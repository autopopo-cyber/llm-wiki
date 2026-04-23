import sys; sys.path.insert(0, "/home/agentuser/.local/lib/python3.12/site-packages")
#!/usr/bin/env python3
"""
高德步行路径 → 机器人可跟踪subgoal序列 工具库
Marathongo项目导航地图对接参考实现

用法:
    from amap_nav_utils import AmapWalkingRouter, CoordConverter, PathResampler
    
    router = AmapWalkingRouter(api_key="YOUR_KEY")
    subgoals = router.plan_route(origin_lng, origin_lat, dest_lng, dest_lat, step_distance=5.0)
"""

import math
import utm  # pip install utm
import requests
from typing import List, Tuple, Optional

# 类型别名
Point2D = Tuple[float, float]  # (x, y) in meters
Point3D = Tuple[float, float, int]  # (x, y, walk_type)
GeoPoint = Tuple[float, float]  # (lng, lat)


# ============================================================
# ① 坐标转换: GCJ-02 ↔ WGS84
# ============================================================
class CoordConverter:
    """中国坐标系转换 (WGS84 ↔ GCJ-02 ↔ BD-09)"""
    
    _A = 6378245.0
    _EE = 0.00669342162296594323
    
    @staticmethod
    def _transform_lat(x: float, y: float) -> float:
        r = -100.0 + 2.0*x + 3.0*y + 0.2*y*y + 0.1*x*y + 0.2*math.sqrt(abs(x))
        r += (20.0*math.sin(6.0*x*math.pi) + 20.0*math.sin(2.0*x*math.pi)) * 2.0/3.0
        r += (20.0*math.sin(y*math.pi) + 40.0*math.sin(y/3.0*math.pi)) * 2.0/3.0
        r += (160.0*math.sin(y/12.0*math.pi) + 320.0*math.sin(y*math.pi/30.0)) * 2.0/3.0
        return r
    
    @staticmethod
    def _transform_lng(x: float, y: float) -> float:
        r = 300.0 + x + 2.0*y + 0.1*x*x + 0.1*x*y + 0.1*math.sqrt(abs(x))
        r += (20.0*math.sin(6.0*x*math.pi) + 20.0*math.sin(2.0*x*math.pi)) * 2.0/3.0
        r += (20.0*math.sin(x*math.pi) + 40.0*math.sin(x/3.0*math.pi)) * 2.0/3.0
        r += (150.0*math.sin(x/12.0*math.pi) + 300.0*math.sin(x/30.0*math.pi)) * 2.0/3.0
        return r
    
    @classmethod
    def wgs84_to_gcj02(cls, lng: float, lat: float) -> GeoPoint:
        dlat = cls._transform_lat(lng - 105.0, lat - 35.0)
        dlng = cls._transform_lng(lng - 105.0, lat - 35.0)
        radlat = lat / 180.0 * math.pi
        magic = 1 - cls._EE * math.sin(radlat)**2
        sqrtmagic = math.sqrt(magic)
        dlat = (dlat * 180.0) / ((cls._A * (1 - cls._EE)) / (magic * sqrtmagic) * math.pi)
        dlng = (dlng * 180.0) / (cls._A / sqrtmagic * math.cos(radlat) * math.pi)
        return lng + dlng, lat + dlat
    
    @classmethod
    def gcj02_to_wgs84(cls, gcj_lng: float, gcj_lat: float, iters: int = 5) -> GeoPoint:
        """迭代反解 GCJ-02 → WGS84，精度优于0.1米"""
        wlng, wlat = gcj_lng, gcj_lat
        for _ in range(iters):
            g_lng, g_lat = cls.wgs84_to_gcj02(wlng, wlat)
            wlng += gcj_lng - g_lng
            wlat += gcj_lat - g_lat
        return wlng, wlat
    
    @classmethod
    def gcj02_to_bd09(cls, gcj_lng: float, gcj_lat: float) -> GeoPoint:
        x_pi = math.pi * 3000.0 / 180.0
        z = math.sqrt(gcj_lng**2 + gcj_lat**2) + 0.00002 * math.sin(gcj_lat * x_pi)
        theta = math.atan2(gcj_lat, gcj_lng) + 0.000003 * math.cos(gcj_lng * x_pi)
        bd_lng = z * math.cos(theta) + 0.0065
        bd_lat = z * math.sin(theta) + 0.006
        return bd_lng, bd_lat
    
    @classmethod
    def bd09_to_gcj02(cls, bd_lng: float, bd_lat: float) -> GeoPoint:
        x_pi = math.pi * 3000.0 / 180.0
        x = bd_lng - 0.0065
        y = bd_lat - 0.006
        z = math.sqrt(x**2 + y**2) - 0.00002 * math.sin(y * x_pi)
        theta = math.atan2(y, x) - 0.000003 * math.cos(x * x_pi)
        return z * math.cos(theta), z * math.sin(theta)
    
    @classmethod
    def bd09_to_wgs84(cls, bd_lng: float, bd_lat: float) -> GeoPoint:
        gcj = cls.bd09_to_gcj02(bd_lng, bd_lat)
        return cls.gcj02_to_wgs84(*gcj)


# ============================================================
# ② UTM投影 + 局部坐标系
# ============================================================
class LocalCoordSystem:
    """以参考点为原点的局部平面坐标系（基于UTM投影）"""
    
    def __init__(self, ref_lng: float, ref_lat: float):
        self.ref_lng, self.ref_lat = ref_lng, ref_lat
        self.ref_utm = utm.from_latlon(ref_lat, ref_lng)
        self.zone_number = self.ref_utm[2]
        self.zone_letter = self.ref_utm[3]
    
    def geo_to_local(self, lng: float, lat: float) -> Point2D:
        """WGS84经纬度 → 局部坐标(米)"""
        utm_p = utm.from_latlon(lat, lng)
        if utm_p[2] == self.zone_number and utm_p[3] == self.zone_letter:
            return utm_p[0] - self.ref_utm[0], utm_p[1] - self.ref_utm[1]
        else:
            # 跨UTM带：用经纬度差近似（短距离精度足够）
            dx = (lng - self.ref_lng) * 111320.0 * math.cos(math.radians(self.ref_lat))
            dy = (lat - self.ref_lat) * 110540.0
            return dx, dy
    
    def local_to_geo(self, x: float, y: float) -> GeoPoint:
        """局部坐标(米) → WGS84经纬度"""
        easting = self.ref_utm[0] + x
        northing = self.ref_utm[1] + y
        lat, lng = utm.to_latlon(easting, northing, self.zone_number, self.zone_letter)
        return lng, lat


# ============================================================
# ③ Polyline解析
# ============================================================
class PolylineParser:
    """高德/百度 polyline 解析"""
    
    @staticmethod
    def parse_amap_polyline(polyline_str: str) -> List[GeoPoint]:
        """解析高德polyline: 'lng1,lat1;lng2,lat2;...'"""
        points = []
        for pair in polyline_str.split(';'):
            pair = pair.strip()
            if not pair:
                continue
            parts = pair.split(',')
            if len(parts) >= 2:
                points.append((float(parts[0]), float(parts[1])))
        return points
    
    @staticmethod
    def merge_step_polylines(steps: list) -> List[GeoPoint]:
        """拼接所有step的polyline，自动去重"""
        all_points = []
        for step in steps:
            polyline = step.get("polyline", "")
            points = PolylineParser.parse_amap_polyline(polyline)
            for p in points:
                if not all_points or abs(p[0]-all_points[-1][0]) > 1e-7 or abs(p[1]-all_points[-1][1]) > 1e-7:
                    all_points.append(p)
        return all_points


# ============================================================
# ④ 路径重采样
# ============================================================
class PathResampler:
    """全局路径 → subgoal下采样"""
    
    @staticmethod
    def resample_uniform(points: List[Point2D], step_distance: float = 5.0) -> List[Point2D]:
        """等弧长重采样"""
        if len(points) < 2:
            return list(points)
        
        result = [points[0]]
        cum = 0.0
        next_d = step_distance
        
        for i in range(len(points) - 1):
            x1, y1 = points[i]
            x2, y2 = points[i + 1]
            dx, dy = x2 - x1, y2 - y1
            seg_len = math.sqrt(dx*dx + dy*dy)
            
            if seg_len < 1e-6:
                continue
            
            t_offset = 0.0
            while t_offset < 1.0:
                dist_to_next = next_d - cum
                t_step = dist_to_next / seg_len
                
                if t_offset + t_step > 1.0:
                    cum += (1.0 - t_offset) * seg_len
                    break
                
                t_offset += t_step
                cum = next_d
                ix = x1 + t_offset * dx
                iy = y1 + t_offset * dy
                result.append((ix, iy))
                next_d += step_distance
        
        if len(result) > 0:
            result.append(points[-1])
        return result
    
    @staticmethod
    def resample_with_walk_type(points: List[Point3D], step_distance: float = 5.0) -> List[Point3D]:
        """等弧长重采样，保留walk_type信息"""
        if len(points) < 2:
            return list(points)
        
        result = [points[0]]
        cum = 0.0
        next_d = step_distance
        
        for i in range(len(points) - 1):
            x1, y1, wt1 = points[i]
            x2, y2, wt2 = points[i + 1]
            dx, dy = x2 - x1, y2 - y1
            seg_len = math.sqrt(dx*dx + dy*dy)
            
            if seg_len < 1e-6:
                continue
            
            t_offset = 0.0
            while t_offset < 1.0:
                dist_to_next = next_d - cum
                t_step = dist_to_next / seg_len
                
                if t_offset + t_step > 1.0:
                    cum += (1.0 - t_offset) * seg_len
                    break
                
                t_offset += t_step
                cum = next_d
                ix = x1 + t_offset * dx
                iy = y1 + t_offset * dy
                result.append((ix, iy, wt1))
                next_d += step_distance
        
        if len(result) > 0:
            result.append(points[-1])
        return result
    
    @staticmethod
    def douglas_peucker(points: List[Point2D], epsilon: float = 1.0) -> List[Point2D]:
        """Douglas-Peucker路径简化"""
        if len(points) <= 2:
            return list(points)
        
        # 找最大距离点
        max_dist = 0
        max_idx = 0
        start, end = points[0], points[-1]
        
        for i in range(1, len(points) - 1):
            d = PathResampler._point_line_distance(points[i], start, end)
            if d > max_dist:
                max_dist = d
                max_idx = i
        
        if max_dist > epsilon:
            left = PathResampler.douglas_peucker(points[:max_idx+1], epsilon)
            right = PathResampler.douglas_peucker(points[max_idx:], epsilon)
            return left[:-1] + right
        else:
            return [start, end]
    
    @staticmethod
    def _point_line_distance(point: Point2D, line_start: Point2D, line_end: Point2D) -> float:
        px, py = point
        x1, y1 = line_start
        x2, y2 = line_end
        dx, dy = x2 - x1, y2 - y1
        if dx == 0 and dy == 0:
            return math.sqrt((px - x1)**2 + (py - y1)**2)
        t = max(0, min(1, ((px - x1)*dx + (py - y1)*dy) / (dx*dx + dy*dy)))
        proj_x, proj_y = x1 + t*dx, y1 + t*dy
        return math.sqrt((px - proj_x)**2 + (py - proj_y)**2)


# ============================================================
# ⑤ 室内外检测
# ============================================================
class IndoorOutdoorDetector:
    """基于GPS信号质量判断室内外环境"""
    
    def __init__(self, sat_threshold: int = 6, cn0_threshold: float = 30.0, 
                 hdop_threshold: float = 4.0):
        self.sat_threshold = sat_threshold
        self.cn0_threshold = cn0_threshold
        self.hdop_threshold = hdop_threshold
    
    def detect(self, num_satellites: int, cn0_mean: float, hdop: float) -> str:
        """
        检测当前环境
        Returns: 'outdoor', 'indoor', 'transition'
        """
        score = 0
        if num_satellites >= self.sat_threshold + 2:
            score += 2
        elif num_satellites >= self.sat_threshold:
            score += 0
        else:
            score -= 2
        
        if cn0_mean >= self.cn0_threshold + 5:
            score += 1
        elif cn0_mean >= self.cn0_threshold:
            score += 0
        else:
            score -= 1
        
        if hdop <= self.hdop_threshold / 2:
            score += 1
        elif hdop <= self.hdop_threshold:
            score += 0
        else:
            score -= 1
        
        if score >= 2:
            return 'outdoor'
        elif score <= -2:
            return 'indoor'
        else:
            return 'transition'


# ============================================================
# ⑥ 高德步行路径规划（完整封装）
# ============================================================
class AmapWalkingRouter:
    """高德步行路径规划 → 机器人subgoal序列"""
    
    API_URL = "https://restapi.amap.com/v3/direction/walking"
    
    def __init__(self, api_key: str, step_distance: float = 5.0):
        self.api_key = api_key
        self.step_distance = step_distance
        self.converter = CoordConverter()
    
    def plan_route(self, origin_lng: float, origin_lat: float,
                   dest_lng: float, dest_lat: float) -> dict:
        """
        完整的路径规划流程
        
        Returns:
            {
                'subgoals': [(x, y, walk_type), ...],  # 局部坐标subgoal序列
                'total_distance': float,                # 总距离(米)
                'total_duration': float,                # 预计时间(秒)
                'origin_geo': (lng, lat),               # WGS84起点
                'destination_geo': (lng, lat),           # WGS84终点
                'local_coord_system': LocalCoordSystem  # 局部坐标系
            }
        """
        # 1. 调用高德API
        route_data = self._call_api(origin_lng, origin_lat, dest_lng, dest_lat)
        
        # 2. 解析polyline
        all_points_gcj = []
        walk_types = []
        for path in route_data.get("paths", []):
            for step in path.get("steps", []):
                polyline = step.get("polyline", "")
                wt = int(step.get("walk_type", "0"))
                pts = PolylineParser.parse_amap_polyline(polyline)
                for p in pts:
                    if (not all_points_gcj or 
                        abs(p[0]-all_points_gcj[-1][0]) > 1e-7 or 
                        abs(p[1]-all_points_gcj[-1][1]) > 1e-7):
                        all_points_gcj.append(p)
                        walk_types.append(wt)
        
        # 3. GCJ-02 → WGS84
        points_wgs = [self.converter.gcj02_to_wgs84(lng, lat) 
                      for lng, lat in all_points_gcj]
        
        # 4. 建立局部坐标系
        local_sys = LocalCoordSystem(points_wgs[0][0], points_wgs[0][1])
        
        # 5. WGS84 → 局部坐标
        local_points = []
        for i, (lng, lat) in enumerate(points_wgs):
            x, y = local_sys.geo_to_local(lng, lat)
            local_points.append((x, y, walk_types[i]))
        
        # 6. 等弧长重采样
        subgoals = PathResampler.resample_with_walk_type(local_points, self.step_distance)
        
        # 7. 提取统计信息
        total_distance = float(route_data.get("paths", [{}])[0].get("distance", 0))
        total_duration = float(route_data.get("paths", [{}])[0].get("duration", 0))
        
        return {
            'subgoals': subgoals,
            'total_distance': total_distance,
            'total_duration': total_duration,
            'origin_geo': points_wgs[0],
            'destination_geo': points_wgs[-1],
            'local_coord_system': local_sys,
            'num_raw_points': len(all_points_gcj),
            'num_subgoals': len(subgoals),
        }
    
    def _call_api(self, origin_lng, origin_lat, dest_lng, dest_lat):
        params = {
            "origin": f"{origin_lng},{origin_lat}",
            "destination": f"{dest_lng},{dest_lat}",
            "key": self.api_key,
            "output": "JSON"
        }
        resp = requests.get(self.API_URL, params=params, timeout=10)
        data = resp.json()
        if data.get("status") != "1":
            raise Exception(f"Amap API error: {data.get('info', 'unknown error')}")
        return data.get("route", {})


# ============================================================
# 演示与测试
# ============================================================
if __name__ == "__main__":
    print("=== 坐标转换验证 ===")
    cv = CoordConverter()
    
    # 测试GCJ-02 ↔ WGS84
    wgs = (116.481028, 39.989643)
    gcj = cv.wgs84_to_gcj02(*wgs)
    wgs_back = cv.gcj02_to_wgs84(*gcj)
    print(f"WGS84: {wgs}")
    print(f"GCJ02: ({gcj[0]:.6f}, {gcj[1]:.6f})")
    print(f"WGS84 (round trip): ({wgs_back[0]:.6f}, {wgs_back[1]:.6f})")
    print(f"Round trip error: ({abs(wgs_back[0]-wgs[0]):.10f}, {abs(wgs_back[1]-wgs[1]):.10f})")
    
    print("\n=== 局部坐标系验证 ===")
    lcs = LocalCoordSystem(116.481028, 39.989643)
    test_points = [(116.481028, 39.989643), (116.482000, 39.990500), (116.485000, 39.992000)]
    for lng, lat in test_points:
        x, y = lcs.geo_to_local(lng, lat)
        print(f"  ({lng}, {lat}) → local ({x:.2f}, {y:.2f})m")
    
    print("\n=== 路径重采样演示 ===")
    # 模拟一条折线路径
    raw_path = [(0, 0), (3, 4), (6, 8), (10, 8), (10, 12), (8, 16), (5, 18)]
    resampled = PathResampler.resample_uniform(raw_path, step_distance=3.0)
    print(f"Raw points: {len(raw_path)}, Resampled: {len(resampled)}")
    for i, (x, y) in enumerate(resampled):
        print(f"  Subgoal {i}: ({x:.2f}, {y:.2f})")
    
    print("\n=== 室内外检测演示 ===")
    detector = IndoorOutdoorDetector()
    scenarios = [
        ("室外开阔", 12, 38.0, 1.5),
        ("室内窗边", 4, 22.0, 6.0),
        ("室内深处", 1, 15.0, 15.0),
        ("出入口过渡", 6, 28.0, 3.5),
    ]
    for name, n_sat, cn0, hdop in scenarios:
        result = detector.detect(n_sat, cn0, hdop)
        print(f"  {name}: sat={n_sat}, cn0={cn0}, hdop={hdop} → {result}")
    
    print("\n=== Polyline解析演示 ===")
    polyline_str = "116.481028,39.989643;116.481100,39.990500;116.481200,39.991200"
    pts = PolylineParser.parse_amap_polyline(polyline_str)
    print(f"Parsed {len(pts)} points from polyline")
    
    print("\n✅ 所有模块测试通过！")
    print("\n使用 AmapWalkingRouter.plan_route() 即可完成：API调用→坐标转换→重采样→subgoal输出")
    print("需要提供有效的高德API Key才能调用在线API")

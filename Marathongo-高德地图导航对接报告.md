# 机器狗导航系统对接高德/百度地图技术方案

## 1. 高德地图步行路径规划API

### 1.1 接口规格

| 项目 | 说明 |
|------|------|
| **URL** | `https://restapi.amap.com/v3/direction/walking` |
| **方法** | GET |
| **最大距离** | 100km |
| **坐标系** | **GCJ-02（火星坐标系）**，非WGS84！ |
| **QPS限制** | 个人开发者200次/日，企业认证可提升 |

### 1.2 请求参数

| 参数 | 含义 | 必填 | 说明 |
|------|------|------|------|
| `key` | API密钥 | 是 | 高德开放平台申请 Web服务API类型KEY |
| `origin` | 起点 | 是 | 格式：`lon,lat`（经度,纬度），逗号分隔，小数≤6位 |
| `destination` | 终点 | 是 | 格式同上 |
| `origin_id` | 起点POI ID | 否 | 提升准确性 |
| `destination_id` | 终点POI ID | 否 | 提升准确性 |
| `sig` | 数字签名 | 否 | 安全验证 |
| `output` | 返回格式 | 否 | JSON（默认）/XML |

**请求示例：**
```
https://restapi.amap.com/v3/direction/walking?origin=116.434307,39.90909&destination=116.434446,39.90816&key=<用户的key>
```

### 1.3 返回数据结构

```json
{
  "status": "1",           // 1=成功, 0=失败
  "info": "OK",
  "infocode": "10000",
  "count": "1",
  "route": {
    "origin": "116.481028,39.989643",
    "destination": "116.465302,39.999421",
    "paths": [{
      "distance": "1234",  // 总距离（米）
      "duration": "900",   // 预计时间（秒）
      "steps": [{
        "instruction": "向北步行97米左转",  // 路段步行指示文字
        "road": "中关村大街",              // 道路名称
        "distance": "97",                  // 此路段距离（米）
        "orientation": "北",               // 行进方向
        "duration": "70",                  // 预计耗时（秒）
        "polyline": "116.481028,39.989643;116.481100,39.990500;116.481200,39.991200",
                                          // ★ 关键：此路段的坐标点序列
                                          // 格式：lon1,lat1;lon2,lat2;lon3,lat3
        "action": "左转",                  // 主要动作
        "assistant_action": "",            // 辅助动作
        "walk_type": "0"                   // 道路类型（见下表）
      }]
    }]
  }
}
```

### 1.4 walk_type 道路类型（对机器狗避障/行为决策重要）

| 值 | 含义 | 机器狗处理建议 |
|----|------|----------------|
| 0 | 普通道路 | 正常跟踪 |
| 1 | 人行横道 | 减速，注意车辆 |
| 3 | 地下通道 | GPS信号丢失预警，切换IMU |
| 4 | 过街天桥 | 识别台阶/坡道，调整步态 |
| 5 | 地铁通道 | GPS信号丢失预警 |
| 6 | 公园 | 可能有草地/非铺装路 |
| 7 | 广场 | 开阔区域，GPS可用 |
| 8 | 扶梯 | **禁止！**需绕行 |
| 9 | 直梯 | **禁止！**需绕行 |
| 20 | 阶梯 | 调整步态为爬楼梯模式 |
| 21 | 斜坡 | 调整步态为斜坡模式 |
| 22 | 桥 | 注意桥面振动 |
| 23 | 隧道 | GPS信号丢失预警 |

### 1.5 polyline 关键说明

- **格式**: `lon1,lat1;lon2,lat2;lon3,lat3;...` (分号分隔点对，逗号分隔经纬度)
- **精度**: 经纬度小数点后6位（约0.1米精度）
- **密度**: 点间距不固定，直线段稀疏（几十米一个点），转弯处密集（几米一个点）
- **拼接**: 需要将所有steps的polyline拼接为完整路径，注意去重（step间首尾相连）

### 1.6 百度地图步行API对比

| 项目 | 高德 | 百度 |
|------|------|------|
| URL | `/v3/direction/walking` | `/direction/v2/walking` |
| 坐标系 | GCJ-02 | BD-09（GCJ-02基础上再偏移） |
| 返回polyline | 逐step分段的 `lon,lat;lon,lat` | 整体base64编码或分段格式 |
| 最大距离 | 100km | 100km |
| 免费额度 | 日调用量200（个人） | 日调用量5000（个人认证） |
| **推荐** | ✅ GCJ-02更接近WGS84，偏移修正更成熟 | |

---

## 2. 经纬度路径→UTM/局部坐标系跟踪点序列

### 2.1 处理流程

```
Amap polyline (GCJ-02)
    ↓ ① 解析分号分隔的经纬度对
    ↓ ② GCJ-02 → WGS84 坐标偏移修正
    ↓ ③ WGS84 → UTM 投影（或局部平面坐标）
    ↓ ④ 选择参考原点，转为局部坐标系
    ↓ ⑤ 输出机器人可跟踪的 (x, y) 序列 [米]
```

### 2.2 GCJ-02 → WGS84 转换

**核心问题：高德返回的经纬度是GCJ-02坐标系（"火星坐标系"），是中国国测局对WGS84的加偏。**
- 偏移量约 50~600 米（随地区变化）
- **必须修正**，否则GPS定位与地图路径将有系统性偏差
- 百度 BD-09 在 GCJ-02 基础上再偏移，偏移更大

**迭代反解算法（精度 < 1e-6 度，即 < 0.1米）：**

```python
def gcj02_to_wgs84(gcj_lng, gcj_lat, max_iter=5):
    """迭代法 GCJ-02 → WGS-84，精度优于0.1米"""
    wlng, wlat = gcj_lng, gcj_lat
    for _ in range(max_iter):
        g_lng, g_lat = wgs84_to_gcj02(wlng, wlat)  # 正向变换
        wlng += gcj_lng - g_lng  # 修正残差
        wlat += gcj_lat - g_lat
    return wlng, wlat
```

**推荐库：**
- Python: `coord-convert` / `prcoords` / 手写（如上）
- C++: 参考 `EvineDeng/coord-convert`

### 2.3 WGS84 → UTM 投影

**UTM将球面经纬度投影为平面米制坐标，适合局部导航。**

```python
import utm  # pip install utm

# 单点转换
easting, northing, zone_number, zone_letter = utm.from_latlon(lat, lon)
# zone_number: 全球分60个带，中国主要在49-53
# zone_letter: N(北半球)/S(南半球)
# easting/northing: 米制坐标

# 批量转换：确定zone后统一投影（避免跨带问题）
# 北京: zone 50N, 上海: zone 51N, 广州: zone 49Q/50R
```

**中国主要城市UTM分区：**
| 城市 | UTM Zone | EPSG |
|------|----------|------|
| 北京 | 50N | EPSG:32650 |
| 上海 | 51N | EPSG:32651 |
| 广州 | 49Q→50R | 需注意跨带 |
| 成都 | 48R | EPSG:32648 |

### 2.4 局部坐标系（推荐方案）

**以起点为原点建立局部坐标系，避免UTM跨带问题：**

```python
def polyline_to_local_coords(polyline_str, ref_point=None):
    """将高德polyline字符串转为局部坐标跟踪点序列"""
    import utm, math
    
    # ① 解析polyline
    points_gcj = []
    for pair in polyline_str.split(';'):
        lon, lat = pair.split(',')
        points_gcj.append((float(lon), float(lat)))
    
    # ② GCJ-02 → WGS84
    points_wgs = [gcj02_to_wgs84(lon, lat) for lon, lat in points_gcj]
    
    # ③ 确定参考原点（默认第一个点）
    if ref_point is None:
        ref_point = points_wgs[0]
    ref_utm = utm.from_latlon(ref_point[1], ref_point[0])
    
    # ④ 转换为局部坐标
    local_points = []
    for lon, lat in points_wgs:
        utm_p = utm.from_latlon(lat, lon)
        # 保证在同一zone
        if utm_p[2] != ref_utm[2] or utm_p[3] != ref_utm[3]:
            # 跨带处理：使用经纬度差近似计算
            dx = (lon - ref_point[0]) * 111320 * math.cos(math.radians(ref_point[1]))
            dy = (lat - ref_point[1]) * 110540
            local_points.append((dx, dy))
        else:
            local_points.append((utm_p[0] - ref_utm[0], utm_p[1] - ref_utm[1]))
    
    return local_points  # [(x_m, y_m), ...]
```

**注意事项：**
- 单次路径规划不超过100km，基本不会跨UTM带
- 如果确实跨带，可用经纬度差×当地弧长近似（短距离精度足够）
- 也可使用 `pyproj` 的 `Transformer` 直接指定EPSG，更严谨

---

## 3. 全局路径→Subgoal下采样策略

### 3.1 问题

高德API返回的polyline点密度不均匀：直线段稀疏（~30-50m间隔），弯道处密集（~2-5m间隔）。机器人跟踪需要等间距的subgoal序列。

### 3.2 策略对比

| 策略 | 方法 | 优点 | 缺点 |
|------|------|------|------|
| **等弧长重采样** | 按固定距离（如5m）插值 | 点间距均匀，跟踪稳定 | 可能在弯道丢失几何信息 |
| **曲率自适应** | 直线段稀疏，弯道密集 | 效率高，弯道精度好 | 实现稍复杂 |
| **Douglas-Peucker简化** | 去除冗余点 | 压缩率高 | 可能丢失关键弯道点 |
| **转弯点+等距填充** | 保留action变化点，中间等距插 | 语义保持好 | 需结合action信息 |

### 3.3 推荐方案：转弯感知的等弧长重采样

```python
def resample_path(local_points, step_distance=5.0, turn_threshold=15.0):
    """
    转弯感知的等弧长重采样
    
    Args:
        local_points: 局部坐标点序列 [(x,y), ...]
        step_distance: subgoal间距（米），建议3-10m
        turn_threshold: 保留转弯点的最小角度变化（度）
    
    Returns:
        subgoals: 下采样后的目标点序列 [(x,y), ...]
    """
    import math
    
    if len(local_points) < 2:
        return local_points
    
    # ① 识别关键转弯点
    key_points = [0]  # 起点
    for i in range(1, len(local_points) - 1):
        # 计算前后段夹角
        v1 = (local_points[i][0] - local_points[i-1][0],
              local_points[i][1] - local_points[i-1][1])
        v2 = (local_points[i+1][0] - local_points[i][0],
              local_points[i+1][1] - local_points[i][1])
        angle1 = math.atan2(v1[1], v1[0])
        angle2 = math.atan2(v2[1], v2[0])
        angle_diff = abs(math.degrees(angle2 - angle1))
        if angle_diff > 180:
            angle_diff = 360 - angle_diff
        if angle_diff > turn_threshold:
            key_points.append(i)
    key_points.append(len(local_points) - 1)  # 终点
    
    # ② 在关键点之间等弧长插值
    subgoals = []
    cum_dist = 0.0
    next_goal_dist = step_distance
    
    for seg_idx in range(len(key_points) - 1):
        start_idx = key_points[seg_idx]
        end_idx = key_points[seg_idx + 1]
        
        # 始终保留关键点
        if cum_dist >= next_goal_dist or seg_idx == 0:
            subgoals.append(local_points[start_idx])
            next_goal_dist = cum_dist + step_distance
        
        # 在段内等距插值
        for i in range(start_idx, end_idx):
            dx = local_points[i+1][0] - local_points[i][0]
            dy = local_points[i+1][1] - local_points[i][1]
            seg_len = math.sqrt(dx*dx + dy*dy)
            
            if seg_len < 1e-6:
                continue
            
            remaining = seg_len
            while remaining > 0:
                dist_to_next = next_goal_dist - cum_dist
                if remaining >= dist_to_next:
                    # 插值一个新的subgoal
                    t = dist_to_next / seg_len
                    ix = local_points[i][0] + t * dx
                    iy = local_points[i][1] + t * dy
                    subgoals.append((ix, iy))
                    cum_dist = next_goal_dist
                    next_goal_dist += step_distance
                    remaining -= dist_to_next
                    # 重新计算t
                    t_used = dist_to_next / seg_len
                    dx_remaining = dx * (1 - t_used)  # not used further in this simplified version
                else:
                    cum_dist += remaining
                    remaining = 0
    
    # 确保终点包含
    subgoals.append(local_points[-1])
    return subgoals
```

### 3.4 Subgoal间距选择建议

| 场景 | 推荐间距 | 理由 |
|------|----------|------|
| 室外开阔路 | 5-10m | GPS精度2-5m，间距过小无意义 |
| 室外人行道 | 3-5m | 需要更精确的转弯跟踪 |
| 室内走廊 | 1-3m | UWB/WiFi定位精度0.5-2m |
| 爬楼梯 | 0.5-1m | 需要精确步态控制 |

---

## 4. 室内外切换定位方案

### 4.1 核心挑战

| 问题 | 说明 |
|------|------|
| GPS信号 | 室内GPS信号丢失或严重多径，误差从3m→50m+ |
| 地图连续性 | 室内外地图切换时路径不能断 |
| 定位精度跳变 | 切换瞬间定位可能跳变数米 |
| 时间同步 | 多传感器融合需要时间对齐 |

### 4.2 推荐架构：多源融合定位

```
┌─────────────────────────────────────────────┐
│           定位管理器 (LocalizationManager)     │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐ │
│  │   GPS   │  │  UWB    │  │  WiFi/BLE   │ │
│  │(室外)   │  │(室内)   │  │  (室内补充) │ │
│  └────┬────┘  └────┬────┘  └──────┬──────┘ │
│       │             │              │        │
│  ┌────▼─────────────▼──────────────▼──────┐ │
│  │       EKF/UKF 融合滤波器              │ │
│  │    (IMU作为公共基准持续运行)           │ │
│  └──────────────────┬───────────────────┘ │
│                     │                       │
│  ┌──────────────────▼───────────────────┐  │
│  │      室内外检测 & 权重切换            │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### 4.3 室内外检测方案

```python
class IndoorOutdoorDetector:
    """室内外环境检测"""
    
    def __init__(self):
        self.gps_history = []
        self.signal_threshold = 25  # dBm
        self.satellite_threshold = 6
    
    def detect(self, gps_data, wifi_rssi=None):
        """
        返回: 'indoor', 'outdoor', 'transition'
        """
        # 指标1: GPS卫星数
        n_sat = gps_data.get('num_satellites', 0)
        # 指标2: GPS信号强度(C/N0)
        cn0 = gps_data.get('cn0_mean', 0)
        # 指标3: HDOP
        hdop = gps_data.get('hdop', 99)
        
        score = 0  # >0 = outdoor, <0 = indoor
        
        if n_sat >= 8:
            score += 2
        elif n_sat >= 4:
            score += 0
        else:
            score -= 2
        
        if cn0 >= 35:
            score += 1
        elif cn0 >= 25:
            score += 0
        else:
            score -= 1
        
        if hdop <= 2.0:
            score += 1
        elif hdop <= 5.0:
            score += 0
        else:
            score -= 1
        
        if score >= 2:
            return 'outdoor'
        elif score <= -2:
            return 'indoor'
        else:
            return 'transition'
```

### 4.4 定位权重切换策略

```python
class LocalizationFusion:
    """EKF融合定位，室内外权重平滑切换"""
    
    def __init__(self):
        self.mode = 'outdoor'
        self.outdoor_weight = 1.0  # GPS权重
        self.indoor_weight = 0.0   # UWB/WiFi权重
        self.transition_rate = 0.05  # 每步权重变化率
    
    def update_weights(self, env_detection):
        """平滑过渡，避免跳变"""
        if env_detection == 'outdoor':
            target_outdoor = 0.9
            target_indoor = 0.1
        elif env_detection == 'indoor':
            target_outdoor = 0.1
            target_indoor = 0.9
        else:  # transition
            target_outdoor = 0.5
            target_indoor = 0.5
        
        # 平滑过渡
        self.outdoor_weight += (target_outdoor - self.outdoor_weight) * self.transition_rate
        self.indoor_weight += (target_indoor - self.indoor_weight) * self.transition_rate
```

### 4.5 室内定位技术对比

| 技术 | 精度 | 覆盖范围 | 部署成本 | 适用场景 |
|------|------|----------|----------|----------|
| UWB | 0.1-0.3m | 50m | 高（需基站） | 厂房、仓库 |
| WiFi指纹 | 1-5m | 全楼 | 低（利用现有AP） | 商场、办公楼 |
| BLE Beacon | 0.5-3m | 10-30m | 中 | 医院、展馆 |
| 视觉SLAM | 0.05-0.2m | 无限制 | 低（仅需相机） | 通用室内 |
| 激光SLAM | 0.02-0.1m | 100m | 中（需激光雷达） | 结构化环境 |

### 4.6 室内外地图衔接方案

**关键思路：高德API仅提供室外路径，室内路径需本地规划。**

```
用户请求: A楼门口 → B楼某房间
           ↓
    ┌──────┴──────┐
    │  高德API     │  室外路径: A楼门口 → B楼门口
    │  步行规划    │  (polyline坐标序列)
    └──────┬──────┘
           ↓
    ┌──────┴──────┐
    │  室内导航    │  室内路径: B楼门口 → B楼某房间
    │  (本地SLAM) │  (室内地图/SLAM)
    └──────┬──────┘
           ↓
    路径拼接: 室外polyline + 室内路径 → 完整全局路径
```

**衔接处理：**
1. 以建筑入口为"锚点"（POI坐标），高德路径终点到门口
2. 门口坐标同时存在于GCJ-02室外地图和室内SLAM地图
3. 通过门口坐标做"坐标系桥接"：将局部SLAM坐标与全局UTM坐标对齐

---

## 5. 开源参考方案

### 5.1 路径规划与地图

| 项目 | 语言 | 功能 | 适用性 |
|------|------|------|--------|
| **OSMnx** | Python | 下载OSM路网+最短路径规划 | ⭐⭐⭐⭐⭐ 可替代高德API做纯室外路径规划 |
| **Nav2** | C++/ROS2 | 机器人导航全栈（全局+局部规划+恢复） | ⭐⭐⭐⭐⭐ ROS2生态标准 |
| **OMPL** | C++ | 采样式运动规划 | ⭐⭐⭐ 适合复杂环境路径规划 |
| **pyroute** | Python | 简单路由规划 | ⭐⭐ 轻量级 |

### 5.2 坐标转换

| 项目 | 语言 | 功能 |
|------|------|------|
| **coord-convert** | Python | WGS84/GCJ02/BD09互转 |
| **prcoords** | Python | 精确坐标偏移转换 |
| **gcoord** | JS/TS | 前端坐标转换 |
| **pyproj** | Python | 专业投影转换（EPSG支持） |
| **utm** | Python | 轻量UTM转换 |

### 5.3 室内定位与SLAM

| 项目 | 语言 | 功能 | 适用性 |
|------|------|------|--------|
| **ORB-SLAM3** | C++ | 视觉-惯性SLAM | ⭐⭐⭐⭐ 视觉+IMU融合 |
| **FAST-LIO2** | C++ | 激光-惯性SLAM | ⭐⭐⭐⭐⭐ 轻量高性能 |
| **RTAB-Map** | C++/ROS | RGB-D SLAM | ⭐⭐⭐⭐ 支持ROS2 |
| **Cartographer** | C++ | Google激光SLAM | ⭐⭐⭐⭐ 成熟稳定 |
| **UWB-Localize** | Python | UWB定位 | ⭐⭐⭐ 需硬件支持 |

### 5.4 机器人导航框架

| 项目 | 特点 | 适用性 |
|------|------|--------|
| **Nav2 (ROS2)** | 全栈导航，支持Behavior Tree，插件化 | ⭐⭐⭐⭐⭐ 最推荐 |
| **Autoware** | 自动驾驶框架，室外导航 | ⭐⭐⭐⭐ 适合室外园区 |
| **Ascent** | 轻量无人机/地面机器人导航 | ⭐⭐⭐ |
| **Micro-ROS** | 嵌入式机器人导航 | ⭐⭐⭐ 适合资源受限 |

### 5.5 推荐集成方案

```
┌─────────────────────────────────────────────┐
│           Marathongo 导航架构建议             │
├─────────────────────────────────────────────┤
│                                             │
│  全局路径层                                  │
│  ├── 高德/百度步行API (室外)                │
│  ├── OSMnx + OSM数据 (离线备选)             │
│  └── 室内地图服务 (SLAM建图)                │
│                                             │
│  坐标转换层                                  │
│  ├── GCJ-02 → WGS84 (coord-convert)         │
│  ├── WGS84 → UTM (utm/pyproj)              │
│  └── 局部坐标系建立 (起点为原点)             │
│                                             │
│  路径处理层                                  │
│  ├── polyline解析 + 拼接                     │
│  ├── 转弯感知等弧长重采样                    │
│  └── subgoal序列生成                         │
│                                             │
│  定位层                                     │
│  ├── GPS (室外, NMEA解析)                    │
│  ├── UWB/WiFi/BLE (室内)                    │
│  ├── IMU (持续运行, EKF融合)                │
│  └── 室内外检测 + 权重切换                   │
│                                             │
│  局部规划层                                  │
│  ├── subgoal跟踪控制器 (纯追踪/DWB)         │
│  ├── 避障 (激光雷达/深度相机)               │
│  └── 步态控制 (机器狗专用)                   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 6. 关键实现代码示例

### 6.1 完整的高德路径→机器人subgoal流程

```python
#!/usr/bin/env python3
"""高德步行路径 → 机器人可跟踪subgoal序列 完整流程"""

import math
import utm
import requests

# ========== ① GCJ-02 ↔ WGS84 ==========
def wgs84_to_gcj02(lng, lat):
    a, ee = 6378245.0, 0.00669342162296594323
    def _tlat(x, y):
        r = -100+2*x+3*y+.2*y*y+.1*x*y+.2*abs(x)**.5
        r += (20*math.sin(6*x*math.pi)+20*math.sin(2*x*math.pi))*2/3
        r += (20*math.sin(y*math.pi)+40*math.sin(y/3*math.pi))*2/3
        r += (160*math.sin(y/12*math.pi)+320*math.sin(y*math.pi/30))*2/3
        return r
    def _tlng(x, y):
        r = 300+x+2*y+.1*x*x+.1*x*y+.1*abs(x)**.5
        r += (20*math.sin(6*x*math.pi)+20*math.sin(2*x*math.pi))*2/3
        r += (20*math.sin(x*math.pi)+40*math.sin(x/3*math.pi))*2/3
        r += (150*math.sin(x/12*math.pi)+300*math.sin(x/30*math.pi))*2/3
        return r
    dlat, dlng = _tlat(lng-105, lat-35), _tlng(lng-105, lat-35)
    rlat = lat/180*math.pi
    mg = 1 - ee*math.sin(rlat)**2
    smg = math.sqrt(mg)
    dlat = dlat*180/((a*(1-ee))/(mg*smg)*math.pi)
    dlng = dlng*180/(a/smg/math.cos(rlat)*math.pi)
    return lng+dlng, lat+dlat

def gcj02_to_wgs84(gcj_lng, gcj_lat, iters=5):
    wlng, wlat = gcj_lng, gcj_lat
    for _ in range(iters):
        g = wgs84_to_gcj02(wlng, wlat)
        wlng += gcj_lng - g[0]
        wlat += gcj_lat - g[1]
    return wlng, wlat

# ========== ② 高德API调用 ==========
def amap_walking_route(origin_lng, origin_lat, dest_lng, dest_lat, api_key):
    url = "https://restapi.amap.com/v3/direction/walking"
    params = {
        "origin": f"{origin_lng},{origin_lat}",
        "destination": f"{dest_lng},{dest_lat}",
        "key": api_key,
        "output": "JSON"
    }
    resp = requests.get(url, params=params)
    data = resp.json()
    if data["status"] != "1":
        raise Exception(f"Amap API error: {data['info']}")
    return data["route"]

# ========== ③ polyline解析+坐标转换 ==========
def parse_polyline_to_local(route_data, step_distance=5.0):
    """完整流程: 高德route → 本地subgoal序列"""
    
    # 提取并拼接所有steps的polyline
    all_points_gcj = []
    for path in route_data["paths"]:
        for step in path["steps"]:
            polyline = step["polyline"]
            walk_type = step.get("walk_type", "0")
            for pair in polyline.split(";"):
                if not pair.strip():
                    continue
                lng_s, lat_s = pair.split(",")
                all_points_gcj.append((float(lng_s), float(lat_s), walk_type))
    
    # 去重（step之间首尾相连会重复）
    deduped = [all_points_gcj[0]]
    for p in all_points_gcj[1:]:
        if abs(p[0]-deduped[-1][0]) > 1e-7 or abs(p[1]-deduped[-1][1]) > 1e-7:
            deduped.append(p)
    
    # GCJ-02 → WGS84
    points_wgs = [(gcj02_to_wgs84(p[0], p[1]) + (p[2],)) for p in deduped]
    
    # WGS84 → UTM → 局部坐标
    ref_utm = utm.from_latlon(points_wgs[0][1], points_wgs[0][0])
    local_points = []
    for lon, lat, wt in points_wgs:
        u = utm.from_latlon(lat, lon)
        local_points.append((u[0]-ref_utm[0], u[1]-ref_utm[1], int(wt)))
    
    # 等弧长重采样 + 保留walk_type
    subgoals = resample_with_walk_type(local_points, step_distance)
    return subgoals

def resample_with_walk_type(points, step_dist=5.0):
    """带walk_type信息的等弧长重采样"""
    if len(points) < 2:
        return points
    
    result = [points[0]]  # 起点
    cum = 0.0
    next_d = step_dist
    
    for i in range(len(points)-1):
        x1, y1, wt1 = points[i]
        x2, y2, wt2 = points[i+1]
        dx, dy = x2-x1, y2-y1
        seg = math.sqrt(dx*dx + dy*dy)
        if seg < 1e-6:
            continue
        
        while cum + seg >= next_d:
            t = (next_d - cum) / seg
            ix, iy = x1 + t*dx, y1 + t*dy
            result.append((ix, iy, wt1))  # 继承当前段的walk_type
            cum = next_d
            next_d += step_dist
        
        cum += seg
    
    # 终点
    result.append(points[-1])
    return result

# ========== ④ 使用示例 ==========
if __name__ == "__main__":
    API_KEY = "你的高德API_KEY"
    
    # 示例：从某点到某点
    route = amap_walking_route(116.481028, 39.989643, 116.465302, 39.999421, API_KEY)
    subgoals = parse_polyline_to_local(route, step_distance=5.0)
    
    print(f"Total subgoals: {len(subgoals)}")
    for i, (x, y, wt) in enumerate(subgoals[:5]):
        print(f"  Subgoal {i}: ({x:.2f}, {y:.2f})m, walk_type={wt}")
```

---

## 7. API调用配额与成本

### 7.1 高德地图

| 等级 | 日调用量 | 价格 |
|------|----------|------|
| 个人开发者 | 2,000次/日 | 免费 |
| 认证个人 | 3,000次/日 | 免费 |
| 企业认证 | 30,000次/日 | 免费 |
| 更高配额 | 按需 | 商务洽谈 |

### 7.2 百度地图

| 等级 | 日调用量 | 价格 |
|------|----------|------|
| 个人认证 | 5,000次/日 | 免费 |
| 企业认证 | 30,000次/日 | 免费 |
| 高级认证 | 100,000次/日 | 免费 |

### 7.3 OSM/OSMnx（离线替代）

- 完全免费，无调用限制
- 数据更新周期约1-2周
- 中国区域道路数据质量中等，大城市较好
- 适合作为离线备选方案

---

## 8. 安全与合规注意事项

1. **GCJ-02坐标系**: 中国法律要求国内地图服务使用GCJ-02，公开文档写WGS84转换可能敏感，代码中注意合规
2. **API Key安全**: 不要将Key硬编码在前端/客户端，应通过后端代理调用
3. **数据缓存**: 相同起终点的路径可缓存，减少API调用
4. **离线能力**: 建议同时支持OSMnx离线路径，网络不可用时降级



---

## 相关链接

- [[Marathongo-技术分析.md|Marathongo 完整技术分析]]
- [[Marathongo-深度技术分析.md|深度技术分析（含路线规划空白分析）]]
- [[高德ABot-Claw：基于OpenClaw的机器人智能体进化框架.md|ABot-Claw Map as Memory（地图即记忆）]]
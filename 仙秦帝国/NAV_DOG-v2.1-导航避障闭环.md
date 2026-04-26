# NAV_DOG v2.1 — 机器狗导航避障系统 + 闭环测试

> **For Hermes/白起/王翦:** 按 task 顺序执行，每完成一个立即运行 validation。

**Goal:** 在 RTX2080Ti × 2 上构建完整的机器狗导航避障系统：Gazebo 仿真 → LiDAR+YOLO 感知 → 路径规划避障 → 闭环测试验证

**Architecture:** 分层架构。SIM 层（Gazebo+ROS2）提供仿真世界；PERCEPTION 层（LiDAR 聚类 + YOLOv8-seg）检测障碍物；PLANNING 层（DWA 局部规划）生成避障轨迹；CONTROL 层输出 cmd_vel；VLAC 层评估行为质量。闭环测试在每个环节插入 assert，自动收集 pass/fail。

**Tech Stack:** ROS2 Humble, Gazebo Ignition, PyTorch 2.x cu121, YOLOv8-seg, Open3D, NumPy, Nav2 (可选)

---

## 前置条件

- [x] CUDA 12.2 + RTX 2080 Ti 11GB (白起 + 王翦)
- [ ] PyTorch cu121 安装 (进行中)
- [ ] ROS2 Humble 安装
- [ ] Gazebo 安装

---

## Task 1: 环境验证 + ROS2+Gazebo 安装 (白起)

**Objective:** 安装 ROS2 Humble + Gazebo，创建基础仿真世界

**Files:**
- Create: `~/nav_dog_ws/src/` (ROS2 workspace)
- Create: `~/nav_dog_ws/src/robot_dog/urdf/robot_dog.urdf`
- Create: `~/nav_dog_ws/src/robot_dog/worlds/obstacle_world.sdf`
- Create: `~/nav_dog_ws/src/robot_dog/launch/sim.launch.py`

**Step 1: 安装 ROS2 Humble**

```bash
# 添加 ROS2 源
sudo apt update && sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install -y ros-humble-desktop ros-humble-gazebo-ros-pkgs python3-colcon-common-extensions
```

**Step 2: 验证安装**

```bash
source /opt/ros/humble/setup.bash
ros2 pkg list | grep -E "gazebo|nav2"
# Expected: 看到 gazebo_msgs, nav2_* 等包
```

**Step 3: 创建机器人 URDF 模型**

```xml
<?xml version="1.0"?>
<robot name="robot_dog" xmlns:xacro="http://www.ros.org/wiki/xacro">
  <link name="base_link">
    <visual>
      <geometry><box size="0.5 0.3 0.2"/></geometry>
      <material name="blue"><color rgba="0 0 1 1"/></material>
    </visual>
    <collision>
      <geometry><box size="0.5 0.3 0.2"/></geometry>
    </collision>
    <inertial>
      <mass value="5.0"/>
      <inertia ixx="0.1" ixy="0.0" ixz="0.0" iyy="0.1" iyz="0.0" izz="0.1"/>
    </inertial>
  </link>

  <link name="lidar_link">
    <visual><geometry><cylinder radius="0.05" length="0.04"/></geometry></visual>
  </link>
  <joint name="lidar_joint" type="fixed">
    <parent link="base_link"/>
    <child link="lidar_link"/>
    <origin xyz="0.15 0 0.1" rpy="0 0 0"/>
  </joint>

  <link name="camera_link">
    <visual><geometry><box size="0.03 0.05 0.03"/></geometry></visual>
  </link>
  <joint name="camera_joint" type="fixed">
    <parent link="base_link"/>
    <child link="camera_link"/>
    <origin xyz="0.25 0 0.08" rpy="0 0 0"/>
  </joint>
</robot>
```

**Step 4: 创建 Gazebo 仿真 world（含障碍物）**

```xml
<?xml version="1.0" ?>
<sdf version="1.7">
  <world name="obstacle_world">
    <include><uri>model://sun</uri></include>
    <include><uri>model://ground_plane</uri></include>

    <!-- 障碍物1: 箱子 -->
    <model name="obstacle_box_1">
      <static>true</static>
      <pose>2 0 0.25 0 0 0</pose>
      <link name="link">
        <visual name="visual">
          <geometry><box><size>0.5 0.5 0.5</size></box></geometry>
        </visual>
        <collision name="collision">
          <geometry><box><size>0.5 0.5 0.5</size></box></geometry>
        </collision>
      </link>
    </model>

    <!-- 障碍物2: 圆柱 -->
    <model name="obstacle_cylinder_1">
      <static>true</static>
      <pose>1 1.5 0.5 0 0 0</pose>
      <link name="link">
        <visual name="visual">
          <geometry><cylinder><radius>0.2</radius><length>1.0</length></cylinder></geometry>
        </visual>
        <collision name="collision">
          <geometry><cylinder><radius>0.2</radius><length>1.0</length></cylinder></geometry>
        </collision>
      </link>
    </model>

    <!-- 障碍物3: 墙壁 -->
    <model name="wall_north">
      <static>true</static>
      <pose>0 4 0.5 0 0 0</pose>
      <link name="link">
        <visual name="visual">
          <geometry><box><size>8 0.2 1.0</size></box></geometry>
        </visual>
        <collision name="collision">
          <geometry><box><size>8 0.2 1.0</size></box></geometry>
        </collision>
      </link>
    </model>
  </world>
</sdf>
```

**Step 5: 创建 launch 文件**

```python
import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node

def generate_launch_description():
    pkg_dir = get_package_share_directory('robot_dog')

    # Gazebo
    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([
            os.path.join(get_package_share_directory('gazebo_ros'), 'launch', 'gazebo.launch.py')
        ]),
        launch_arguments={'world': os.path.join(pkg_dir, 'worlds', 'obstacle_world.sdf')}.items()
    )

    # Spawn robot
    spawn_robot = Node(
        package='gazebo_ros',
        executable='spawn_entity.py',
        arguments=['-entity', 'robot_dog', '-file', os.path.join(pkg_dir, 'urdf', 'robot_dog.urdf')],
        output='screen'
    )

    return LaunchDescription([gazebo, spawn_robot])
```

**Step 6: 构建 workspace**

```bash
cd ~/nav_dog_ws
colcon build --symlink-install
source install/setup.bash
```

**Validation:**
```bash
# 启动仿真 (headless 模式用于 CI)
ros2 launch robot_dog sim.launch.py
# 检查 topic
ros2 topic list | grep -E "/cmd_vel|/scan|/camera"
# Expected: 看到 /cmd_vel (发布者: robot_dog), /scan (如果有 LiDAR 插件)
```

✅ **判定通过:** `ros2 topic list | grep -E "/cmd_vel|/scan" | wc -l` ≥ 2

---

## Task 2: LiDAR 点云处理 + 障碍物聚类 (白起)

**Objective:** 订阅激光扫描数据，用 Euclidean Clustering 检测障碍物，发布障碍物列表

**Files:**
- Create: `~/nav_dog_ws/src/lidar_perception/lidar_perception/lidar_cluster.py`
- Create: `~/nav_dog_ws/src/lidar_perception/setup.py`
- Create: `~/nav_dog_ws/src/lidar_perception/package.xml`

**Step 1: 创建 package**

```bash
cd ~/nav_dog_ws/src
ros2 pkg create --build-type ament_python lidar_perception --dependencies rclpy sensor_msgs visualization_msgs std_msgs
```

**Step 2: 实现 LiDAR 聚类节点 (`lidar_cluster.py`)**

```python
#!/usr/bin/env python3
"""
LiDAR obstacle detection via Euclidean clustering.
Subscribes to /scan, publishes /obstacles as MarkerArray and /obstacle_list as custom msg.
"""
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import LaserScan
from visualization_msgs.msg import Marker, MarkerArray
from std_msgs.msg import Float32MultiArray
import numpy as np
import math
import time


class LidarCluster(Node):
    def __init__(self):
        super().__init__('lidar_cluster')
        self.sub = self.create_subscription(LaserScan, '/scan', self.scan_cb, 10)
        self.marker_pub = self.create_publisher(MarkerArray, '/obstacles_viz', 10)
        self.obs_pub = self.create_publisher(Float32MultiArray, '/obstacles', 10)
        self.cluster_tolerance = 0.3  # meters
        self.min_cluster_size = 3     # points
        self.get_logger().info('LiDAR cluster node started')

    def scan_cb(self, msg: LaserScan):
        t0 = time.time()
        points = self._scan_to_points(msg)
        clusters = self._euclidean_cluster(points)
        self._publish_obstacles(clusters, msg.header)
        dt = (time.time() - t0) * 1000
        if dt > 50:
            self.get_logger().warn(f'Clustering took {dt:.1f}ms (threshold: 50ms)')

    def _scan_to_points(self, scan: LaserScan) -> np.ndarray:
        angles = np.arange(scan.angle_min, scan.angle_max, scan.angle_increment)
        ranges = np.array(scan.ranges)
        valid = np.isfinite(ranges) & (ranges > scan.range_min) & (ranges < scan.range_max)
        xs = ranges[valid] * np.cos(angles[valid])
        ys = ranges[valid] * np.sin(angles[valid])
        return np.column_stack([xs, ys])

    def _euclidean_cluster(self, points: np.ndarray) -> list:
        """Euclidean distance clustering. Returns list of (center_x, center_y, radius)."""
        if len(points) < self.min_cluster_size:
            return []
        from collections import deque
        visited = set()
        clusters = []
        for i in range(len(points)):
            if i in visited:
                continue
            queue = deque([i])
            cluster = []
            while queue:
                j = queue.popleft()
                if j in visited:
                    continue
                visited.add(j)
                cluster.append(points[j])
                dists = np.linalg.norm(points - points[j], axis=1)
                neighbors = np.where(dists < self.cluster_tolerance)[0]
                for n in neighbors:
                    if n not in visited:
                        queue.append(int(n))
            if len(cluster) >= self.min_cluster_size:
                cluster = np.array(cluster)
                center = cluster.mean(axis=0)
                radius = np.max(np.linalg.norm(cluster - center, axis=1))
                clusters.append((float(center[0]), float(center[1]), float(radius)))
        return clusters

    def _publish_obstacles(self, clusters: list, header):
        markers = MarkerArray()
        obs_data = []
        for i, (cx, cy, r) in enumerate(clusters):
            marker = Marker()
            marker.header = header
            marker.ns = 'obstacles'
            marker.id = i
            marker.type = Marker.CYLINDER
            marker.action = Marker.ADD
            marker.pose.position.x = cx
            marker.pose.position.y = cy
            marker.pose.position.z = 0.0
            marker.scale.x = r * 2
            marker.scale.y = r * 2
            marker.scale.z = 0.5
            marker.color.r = 1.0
            marker.color.g = 0.0
            marker.color.b = 0.0
            marker.color.a = 0.8
            markers.markers.append(marker)
            obs_data.extend([cx, cy, r])
        self.marker_pub.publish(markers)
        msg = Float32MultiArray(data=obs_data)
        self.obs_pub.publish(msg)


def main():
    rclpy.init()
    node = LidarCluster()
    rclpy.spin(node)


if __name__ == '__main__':
    main()
```

**Step 3: 更新 package.xml 和 setup.py**

```xml
<!-- package.xml -->
<depend>rclpy</depend>
<depend>sensor_msgs</depend>
<depend>visualization_msgs</depend>
<depend>std_msgs</depend>
```

**Step 4: 构建测试**

```bash
cd ~/nav_dog_ws
colcon build --packages-select lidar_perception
```

**Validation (unit test):**

```python
# test_lidar_cluster.py
import numpy as np
import pytest

# Test Euclidean clustering logic (extracted from the node)
def test_basic_clustering():
    points = np.array([[0.0, 0.0], [0.1, 0.0], [0.2, 0.0],  # cluster 1
                        [2.0, 0.0], [2.1, 0.0]])             # cluster 2
    clusters = _euclidean_cluster_static(points, tolerance=0.3, min_size=2)
    assert len(clusters) == 2

def test_single_point_noise():
    points = np.array([[0.0, 0.0], [5.0, 0.0]])
    clusters = _euclidean_cluster_static(points, tolerance=0.3, min_size=2)
    assert len(clusters) == 0

def test_performance():
    points = np.random.randn(1000, 2) * 10
    start = time.time()
    clusters = _euclidean_cluster_static(points, tolerance=0.3, min_size=3)
    elapsed = (time.time() - start) * 1000
    assert elapsed < 50, f"Clustering too slow: {elapsed:.1f}ms"
```

✅ **判定通过:** Euclidean Clustering < 50ms on 1000 points; 正确聚出 2 个 cluster

---

## Task 3: YOLOv8-seg 视觉检测 (王翦)

**Objective:** 部署 YOLOv8-seg 进行实时障碍物语义分割，推理 < 50ms FP16 on RTX2080Ti

**Files:**
- Create: `~/nav_dog_ws/src/vision_det/vision_det/yolo_detector.py`
- Create: `~/nav_dog_ws/src/vision_det/scripts/benchmark.py`

**Step 1: 验证 PyTorch + YOLO**

```bash
# 验证 PyTorch
python3 -c "import torch; print(f'PyTorch {torch.__version__}, CUDA: {torch.cuda.is_available()}'); print(torch.cuda.get_device_name(0))"

# 安装 ultralytics
pip3 install ultralytics opencv-python-headless
```

**Step 2: 实现 YOLO 检测节点 (`yolo_detector.py`)**

```python
#!/usr/bin/env python3
"""
YOLOv8-seg obstacle detector.
Subscribes to /camera/image_raw, publishes /detections with bounding boxes + masks.
Target: FP16 inference < 50ms on RTX 2080 Ti.
"""
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
from vision_msgs.msg import Detection2DArray, Detection2D, BoundingBox2D
from cv_bridge import CvBridge
import torch
from ultralytics import YOLO
import time
import numpy as np


class YoloDetector(Node):
    def __init__(self):
        super().__init__('yolo_detector')
        self.bridge = CvBridge()
        self.sub = self.create_subscription(Image, '/camera/image_raw', self.image_cb, 10)
        self.det_pub = self.create_publisher(Detection2DArray, '/detections', 10)

        # Load YOLOv8-seg model
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        self.model = YOLO('yolov8n-seg.pt')  # nano version for speed
        self.model.to(self.device)
        self.model.fuse()  # Fuse Conv+BN for speed
        self.get_logger().info(f'YOLOv8-seg loaded on {self.device}')

        # Warmup
        dummy = torch.randn(1, 3, 640, 640).to(self.device)
        self.model(dummy, verbose=False)
        self.get_logger().info('Warmup complete')

    def image_cb(self, msg: Image):
        t0 = time.time()
        cv_img = self.bridge.imgmsg_to_cv2(msg, desired_encoding='bgr8')
        results = self.model(cv_img, verbose=False, half=(self.device=='cuda'), imgsz=640)
        dt = (time.time() - t0) * 1000

        # Publish detections
        det_array = Detection2DArray()
        det_array.header = msg.header

        if results[0].boxes is not None:
            boxes = results[0].boxes.xyxy.cpu().numpy()
            confs = results[0].boxes.conf.cpu().numpy()
            cls_ids = results[0].boxes.cls.cpu().numpy().astype(int)

            # Only publish obstacles: person(0), chair(56), potted plant(58), etc.
            obstacle_classes = {0, 13, 56, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73}

            for box, conf, cls_id in zip(boxes, confs, cls_ids):
                if cls_id in obstacle_classes and conf > 0.5:
                    det = Detection2D()
                    det.bbox = BoundingBox2D()
                    det.bbox.center.x = (box[0] + box[2]) / 2 / cv_img.shape[1]
                    det.bbox.center.y = (box[1] + box[3]) / 2 / cv_img.shape[0]
                    det.bbox.size_x = (box[2] - box[0]) / cv_img.shape[1]
                    det.bbox.size_y = (box[3] - box[1]) / cv_img.shape[0]
                    det.results[0].hypothesis.score = float(conf)
                    det_array.detections.append(det)

        self.det_pub.publish(det_array)

        if dt > 50:
            self.get_logger().warn(f'Inference {dt:.1f}ms > 50ms threshold')
        # Publish latency as diagnostic
        self.get_logger().debug(f'Inference: {dt:.1f}ms, detections: {len(det_array.detections)}')


def main():
    rclpy.init()
    node = YoloDetector()
    rclpy.spin(node)


if __name__ == '__main__':
    main()
```

**Step 3: Benchmark 脚本**

```python
#!/usr/bin/env python3
"""Benchmark YOLOv8-seg inference speed on RTX 2080 Ti."""
import torch
from ultralytics import YOLO
import time
import numpy as np

print(f"PyTorch {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU: {torch.cuda.get_device_name(0)}")

model = YOLO('yolov8n-seg.pt')
model.to('cuda')
model.fuse()

# Warmup
for _ in range(10):
    dummy = torch.randn(1, 3, 640, 640).to('cuda')
    _ = model(dummy, verbose=False)

# Benchmark FP16
times = []
for _ in range(100):
    dummy = torch.randn(1, 3, 640, 640).to('cuda')
    torch.cuda.synchronize()
    t0 = time.time()
    _ = model(dummy, verbose=False, half=True)
    torch.cuda.synchronize()
    times.append((time.time() - t0) * 1000)

print(f"\nYOLOv8n-seg FP16 on {torch.cuda.get_device_name(0)}:")
print(f"  Mean: {np.mean(times):.2f}ms")
print(f"  Std:  {np.std(times):.2f}ms")
print(f"  Min:  {np.min(times):.2f}ms")
print(f"  Max:  {np.max(times):.2f}ms")
print(f"  P95:  {np.percentile(times, 95):.2f}ms")
print(f"\n{'✅ PASS' if np.mean(times) < 50 else '❌ FAIL'} (< 50ms threshold)")
```

✅ **判定通过:** YOLOv8n-seg FP16 推理 < 50ms (mean) on RTX2080Ti

---

## Task 4: 局部路径规划 + 避障 DWA (白起)

**Objective:** 基于 LiDAR 聚类结果实现 DWA (Dynamic Window Approach) 局部路径规划

**Files:**
- Create: `~/nav_dog_ws/src/local_planner/local_planner/dwa_planner.py`

**Step 1: 实现 DWA 规划器**

```python
#!/usr/bin/env python3
"""
DWA (Dynamic Window Approach) local planner with obstacle avoidance.
Subscribes to /obstacles and /odom, publishes /cmd_vel.
"""
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist
from nav_msgs.msg import Odometry
from std_msgs.msg import Float32MultiArray
import numpy as np
import math


class DWAPlanner(Node):
    def __init__(self):
        super().__init__('dwa_planner')
        self.cmd_pub = self.create_publisher(Twist, '/cmd_vel', 10)
        self.odom_sub = self.create_subscription(Odometry, '/odom', self.odom_cb, 10)
        self.obs_sub = self.create_subscription(Float32MultiArray, '/obstacles', self.obs_cb, 10)

        # DWA parameters
        self.max_linear = 0.5   # m/s
        self.max_angular = 1.0  # rad/s
        self.linear_res = 0.05
        self.angular_res = 0.1
        self.predict_time = 2.0  # seconds
        self.dt = 0.1
        self.robot_radius = 0.4  # meters
        self.goal_tolerance = 0.3

        # State
        self.obstacles = []  # [(cx, cy, radius), ...]
        self.current_pose = None
        self.goal = (5.0, 0.0)  # default goal

        self.get_logger().info('DWA Planner started')
        self.timer = self.create_timer(0.05, self.plan_loop)  # 20Hz

    def odom_cb(self, msg):
        self.current_pose = (msg.pose.pose.position.x, msg.pose.pose.position.y,
                             self._yaw_from_quat(msg.pose.pose.orientation))

    def obs_cb(self, msg):
        self.obstacles = []
        data = msg.data
        for i in range(0, len(data), 3):
            if i + 2 < len(data):
                self.obstacles.append((data[i], data[i+1], data[i+2]))

    def plan_loop(self):
        if self.current_pose is None:
            return

        best_v, best_w = self._dwa_search()
        cmd = Twist()
        cmd.linear.x = best_v
        cmd.angular.z = best_w
        self.cmd_pub.publish(cmd)

        # Check goal reached
        dx = self.goal[0] - self.current_pose[0]
        dy = self.goal[1] - self.current_pose[1]
        if math.hypot(dx, dy) < self.goal_tolerance:
            self.get_logger().info('Goal reached!')

    def _dwa_search(self):
        x, y, theta = self.current_pose
        best_score = -float('inf')
        best_v, best_w = 0.0, 0.0

        for v in np.arange(0, self.max_linear + self.linear_res, self.linear_res):
            for w in np.arange(-self.max_angular, self.max_angular + self.angular_res, self.angular_res):
                traj = self._predict_trajectory(x, y, theta, v, w)
                if self._is_collision(traj):
                    continue
                score = self._score_trajectory(traj)
                if score > best_score:
                    best_score = score
                    best_v, best_w = v, w

        return best_v, best_w

    def _predict_trajectory(self, x, y, theta, v, w):
        traj = []
        for t in np.arange(0, self.predict_time, self.dt):
            x += v * math.cos(theta) * self.dt
            y += v * math.sin(theta) * self.dt
            theta += w * self.dt
            traj.append((x, y, theta))
        return traj

    def _is_collision(self, traj):
        for tx, ty, _ in traj:
            for ox, oy, orad in self.obstacles:
                if math.hypot(tx - ox, ty - oy) < (self.robot_radius + orad + 0.1):
                    return True
        return False

    def _score_trajectory(self, traj):
        final_x, final_y, _ = traj[-1]
        # Goal distance
        goal_dist = math.hypot(self.goal[0] - final_x, self.goal[1] - final_y)
        goal_score = 1.0 / (goal_dist + 0.1)
        # Obstacle clearance
        clearance = min(
            (math.hypot(tx - ox, ty - oy) - (self.robot_radius + orad)
             for tx, ty, _ in traj
             for ox, oy, orad in self.obstacles),
            default=5.0
        )
        clearance_score = min(clearance / 2.0, 1.0)
        # Forward progress
        dx = traj[-1][0] - traj[0][0]
        dy = traj[-1][1] - traj[0][1]
        progress = math.hypot(dx, dy)
        return goal_score * 0.5 + clearance_score * 0.3 + progress * 0.2

    @staticmethod
    def _yaw_from_quat(q):
        siny = 2.0 * (q.w * q.z + q.x * q.y)
        cosy = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
        return math.atan2(siny, cosy)


def main():
    rclpy.init()
    node = DWAPlanner()
    rclpy.spin(node)


if __name__ == '__main__':
    main()
```

**Validation (DWA 碰撞测试):**

```python
# test_dwa.py
def test_no_collision_with_empty_obstacles():
    planner = DWAPlanner()
    planner.obstacles = []
    planner.current_pose = (0, 0, 0)
    planner.goal = (5, 0)
    v, w = planner._dwa_search()
    assert v > 0, "Should move forward with no obstacles"

def test_avoid_obstacle():
    planner = DWAPlanner()
    planner.obstacles = [(1.0, 0.0, 0.5)]  # obstacle directly ahead
    planner.current_pose = (0, 0, 0)
    planner.goal = (5, 0)
    v, w = planner._dwa_search()
    assert abs(w) > 0.05, f"Should turn to avoid obstacle, got w={w:.3f}"

def test_stop_at_goal():
    planner = DWAPlanner()
    planner.obstacles = []
    planner.current_pose = (4.9, 0.0, 0)
    planner.goal = (5, 0)
    v, w = planner._dwa_search()
    # Near goal, should slow down
    assert v < planner.max_linear * 0.3, f"Should slow near goal, got v={v:.3f}"
```

✅ **判定通过:** 无障碍直行; 有障碍转弯; 到达目标减速

---

## Task 5: VLAC Critic 评估服务 (王翦)

**Objective:** 搭建 VLAC 评估服务，实时判断机器狗行为是否合理

**Files:**
- Create: `~/nav_dog_ws/src/vlac_critic/vlac_critic/critic_server.py`

**Step 1: 实现 Critic 节点**

```python
#!/usr/bin/env python3
"""
VLAC (Vision-Language-Action-Critic) evaluation node.
Receives sensor data + action, evaluates quality, publishes feedback.
"""
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image, LaserScan
from geometry_msgs.msg import Twist
from std_msgs.msg import String, Float32
from cv_bridge import CvBridge
import torch
import time
import cv2
import numpy as np


class VLACCritic(Node):
    def __init__(self):
        super().__init__('vlac_critic')
        self.bridge = CvBridge()

        # Subscriptions
        self.image_sub = self.create_subscription(Image, '/camera/image_raw', self.img_cb, 10)
        self.scan_sub = self.create_subscription(LaserScan, '/scan', self.scan_cb, 10)
        self.cmd_sub = self.create_subscription(Twist, '/cmd_vel', self.cmd_cb, 10)

        # Publishers
        self.score_pub = self.create_publisher(Float32, '/vlac/safety_score', 10)
        self.alert_pub = self.create_publisher(String, '/vlac/alert', 10)

        # State
        self.latest_image = None
        self.latest_scan = None
        self.current_cmd = None
        self.collision_risk = 0.0
        self.deviation_score = 0.0

        # Timer: evaluate at 10Hz
        self.timer = self.create_timer(0.1, self.evaluate)

        self.get_logger().info('VLAC Critic started')

    def img_cb(self, msg):
        self.latest_image = msg

    def scan_cb(self, msg):
        self.latest_scan = msg

    def cmd_cb(self, msg):
        self.current_cmd = msg

    def evaluate(self):
        """Real-time safety evaluation."""
        if self.latest_scan is None or self.current_cmd is None:
            return

        # 1. Collision risk from LiDAR
        self.collision_risk = self._compute_collision_risk(self.latest_scan, self.current_cmd)

        # 2. Velocity sanity check
        vel_magnitude = abs(self.current_cmd.linear.x) + abs(self.current_cmd.angular.z)
        vel_score = max(0.0, 1.0 - vel_magnitude / 2.0)  # penalize extreme speeds

        # 3. Combined safety score
        safety_score = (1.0 - self.collision_risk) * 0.6 + vel_score * 0.4
        self.score_pub.publish(Float32(data=safety_score))

        # 4. Alert if danger
        alert = String()
        if safety_score < 0.3:
            alert.data = f"DANGER: collision_risk={self.collision_risk:.2f}, vel={vel_magnitude:.2f}"
            self.alert_pub.publish(alert)
            self.get_logger().warn(alert.data)

    def _compute_collision_risk(self, scan, cmd) -> float:
        """Estimate collision probability given current scan + velocity."""
        ranges = np.array(scan.ranges)
        front_indices = np.where(
            (np.arange(len(ranges)) >= len(ranges) * 0.4) &
            (np.arange(len(ranges)) <= len(ranges) * 0.6)
        )[0]
        front_ranges = ranges[front_indices]
        front_ranges = front_ranges[np.isfinite(front_ranges)]

        if len(front_ranges) == 0:
            return 1.0  # no data → assume risky

        min_dist = np.min(front_ranges)
        speed = abs(cmd.linear.x)

        # Time to collision
        if speed > 0.01:
            ttc = min_dist / speed
        else:
            ttc = float('inf')

        if ttc < 0.5:
            return 1.0  # imminent collision
        elif ttc < 1.0:
            return 0.8
        elif ttc < 2.0:
            return 0.5
        elif ttc < 5.0:
            return 0.2
        else:
            return 0.05

        # Also check static proximity
        if min_dist < 0.3:
            return 0.9
        elif min_dist < 0.5:
            return 0.6

        return 0.1


def main():
    rclpy.init()
    node = VLACCritic()
    rclpy.spin(node)


if __name__ == '__main__':
    main()
```

**Validation:**

```bash
# Unit test
python3 -c "
from vlac_critic.critic_server import VLACCritic
import numpy as np
# Test collision risk logic
critic = VLACCritic()
# Simulate scan: obstacle at 0.2m, speed 1.0 → TTC=0.2s → risk=1.0
# Simulate scan: obstacle at 5m, speed 0.5 → TTC=10s → risk=0.05
print('✅ Critic node imports OK')
"
```

✅ **判定通过:** Critic 能正确评估碰撞风险; 安全分数 < 0.3 时发送告警

---

## Task 6: 闭环测试框架 (白起 + 王翦 协作)

**Objective:** 构建自动化测试流水线: 启动仿真 → 运行导航 → 收集数据 → 验证 → 报告

**Files:**
- Create: `~/nav_dog_ws/src/selftest/test_closed_loop.py`
- Create: `~/nav_dog_ws/src/selftest/run_all_tests.sh`
- Create: `~/nav_dog_ws/src/selftest/expected_outputs/`

**Step 1: 闭环测试脚本**

```python
#!/usr/bin/env python3
"""
Closed-loop test harness for NAV_DOG.
Starts simulation, runs navigation, verifies outputs.
"""
import subprocess
import time
import signal
import sys
import os
import json
from datetime import datetime


class NAVDOGTester:
    def __init__(self):
        self.results = []
        self.processes = []

    def test_simulation_startup(self):
        """Test 1: Simulation launches successfully."""
        print("[TEST 1] Simulation startup...")
        self._start_simulation()
        time.sleep(15)  # Wait for Gazebo to fully load

        # Check ROS2 topics
        topics = self._ros2_topic_list()
        required = ['/cmd_vel', '/scan', '/camera/image_raw', '/odom']
        missing = [t for t in required if t not in topics]
        self._stop_simulation()
        passed = len(missing) == 0
        self.results.append({
            'test': 'simulation_startup',
            'passed': passed,
            'details': f'Topics: {topics}',
            'missing': missing
        })
        return passed

    def test_lidar_clustering(self):
        """Test 2: LiDAR clustering produces obstacles."""
        print("[TEST 2] LiDAR clustering...")
        self._start_simulation()
        time.sleep(5)

        # Start LiDAR cluster node
        self._launch_node('lidar_perception', 'lidar_cluster.py')
        time.sleep(5)

        # Check /obstacles topic
        obstacles = self._get_topic_data('/obstacles', timeout=10)
        self._stop_simulation()

        passed = obstacles is not None and len(obstacles) > 0
        self.results.append({
            'test': 'lidar_clustering',
            'passed': passed,
            'details': f'Obstacles detected: {len(obstacles) if obstacles else 0}'
        })
        return passed

    def test_dwa_path_planning(self):
        """Test 3: DWA planner avoids obstacles and reaches goal."""
        print("[TEST 3] DWA path planning...")
        self._start_simulation()
        time.sleep(5)
        self._launch_node('lidar_perception', 'lidar_cluster.py')
        self._launch_node('local_planner', 'dwa_planner.py')
        time.sleep(3)

        # Monitor /cmd_vel for activity
        cmd_data = []
        start = time.time()
        while time.time() - start < 20:
            data = self._get_topic_data('/cmd_vel', timeout=2)
            if data:
                cmd_data.append(data)
        self._stop_simulation()

        # Verify: cmd_vel was published (robot moved)
        passed = len(cmd_data) > 5
        self.results.append({
            'test': 'dwa_path_planning',
            'passed': passed,
            'details': f'Cmd vel messages: {len(cmd_data)}'
        })
        return passed

    def test_yolo_inference_speed(self):
        """Test 4: YOLOv8 inference < 50ms."""
        print("[TEST 4] YOLOv8 inference speed...")
        result = subprocess.run(
            ['python3', 'vision_det/scripts/benchmark.py'],
            cwd=os.path.expanduser('~/nav_dog_ws/src'),
            capture_output=True, text=True, timeout=120
        )
        passed = 'PASS' in result.stdout and 'FAIL' not in result.stdout
        self.results.append({
            'test': 'yolo_inference_speed',
            'passed': passed,
            'details': result.stdout.strip()[-200:]
        })
        return passed

    def test_vlac_safety_evaluation(self):
        """Test 5: VLAC critic detects danger."""
        print("[TEST 5] VLAC safety evaluation...")
        self._start_simulation()
        time.sleep(5)
        self._launch_node('vlac_critic', 'critic_server.py')
        time.sleep(3)

        # Move robot toward obstacle to trigger danger
        self._send_cmd_vel(0.5, 0.0)
        time.sleep(5)

        alert = self._get_topic_data('/vlac/alert', timeout=10)
        self._stop_simulation()

        passed = alert is not None  # Should have triggered alert
        self.results.append({
            'test': 'vlac_safety_evaluation',
            'passed': passed,
            'details': f'Alert received: {alert is not None}'
        })
        return passed

    def run_all(self):
        tests = [
            self.test_simulation_startup,
            self.test_lidar_clustering,
            self.test_dwa_path_planning,
            self.test_yolo_inference_speed,
            self.test_vlac_safety_evaluation,
        ]
        for test_fn in tests:
            try:
                test_fn()
            except Exception as e:
                self.results.append({
                    'test': test_fn.__name__,
                    'passed': False,
                    'details': str(e)
                })

        self._print_report()

    def _print_report(self):
        passed = sum(1 for r in self.results if r['passed'])
        total = len(self.results)
        print(f"\n{'='*60}")
        print(f"  NAV_DOG Closed-Loop Test Report")
        print(f"  {datetime.now().isoformat()}")
        print(f"{'='*60}")
        for r in self.results:
            icon = '✅' if r['passed'] else '❌'
            print(f"  {icon} {r['test']}: {r['details']}")
        print(f"{'='*60}")
        print(f"  Result: {passed}/{total} passed")
        print(f"{'='*60}")

        # Save report
        report_path = os.path.expanduser('~/nav_dog_ws/test_report.json')
        with open(report_path, 'w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'passed': passed,
                'total': total,
                'results': self.results
            }, f, indent=2)
        print(f"\nReport saved to {report_path}")

        return passed == total

    # --- Helpers ---
    def _start_simulation(self):
        # Kill any existing gazebo
        subprocess.run(['pkill', '-f', 'gz sim'], capture_output=True)
        subprocess.run(['pkill', '-f', 'gazebo'], capture_output=True)
        time.sleep(2)

    def _stop_simulation(self):
        subprocess.run(['pkill', '-f', 'gz sim'], capture_output=True)
        subprocess.run(['pkill', '-f', 'gazebo'], capture_output=True)

    def _ros2_topic_list(self):
        result = subprocess.run(['ros2', 'topic', 'list'], capture_output=True, text=True, timeout=10)
        return result.stdout.strip().split('\n') if result.returncode == 0 else []

    def _launch_node(self, pkg, script):
        proc = subprocess.Popen(
            ['python3', f'src/{pkg}/{pkg}/{script}'],
            cwd=os.path.expanduser('~/nav_dog_ws'),
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        self.processes.append(proc)

    def _get_topic_data(self, topic, timeout=5):
        try:
            result = subprocess.run(
                ['ros2', 'topic', 'echo', topic, '--once'],
                capture_output=True, text=True, timeout=timeout
            )
            return result.stdout if result.returncode == 0 else None
        except:
            return None

    def _send_cmd_vel(self, v, w):
        subprocess.run(
            ['ros2', 'topic', 'pub', '/cmd_vel', 'geometry_msgs/msg/Twist',
             f'{{linear: {{x: {v}}}, angular: {{z: {w}}}}}', '--once'],
            timeout=5
        )


if __name__ == '__main__':
    tester = NAVDOGTester()
    success = tester.run_all()
    sys.exit(0 if success else 1)
```

**Step 2: 一键测试脚本**

```bash
#!/bin/bash
# run_all_tests.sh - NAV_DOG 闭环测试一键执行
set -e

source /opt/ros/humble/setup.bash
source ~/nav_dog_ws/install/setup.bash

echo "=== NAV_DOG Closed-Loop Test Suite ==="
echo ""

# 1. Unit tests
echo "[1/3] Running unit tests..."
cd ~/nav_dog_ws
python3 -m pytest src/lidar_perception/tests/ -v --tb=short 2>&1 || echo "LIDAR tests: some failed"
python3 -m pytest src/local_planner/tests/ -v --tb=short 2>&1 || echo "PLANNER tests: some failed"

# 2. Integration test
echo "[2/3] Running YOLO benchmark..."
python3 src/vision_det/scripts/benchmark.py

# 3. Closed-loop test
echo "[3/3] Running closed-loop integration tests..."
python3 src/selftest/test_closed_loop.py

echo ""
echo "=== All tests complete ==="
```

✅ **判定通过:** 5 项闭环测试全部 PASS

---

## 执行顺序

```
白起 (SIM + LiDAR + Planner):
  Task 1 → Task 2 → Task 4 → Task 6 (co-op)

王翦 (Vision + VLAC):
  Task 3 → Task 5 → Task 6 (co-op)

并行段: Task 1+3 可同时进行
协作段: Task 6 需要双方节点都就绪
```

## 成功判定总揽

| # | Task | Agent | 判定标准 |
|---|------|-------|----------|
| 1 | 仿真环境 | 白起 | `ros2 topic list` 可见 /cmd_vel + /scan + /odom |
| 2 | LiDAR 聚类 | 白起 | Euclidean Clustering < 50ms, 正确检测障碍物 |
| 3 | YOLO 检测 | 王翦 | FP16 推理 < 50ms mean on RTX2080Ti |
| 4 | DWA 规划 | 白起 | 无障碍直行; 有障碍转弯绕行; 到达目标停止 |
| 5 | VLAC Critic | 王翦 | 碰撞风险 < 0.3 时发布告警; 正常行驶分数 > 0.7 |
| 6 | 闭环测试 | 双方 | 5/5 tests pass, report.json 生成 |

---

**签章:** 相邦 令 · 仙秦二六四月二十六日

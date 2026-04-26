# Marathongo — vo_navigation 模块设计提取

> 提取自 `tangent_arc_navigation/src/vo_navigation/`
> 目标：为 Unitree A2 四足导航系统的局部避障/路径跟踪模块提供可直接复用的设计参考

---

## 1. 模块总览

| 属性 | 内容 |
|------|------|
| 包名 | `vo_navigation` |
| 节点数 | 3 个 ROS1 C++ 节点 |
| 核心算法 | Tangent Arc 避障 + 子目标前视跟踪 + 速度弧采样碰撞预测 |
| 控制频率 | 20Hz (vo_node), 50Hz (subgoal_selector) |
| 输入 | 里程计、障碍物、全局路径、车道边界 |
| 输出 | `speed_controller::SpeedCommand` (线速度 + 角速度) |

---

## 2. 节点架构与职责

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│ lidar_obstacle_node │────→│    vo_node (主控)    │←────│ subgoal_selector_node│
│   障碍物格式转换     │     │   避障+速度指令生成   │     │   子目标选取         │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
         ↑                            ↑                          ↑
    /obstacles_raw               /odometry_body            /central/smoothed_path
    (costmap_converter)          /obstacles               /left/smoothed_path
                                 /vo/subgoal              /right/smoothed_path
                                 /vo/state (状态机)
```

### 2.1 lidar_obstacle_node
- **功能**：将 `costmap_converter::ObstacleArrayMsg` 转换为本包自定义的 `vo_navigation::ObstacleArray`
- **TF 处理**：自动将障碍物坐标转换到 `target_frame` (默认 `body`)
- **参数**：`default_obstacle_radius`, `max_obstacles`
- **对 A2 的启示**：A2 若使用 Livox/雷视融合方案，可用类似节点将点云聚类结果转为统一障碍物格式

### 2.2 subgoal_selector_node
- **功能**：沿全局路径选取前视子目标 (subgoal)
- **核心机制**：
  - 以最近路径点为锚点，沿前进方向累积 `lookahead_dist` 选取子目标
  - **自适应前视**：基于前方路径曲率动态调整 lookahead（曲率大→距离短，曲率小→距离长）
  - **终点锁定**：连续 N 帧距离终点 < 阈值后锁定，防止 SLAM 抖动导致反复横跳
  - **重捕获**：若最近点超出 `nearest_reacquire_dist`，全局重搜索
- **参数要点**：
  - `lookahead_dist: 4.0`, `max_lookahead: 8.0`, `min_lookahead: 1.0`
  - `refresh_dist: 1.2` — 接近当前子目标时提前前进
  - `end_confirmation_count: 10` — 50Hz 下约 0.2s 稳定确认
- **对 A2 的启示**：四足机器人步态切换需要提前量，自适应前视对崎岖地形尤其实用；可直接复用该子目标选取逻辑

### 2.3 vo_node（核心避障节点）

#### 输入话题
| 话题 | 类型 | 说明 |
|------|------|------|
| `/odometry_body` | `nav_msgs/Odometry` | 机器人位姿与速度 |
| `/obstacles` | `vo_navigation/ObstacleArray` | 障碍物（位置/速度/半径/多边形） |
| `/vo/subgoal` | `geometry_msgs/PointStamped` | 子目标点 |
| `/left/smoothed_path` | `nav_msgs/Path` | 左车道边界 |
| `/right/smoothed_path` | `nav_msgs/Path` | 右车道边界 |
| `/vo/state` | `std_msgs/Int32` | 外部状态机控制 |

#### 输出话题
| 话题 | 类型 | 说明 |
|------|------|------|
| `/speed_command` | `speed_controller::SpeedCommand` | 线速度 + 角速度指令 |
| `/vo/optimal_direction_marker` | `visualization_msgs/Marker` | RViz 最优方向可视化 |

#### 核心算法流程

```
1. 定时器回调 (20Hz)
   ├── 读取里程计 → robot_pos, robot_yaw, robot_vel
   ├── 读取障碍物列表
   ├── 读取子目标
   ├── 计算期望朝向 desired_heading = atan2(subgoal - robot_pos)
   │
   ├── 2. Tangent Arc 避障计算
   │   ├── 对左/右两侧分别计算切线弧
   │   ├── 模拟圆弧轨迹 (arc_sim_steps=80)
   │   ├── 检测与障碍物的碰撞（含半径膨胀 inflation）
   │   ├── 选择最近的碰撞点作为 hit_point
   │   └── 若无碰撞 → 无障碍直走
   │
   ├── 3. 最优方向选择（带侧向迟滞）
   │   ├── side_switch_counter_thresh: 连续 N 帧才允许换侧
   │   ├── 防止左右圆弧频繁切换导致的震荡
   │   └── 输出 optimal_heading
   │
   ├── 4. 速度弧采样
   │   ├── 在 optimal_heading 附近采样 speed_arc_sample_count 条弧
   │   ├── 每条弧模拟 speed_arc_sim_steps 步
   │   ├── 评估安全余量 speed_arc_safety_clearance
   │   └── 选择最高安全速度
   │
   ├── 5. 速度平滑
   │   ├── LPF 低通滤波 (alpha=0.20)
   │   ├── 加速度限制：上升 ≤ 1.0 m/s², 下降 ≤ 3.0 m/s²
   │   └── 输出 target_linear_x
   │
   ├── 6. 状态机检查
   │   ├── STATE_NORMAL: 正常执行
   │   ├── STATE_ODOM_UNHEALTHY: 停止
   │   └── STATE_RECOVER_OUTSIDE_LANES: 触发恢复行为
   │
   ├── 7. 恢复规划（Recovery）
   │   ├── 体坐标系下建立 occupancy grid (分辨率 0.3m, 半径 12m)
   │   ├── A* 搜索逃生路径
   │   ├── 触发条件：卡住计数 > 200 帧 且 速度 < 0.35 m/s
   │   └── 超时 30s 后放弃
   │
   └── 8. 发布 SpeedCommand
```

#### 关键数据结构

```cpp
struct ObstacleState {
    Vec2 pos;
    Vec2 vel;      // 动态障碍物速度预测
    double radius;
    int id;
    std::vector<Vec2> polygon;  // 多边形边界（可选）
};

struct SideTangentResult {
    bool has_hit;
    double heading;      // 切线方向
    Vec2 hit_point;      // 碰撞点
    int side_sign;       // +1 左, -1 右
    double hit_omega;    // 命中时角速度
};
```

#### 速度-偏航率限制 CSV
- 文件：`config/vo_angular_limits.csv`
- 格式：速度区间 → 最大偏航率
- 作用：高速时限制转弯角速度，防止侧翻/失控
- **A2 适配**：需根据四足运动学重新标定（高速小跑 vs 低速爬行）

---

## 3. 状态机设计 (`vo_state.h`)

```cpp
enum VOState {
    STATE_NORMAL = 0,              // 正常导航
    STATE_ODOM_UNHEALTHY = 1,      // 里程计异常，停止运动
    STATE_RECOVER_OUTSIDE_LANES = 2 // 偏离车道，触发恢复
};
```

- 状态通过 `/vo/state` 话题外部控制
- 超时机制：0.5s 未收到状态消息自动恢复为 NORMAL
- **A2 扩展建议**：可增加 `STATE_TERRAIN_UNSTABLE`（地形不稳，降速/切换步态）

---

## 4. 核心参数清单（A2 适配参考）

| 参数 | Marathongo 值 | A2 建议值 | 说明 |
|------|--------------|-----------|------|
| `robot_radius` | 0.4 m | 0.35 m | A2 机身更紧凑 |
| `max_linear_vel` | 3.5 m/s | 1.5-2.0 m/s | 四足稳定运动速度上限 |
| `control_period_sec` | 0.05s | 0.05s | 20Hz 控制，可保持 |
| `avoidance_range_time_sec` | 3.5s | 2.0s | A2 速度慢，预测时距缩短 |
| `speed_arc_sample_count` | 20 | 14-16 | 降低计算量（ARM 平台） |
| `speed_arc_sim_steps` | 48 | 36 | 同上 |
| `speed_rise_limit_mps2` | 1.0 | 0.5 | 四足加速更保守 |
| `speed_fall_limit_mps2` | 3.0 | 2.0 | 紧急制动上限 |
| `collision_slope_deg` | 18° | 25° | 四足越障能力更强 |
| `goal_stop_distance` | 1.0 m | 0.5 m | A2 定位精度更高可更靠近 |
| `recovery_v` | 0.5 m/s | 0.3 m/s | 恢复模式低速 |
| `stuck_threshold` | 200 frames | 150 frames | 20Hz 下 7.5s |
| `v_stuck_threshold` | 0.35 m/s | 0.2 m/s | 四足易原地踏步 |

---

## 5. A2 移植策略

### 5.1 可直接复用的组件
1. **subgoal_selector_node** — 纯几何计算，与机器人形态无关，完整复用
2. **Tangent Arc 避障核心逻辑** — 仅依赖圆盘机器人模型，四足等效为圆形 footprint
3. **速度平滑与限幅** — 逻辑通用，改参数即可
4. **状态机框架** — 可扩展新状态
5. **恢复规划（A* + occupancy grid）** — 体坐标系网格与底盘形态无关

### 5.2 需要改造的组件
1. **指令输出接口**
   - Marathongo：发布 `speed_controller::SpeedCommand` (v, ω)
   - A2：需通过 `unitree_sdk2` 发送 `HighCmd`（含 gaitType, speedLevel, footRaiseHeight, yaw/roll/pitch 等）
   - **方案**：在 vo_node 后增加 `a2_cmd_adapter_node`，将 (v, ω) 映射为 A2 的 `HighCmd`

2. **障碍物输入**
   - Marathongo：依赖 `costmap_converter` 从 costmap 提取
   - A2：LiDAR 点云需自行聚类，或 Livox 直接输出 obstacle 信息
   - **方案**：保留 `lidar_obstacle_node` 接口，替换输入源为 A2 的感知管线

3. **里程计输入**
   - Marathongo：`/odometry_body` (轮式里程计)
   - A2：需融合 Leg Odometry + IMU + GNSS，输出相同 `nav_msgs/Odometry` 格式

4. **车道边界**
   - Marathongo：用于赛道左右边界约束
   - A2：可改为地形通行性边界或虚拟走廊

### 5.3 建议的 A2 节点拓扑

```
┌─────────────────┐
│  Livox/雷达聚类  │
└────────┬────────┘
         ↓ /obstacles_raw
┌─────────────────┐     ┌─────────────────┐
│lidar_obstacle_  │────→│                 │
│    node (改造)   │     │    vo_node      │←──── /odometry (融合后)
└─────────────────┘     │   (核心复用)     │←──── /vo/subgoal
                        │                 │←──── /corridor_bounds
                        └────────┬────────┘
                                 ↓ /speed_command (v, ω)
                        ┌─────────────────┐
                        │ a2_cmd_adapter  │
                        │  (v,ω)→HighCmd  │
                        └────────┬────────┘
                                 ↓
                        ┌─────────────────┐
                        │  unitree_sdk2   │
                        │   (UDP 发 A2)   │
                        └─────────────────┘
```

---

## 6. 关键代码文件清单

| 文件 | 行数 | 说明 |
|------|------|------|
| `src/vo_node.cpp` | ~2457 | 核心避障算法（Tangent Arc + 速度采样 + 状态机） |
| `src/subgoal_selector_node.cpp` | ~348 | 子目标选取（自适应前视 + 终点检测） |
| `src/lidar_obstacle_node.cpp` | ~207 | 障碍物格式转换 + TF |
| `include/vo_navigation/vo_state.h` | 14 | 状态机枚举定义 |
| `msg/Obstacle.msg` | 4 | 障碍物消息格式 |
| `msg/ObstacleArray.msg` | 2 | 障碍物数组 |

---

## 7. 风险与注意事项

1. **计算负载**：vo_node 在 20Hz 下做 80 步弧模拟 × 20 条速度采样弧 = 1600 次碰撞检测/帧。ARM 平台（如 Jetson）可能需要降采样。
2. **动态障碍物**：`vo_node` 订阅障碍物速度字段，但对高速动态障碍物的预测较简单（线性外推）。A2 在室外需更谨慎。
3. **无全局规划耦合**：vo_navigation 是纯局部模块，依赖外部提供 `/central/smoothed_path`。A2 需配套全局规划器。
4. **ROS1 依赖**：当前为 ROS1 (melodic/noetic)。A2 若用 ROS2，需做 message 类型和节点接口迁移。

---

*提取时间：2026-04-22 22:46*
*来源：~/projects/marathongo/tangent_arc_navigation/src/vo_navigation/*

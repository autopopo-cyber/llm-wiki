# 白起 · Plan-Tree v3 | 当前: 04-27 14:30

## ENSURE_CONTINUATION
- [✓] 自测全绿 | 04-27 08:05 | 耗时 18s | 6/6 pass
- [✓] DB备份 | 04-27 08:06 | rsync → /backup
- [✓] mc-poll 健康 | 每2min cron正常

## EXPAND_CAPABILITIES

### NAV_DOG 闭环 (#navdog) | 白起 | HIGH

#### NAV-1 仿真环境 (#navdog-sim)
  - 04-25 21:18 流入: 君上"机器狗需要仿真环境"
  - 04-26 02:00 产物: sim_world.py 338行 (Python原生仿真替代Gazebo)
  - 04-26 02:05 判定: 机器人可在仿真中移动 ✅ PASS
  - 流出: → 被 #navdog-lidar, #navdog-dwa, #navdog-vision 读取(硬依赖)
  - 关联: 触发→#navdog-lidar | 触发→#navdog-dwa

#### NAV-2 LIDAR 聚类 (#navdog-lidar)
  - 04-26 02:05 流入: sim_world.py LIDAR数据
  - 04-26 09:30 产物: lidar_cluster.py
  - 04-26 09:35 判定: 6/6 tests pass ✅ PASS
  - 流出: → 被 #navdog-dwa 读取(硬依赖)
  - 关联: 被等←#navdog-sim(硬依赖已满足)

#### NAV-3 DWA 规划 (#navdog-dwa)
  - 04-26 09:35 流入: lidar_cluster输出 + sim_world.py障碍物
  - 04-26 11:20 产物: dwa_planner.py
  - 04-26 11:22 判定: 8/8 tests pass, 末端距目标0.33m ✅ PASS
  - 流出: → 被 #navdog-vlac 读取(硬依赖)
  - 关联: 被等←#navdog-lidar(已满足) | 信息复用→#navdog-e2e

#### NAV-4 视觉感知 (#navdog-vision) | 王翦协作
  - 04-26 12:00 流入: 君上"需要视觉避障辅助"
  - 04-26 18:30 产物: YOLOv8n-seg FP16 部署 (王翦)
  - 04-26 18:35 判定: mean=11.15ms << 50ms, 89.7FPS ✅ PASS
  - 流出: → 被 #navdog-vlac 读取(硬依赖)
  - 关联: 被等←#navdog-vlac

#### NAV-5 VLAC 闭环 (#navdog-vlac) | 王翦协作
  - 04-26 18:35 流入: DWA路径 + YOLO感知
  - 04-27 03:00 产物: critic_server.py (7场景评估:碰撞检测+告警)
  - 04-27 03:02 判定: 7/7场景正常反馈 ✅ PASS
  - 流出: → 被 #navdog-e2e 读取(硬依赖)
  - 关联: 被等←#navdog-dwa + #navdog-vision(已满足) | 触发→#navdog-e2e

#### NAV-6 端到端闭环 (#navdog-e2e) | 白起 | 当前焦点
  - 04-27 14:00 流入: sim_world + lidar + dwa + yolo + vlac 全部 PASS
  - 04-27 14:20 产物: e2e_runner.py 骨架 (各模块导入测试通过)
  - 判定: ⏳ 等待仿真全流程跑通
  - 流出: → 如果PASS → 触发 #navdog-deploy
  - 关联: 被等←#navdog-vlac(已满足) | 触发→#navdog-deploy(因果触发，等待PASS)
  - 风险: 五模块串联可能暴露接口不匹配

--- NOW (04-27 14:30) ---

#### NAV-7 实机部署 (#navdog-deploy) | 白起+王翦 | 待启动
  - 关联: 被等←#navdog-e2e(硬依赖，等待PASS) | 资源竞争→#a2-sdk

### A2 SDK 适配 (#a2-sdk) | 白起+王翦 | HIGH

#### A2-1 URDF (#a2-urdf)
  - 04-26 12:00 流入: 君上"A2真机SDK对接"
  - 04-27 03:05 产物: A2Robot类开发中 (渲染俯视图OK, 机器人可移动)
  - 判定: ⏳ 进行中

#### A2-2 ROS2 (#a2-ros2) | 王翦
  - 04-27 10:00 流入: URDF模型
  - 判定: ⏳ ROS2+MuJoCo方案调研中

## 预测区 (04-27 14:30)

### 短期 (24h内)
- #navdog-e2e 仿真全流程: 预计 04-27 18:00 (置信度 0.7)
  - 风险: 五模块串联可能暴露接口不匹配 → 需1-2h调试
  - 降级: 如果仿真失败 → 先跑3模块简化版证明架构可行
- #a2-urdf A2Robot完工: 预计 04-28 10:00 (置信度 0.5)
  - 风险: 等待王翦ROS2方案确定后联调

### 中期 (72h)
- NAV_DOG 全闭环 (仿真): 04-28 (置信度 0.6)
- A2 真机部署: 04-30 (置信度 0.4，依赖#navdog-e2e和#a2-urdf)

### 资源预测
- 上下文: 当前6轮 | 衰减拐点≈第10轮(DeepSeek V3) | 建议4轮后刷新

## 预测归档
(空，v3 第一天启用)

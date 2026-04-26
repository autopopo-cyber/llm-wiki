# Isaac Gym 深度相机配置（extreme-parkour 参考实现）

**Date**: 2026-04-26
**Source**: https://github.com/chengxuxin/extreme-parkour (CMU, 2023)
**Paper**: https://arxiv.org/abs/2309.14341
**Relevance**: A2 仿真中挂载深度相机的最直接参考——在 Isaac Gym 里给四足机器人配了前置深度相机，GPU tensor 直出，无需中间拷贝。

## 核心流水线（5 步，全 GPU）

```
1. gym.create_camera_sensor(env, CameraProperties(enable_tensors=True))
2. gym.attach_camera_to_body(cam, env, root_body, local_transform, FOLLOW_TRANSFORM)
3. gym.render_all_camera_sensors(sim)           # 每 N 步渲染一次
4. gym.get_camera_image_gpu_tensor(sim, env, cam, IMAGE_DEPTH)
5. gymtorch.wrap_tensor() → crop → resize → normalize → buffer
```

## 关键参数

| 参数 | 值 | 对应代码位置 |
|------|-----|-------------|
| 相机位置 | [0.27, 0, 0.03] (机身前方) | `legged_robot_config.py:95` |
| 原始分辨率 | 106×60 | `legged_robot_config.py:100` |
| 裁剪后分辨率 | 87×58 | `legged_robot_config.py:101` |
| 裁剪方式 | 左右各 4px, 下方 2px | `legged_robot.py:177` |
| 水平 FOV | 87° | `legged_robot_config.py:102` |
| 深度范围 | 0~2m (near=0, far=2) | `legged_robot_config.py:105-106` |
| 更新频率 | 每 5 步 (10Hz @50Hz) | `legged_robot_config.py:98` |
| Buffer 长度 | 2 帧 | `legged_robot_config.py:103` |
| enable_tensors | True (GPU 直出) | `legged_robot.py:873` |
| FOLLOW_TRANSFORM | 跟随身体运动 | `legged_robot.py:889` |

## 深度归一化

Isaac Gym 深度值为负（-Z 轴）。归一化公式：

```python
def normalize_depth_image(depth_image):
    depth_image = depth_image * -1  # 翻转符号
    depth_image = (depth_image - near_clip) / (far_clip - near_clip) - 0.5
    return depth_image  # 范围 [-0.5, 0.5]
```

## 关键 API 调用

```python
# 1. 创建相机
camera_props = gymapi.CameraProperties()
camera_props.width = 106
camera_props.height = 60
camera_props.enable_tensors = True  # ← GPU tensor 访问
camera_props.horizontal_fov = 87
cam_handle = gym.create_camera_sensor(env, camera_props)

# 2. 挂载到机身
local_transform = gymapi.Transform()
local_transform.p = gymapi.Vec3(0.27, 0, 0.03)
root_handle = gym.get_actor_root_rigid_body_handle(env, actor)
gym.attach_camera_to_body(cam_handle, env, root_handle, local_transform, gymapi.FOLLOW_TRANSFORM)

# 3-4. 渲染并获取
gym.step_graphics(sim)  # headless 模式必须
gym.render_all_camera_sensors(sim)
gym.start_access_image_tensors(sim)
depth_tensor = gym.get_camera_image_gpu_tensor(sim, env, cam_handle, gymapi.IMAGE_DEPTH)
depth_image = gymtorch.wrap_tensor(depth_tensor)
gym.end_access_image_tensors(sim)
```

## 训练策略：两阶段蒸馏

| 阶段 | 输入 | 说明 |
|------|------|------|
| Stage 1 (教师) | 特权 scandots (真值高度图) | 8-10h on 3090 |
| Stage 2 (学生) | 深度相机 + 本体感知 | `--use_camera`, 5-10h |

学生策略用深度图替代 scandots，输出动作空间不变——导航逻辑可复用。

## 移植到 A2 需要改的

1. **URDF** — 替换 A1 → A2 (`ros-claw/unitree-mujoco-mcp` 已提供)
2. **相机位姿** — 根据 A2 机身尺寸调整 `position = [x, 0, z]`
3. **本体感知维度** — 确认 A2 DOF 数 (12, 和 A1 一致)

相机管线本身是 Isaac Gym 通用 API，与机器人型号无关。

## 相关文件

- `~/repos/extreme-parkour/legged_gym/legged_gym/envs/base/legged_robot.py` — 核心实现
  - L867: `attach_camera()`
  - L179: `update_depth_buffer()`
  - L161: `normalize_depth_image()`
- `~/repos/extreme-parkour/legged_gym/legged_gym/envs/base/legged_robot_config.py` — 参数配置
  - L89: `class depth`

## 注意

- 必须用 **PhysX** 引擎 (`gymapi.SIM_PHYSX`)，不支持 Flex
- `enable_tensors=True` 是性能关键——避免 GPU→CPU 拷贝
- headless 模式需显式调用 `gym.step_graphics(sim)` 才能渲染相机

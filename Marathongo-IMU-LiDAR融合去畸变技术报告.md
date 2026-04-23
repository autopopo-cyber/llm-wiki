# Marathongo (GLIO Mapping) IMU-LiDAR 融合去畸变技术细节报告

---

## 1. ESEKF 状态向量定义和误差状态传播方程

### 1.1 状态向量定义 (`use-ikfom.hpp`)

```cpp
MTK_BUILD_MANIFOLD(state_ikfom,
((vect3, pos))            // [0-2]   位置 (世界系下, 3维)
((SO3, rot))              // [3-5]   旋转 (IMU到世界, SO3流形, 3维误差态)
((SO3, offset_R_L_I))     // [6-8]   LiDAR到IMU旋转外参 (SO3流形, 3维误差态)
((vect3, offset_T_L_I))   // [9-11]  LiDAR到IMU平移外参 (3维)
((vect3, vel))            // [12-14] 速度 (世界系下, 3维)
((vect3, bg))             // [15-17] 陀螺仪偏差 (3维)
((vect3, ba))             // [18-20] 加速度计偏差 (3维)
((S2, grav))              // [21-22] 重力方向 (S2流形, 2维误差态)
);
```

**关键维度统计：**
- 状态流形维度 (DIM) = 24 (3+4+4+3+3+3+3+3+1 = 不含四元数w, 实际流形构建为24维平铺)
- 误差状态自由度 (DOF) = 23 (3+3+3+3+3+3+3+2)
- 过程噪声维度 = 12 (ng:3 + na:3 + nbg:3 + nba:3)

**S2流形用于重力表示：**
```cpp
typedef MTK::S2<double, 98090, 10000, 1> S2;  // S2流形，参数化2维误差态
```
重力被约束在S2球面上（方向约束，幅值固定为9.81 m/s²），仅用2维切空间表示误差态，避免过参数化。

### 1.2 连续时间过程模型 (`get_f`)

```cpp
inline Eigen::Matrix<double, 24, 1> get_f(state_ikfom &s, const input_ikfom &in)
{
    Eigen::Matrix<double, 24, 1> res = Eigen::Matrix<double, 24, 1>::Zero();
    vect3 omega;
    in.gyro.boxminus(omega, s.bg);       // ω = gyro - bg (去偏差角速度)
    vect3 a_inertial = s.rot * (in.acc - s.ba);  // R * (acc - ba) (惯性系加速度)
    for(int i = 0; i < 3; i++) {
        res(i) = s.vel[i];               // ṗ = v
        res(i + 3) = omega[i];           // Ṙ = ω (SO3右乘)
        res(i + 12) = a_inertial[i] + s.grav[i];  // v̇ = R(a-ba) + g
    }
    return res;
}
```

**数学表达：**
- ṗ = v
- Ṙ = R · [ω]×  (其中 ω = gyro_meas - bg)
- v̇ = R · (a_meas - ba) + g
- ḃg = 0 (随机游走)
- ḃa = 0 (随机游走)

### 1.3 误差状态雅可比矩阵 (`df_dx`)

```cpp
inline Eigen::Matrix<double, 24, 23> df_dx(state_ikfom &s, const input_ikfom &in)
{
    Eigen::Matrix<double, 24, 23> cov = Eigen::Matrix<double, 24, 23>::Zero();
    cov.template block<3, 3>(0, 12) = Eigen::Matrix3d::Identity();     // ∂ṗ/∂v = I
    cov.template block<3, 3>(12, 3) = -s.rot.toRotationMatrix() * MTK::hat(acc_); // ∂v̇/∂θ = -R·[a]×
    cov.template block<3, 3>(12, 18) = -s.rot.toRotationMatrix();     // ∂v̇/∂ba = -R
    cov.template block<3, 2>(12, 21) = grav_matrix;                   // ∂v̇/∂g (S2流形)
    cov.template block<3, 3>(3, 15) = -Eigen::Matrix3d::Identity();   // ∂ω̇/∂bg = -I
    return cov;
}
```

### 1.4 噪声雅可比矩阵 (`df_dw`)

```cpp
inline Eigen::Matrix<double, 24, 12> df_dw(state_ikfom &s, const input_ikfom &in)
{
    Eigen::Matrix<double, 24, 12> cov = Eigen::Matrix<double, 24, 12>::Zero();
    cov.template block<3, 3>(12, 3) = -s.rot.toRotationMatrix();  // ∂v̇/∂na = -R
    cov.template block<3, 3>(3, 0) = -Eigen::Matrix3d::Identity(); // ∂ω̇/∂ng = -I
    cov.template block<3, 3>(15, 6) = Eigen::Matrix3d::Identity(); // ∂bġ/∂nbg = I
    cov.template block<3, 3>(18, 9) = Eigen::Matrix3d::Identity(); // ∂bȧ/∂nba = I
    return cov;
}
```

### 1.5 过程噪声协方差初始化

```cpp
inline MTK::get_cov<process_noise_ikfom>::type process_noise_cov()
{
    MTK::get_cov<process_noise_ikfom>::type cov = ...::Zero();
    MTK::setDiagonal<process_noise_ikfom, vect3, 0>(cov, &process_noise_ikfom::ng, 0.0001);   // 陀螺噪声
    MTK::setDiagonal<process_noise_ikfom, vect3, 3>(cov, &process_noise_ikfom::na, 0.0001);   // 加计噪声
    MTK::setDiagonal<process_noise_ikfom, vect3, 6>(cov, &process_noise_ikfom::nbg, 0.00001);  // 陀螺偏差噪声
    MTK::setDiagonal<process_noise_ikfom, vect3, 9>(cov, &process_noise_ikfom::nba, 0.00001);  // 加计偏差噪声
    return cov;
}
```

**运行时Q矩阵更新** (`imu_processing.cpp:334-337`)：
```cpp
Q.block<3, 3>(0, 0).diagonal() = cov_gyr;       // 陀螺仪噪声 (默认0.1)
Q.block<3, 3>(3, 3).diagonal() = cov_acc;       // 加速度计噪声 (默认0.1)
Q.block<3, 3>(6, 6).diagonal() = cov_bias_gyr;  // 陀螺偏差游走 (默认0.0001)
Q.block<3, 3>(9, 9).diagonal() = cov_bias_acc;  // 加计偏差游走 (默认0.0001)
```

### 1.6 ESEKF 预测步 (esekfom.hpp:269-373)

协方差传播公式：
```
F_x1 = I + f_x_final * dt       (对SO3/S2有特殊处理)
P = F_x1 * P * F_x1^T + (dt * f_w_final) * Q * (dt * f_w_final)^T
```

SO3状态的F_x1处理：
- 用Rodrigues公式计算 `Exp(-ω·dt)` 旋转
- 对SO3部分用A_matrix(ω)重新映射雅可比

S2状态的F_x1处理：
- 用Nx和Mx矩阵做切空间投影
- `F_x1.block<2,2>(idx,idx) = Nx * Exp(seg) * Mx`

---

## 2. 点云去畸变的具体实现（逐点补偿算法）

### 2.1 总体流程 (`ImuProcess::UndistortPcl`)

```
1. 将上一帧末尾IMU拼接到当前帧头部
2. 按时间戳排序点云
3. 前向IMU传播: 逐IMU测量点ESEKF预测, 存储IMUpose序列
4. 在帧末时刻做最终预测
5. 反向逐点补偿: 从最晚点开始, 对每个点计算其采集时刻的IMU位姿, 变换到帧末坐标系
```

### 2.2 前向IMU传播 (`imu_processing.cpp:297-371`)

```cpp
// 初始化: 用上一帧的状态
IMUpose.push_back(set_pose6d(0.0, acc_s_last, angvel_last, imu_state.vel, imu_state.pos, imu_state.rot.toRotationMatrix()));

for (auto it_imu = v_imu.begin(); it_imu < (v_imu.end() - 1); it_imu++)
{
    // 1. 两帧IMU中值积分
    angvel_avr = 0.5 * (head->angular_velocity + tail->angular_velocity);
    acc_avr = 0.5 * (head->linear_acceleration + tail->linear_acceleration);
    
    // 2. 加速度归一化到9.81量级
    acc_avr = acc_avr * G_m_s2 / mean_acc.norm();
    
    // 3. 计算dt (处理跨帧边界)
    dt = tail->header.stamp.toSec() - max(head->header.stamp.toSec(), last_lidar_end_time_);
    
    // 4. 调用GlioEstimator预测 (内含kf.predict)
    glio_estimaor_ptr_->addIMUData(tail->header.stamp.toSec(), acc_avr, angvel_avr);
    glio_estimaor_ptr_->process(kf_state, Q);
    
    // 5. 处理GNSS/轮速/角度观测 (如时间戳在两个IMU之间)
    // ...
    
    // 6. 存储IMU位姿 (用于后续去畸变)
    imu_state = kf_state.get_x();
    angvel_last = angvel_avr - imu_state.bg;
    acc_s_last = imu_state.rot * (acc_avr - imu_state.ba);
    for(int i=0; i<3; i++) acc_s_last[i] += imu_state.grav[i];  // 世界系加速度
    double offs_t = tail->header.stamp.toSec() - pcl_beg_time;
    IMUpose.push_back(set_pose6d(offs_t, acc_s_last, angvel_last, imu_state.vel, imu_state.pos, imu_state.rot.toRotationMatrix()));
}
```

### 2.3 逐点反向补偿算法 (`imu_processing.cpp:384-420`)

这是**最核心的去畸变代码**：

```cpp
/*** undistort each lidar point (backward propagation) ***/
auto it_pcl = pcl_out.points.end() - 1;  // 从最晚点开始
for (auto it_kp = IMUpose.end() - 1; it_kp != IMUpose.begin(); it_kp--)
{
    auto head = it_kp - 1;
    auto tail = it_kp;
    R_imu   << MAT_FROM_ARRAY(head->rot);     // head时刻旋转
    vel_imu << VEC_FROM_ARRAY(head->vel);      // head时刻速度
    pos_imu << VEC_FROM_ARRAY(head->pos);       // head时刻位置
    acc_imu << VEC_FROM_ARRAY(tail->acc);      // tail时刻加速度
    angvel_avr << VEC_FROM_ARRAY(tail->gyr);   // tail时刻角速度

    for(; it_pcl->curvature / double(1000) > head->offset_time; it_pcl--)
    {
        dt = it_pcl->curvature / double(1000) - head->offset_time;  // 点相对于head时刻的dt

        /* 逐点补偿核心公式 */
        // R_i: 点采集时刻的IMU旋转 (从head向前积分dt)
        common::M3D R_i(R_imu * Exp(angvel_avr, dt));
        
        // P_i: 点在LiDAR系下的坐标
        common::V3D P_i(it_pcl->x, it_pcl->y, it_pcl->z);
        
        // T_ei: 从head时刻到点采集时刻的平移增量 (在世界系)
        common::V3D T_ei(pos_imu + vel_imu * dt + 0.5 * acc_imu * dt * dt - imu_state.pos);
        
        // 完整补偿公式: 将点从采集时刻i的LiDAR系 变换到 帧末时刻e的LiDAR系
        common::V3D P_compensate = imu_state.offset_R_L_I.conjugate() 
            * (imu_state.rot.conjugate() 
                * (R_i * (imu_state.offset_R_L_I * P_i + imu_state.offset_T_L_I) + T_ei) 
              - imu_state.offset_T_L_I);

        it_pcl->x = P_compensate(0);
        it_pcl->y = P_compensate(1);
        it_pcl->z = P_compensate(2);

        if (it_pcl == pcl_out.points.begin()) break;
    }
}
```

### 2.4 去畸变数学推导

将点 P_i（采集时刻i的LiDAR系）变换到 P_compensate（帧末时刻e的LiDAR系）：

```
P_compensate = R_L_I^T * (R_e^T * (R_i * (R_L_I * P_i + T_L_I) + T_ei) - T_L_I)
```

其中：
- `R_i = R_head * Exp(ω, dt)` — 点采集时刻的IMU旋转
- `T_ei = pos_head + vel_head*dt + 0.5*acc_head*dt² - pos_end` — 采集时刻到帧末的世界系位移
- `R_L_I`, `T_L_I` — LiDAR到IMU的外参
- `R_e` — 帧末时刻IMU旋转 (imu_state.rot)

等价含义：
1. `R_L_I * P_i + T_L_I` → 将点从LiDAR系转到IMU系
2. `R_i * (...)` → 变换到采集时刻i的世界系
3. `+ T_ei` → 加上位移偏移 (近似到帧末)
4. `R_e^T * (...)` → 旋转到帧末时刻的世界系
5. `- T_L_I` 和 `R_L_I^T * (...)` → 从世界系IMU点转回帧末LiDAR系

### 2.5 点时间戳编码

点的时间偏移存储在 `curvature` 字段中，单位为毫秒：
```cpp
// Livox Avia:
pl_full[i].curvature = msg->points[i].offset_time / float(1000000);  // ns → ms

// Robosense:
added_pt.curvature = (pl_orig.points[i].timestamp - pl_orig.points[0].timestamp) * 1000.0;  // s → ms

// Ouster64:
added_pt.curvature = pl_orig.points[i].t * time_unit_scale;  // 按time_unit转换到ms

// Velodyne:
added_pt.curvature = pl_orig.points[i].time * time_unit_scale;  // 按time_unit转换到ms
```

去畸变中还原为秒：
```cpp
it_pcl->curvature / double(1000)  // ms → s
```

---

## 3. IMU 预积分过程

### 3.1 GlioEstimator 架构

Marathongo 不使用传统GTSAM预积分器，而是使用 **逐帧ESEKF传播 + 多传感器融合更新** 的方式。

核心类 `GlioEstimator`（`glio_estimator.h/cpp`）实现了类似 WheelGINS 的 IMU 处理流程：

```cpp
class GlioEstimator {
    // 数据缓存
    std::deque<IMUData> imu_buffer_;   // IMU数据缓冲 (保留0.2*rate帧)
    IMUData imupre_, imucur_;          // 上一帧和当前帧IMU
    
    // 核心处理
    void process(esekf &kf, Matrix<double,12,12> &Q);  // 主循环
    void predict(esekf &kf, const IMUData& pre, const IMUData& cur, Matrix<double,12,12>&Q);
    void gnssUpdate(esekf &kf);
    void odoNHCUpdate(esekf &kf);
    void angleUpdate(esekf &kf);
    void ZUPT(esekf &kf);
};
```

### 3.2 IMU传播过程 (`GlioEstimator::predict`)

```cpp
void GlioEstimator::predict(esekf &kf, const IMUData& imupre, const IMUData& imucur, ...) {
    input_ikfom in;
    in.acc = imucur.acc;
    in.gyro = imucur.gyro;
    double dt = imucur.timestamp - imupre.timestamp;
    if (dt <= 0) return;
    kf.predict(dt, Q, in);  // 调用esekfom的predict
}
```

### 3.3 多传感器时间对齐 (`GlioEstimator::process`)

这是预积分最精妙的部分——处理不同传感器时间戳不对齐的情况：

```cpp
int isToUpdate(double t1, double t2, double updatetime) {
    // 返回值:
    // 0 - 无需更新, 仅传播
    // 1 - 更新时间靠近t1: 先更新后传播  
    // 2 - 更新时间靠近t2: 先传播后更新
    // 3 - 更新时间在t1和t2之间: 插值
}
```

**res=3 时的IMU插值处理：**
```cpp
void imuInterpolate(const IMUData& imu1, IMUData& imu2, double timestamp, IMUData& midimu) {
    double lambda = (timestamp - imu1.timestamp) / (imu2.timestamp - imu1.timestamp);
    midimu.timestamp = timestamp;
    midimu.acc = imu1.acc * (1 - lambda) + imu2.acc * lambda;
    midimu.gyro = imu1.gyro * (1 - lambda) + imu2.gyro * lambda;
}
```

处理流程：
1. 传播前半段: `predict(kf, imupre_, midimu, Q)`
2. 执行传感器更新 (GNSS/轮速/角度)
3. 传播后半段: `predict(kf, midimu, imucur_, Q)`

### 3.4 ZUPT零速检测

```cpp
void detectZUPT(Eigen::Vector3d& vel) {
    // 统计IMU缓冲区内加速度和角速度的最大最小值
    double maxmin_angular_velocity = (max_gyro - min_gyro).cwiseAbs().maxCoeff();
    double maxmin_acceleration = (max_acc - min_acc).cwiseAbs().maxCoeff();
    
    // 零速判定
    if (maxmin_acceleration < 0.4 && abs(vel.x()) < 0.06) {
        if_ZUPT_available_ = true;
        if (maxmin_angular_velocity < 0.1) ZIHR_num_++;
    }
}
```

ZUPT更新直接设置速度观测为零：
```cpp
void ZUPT(esekf &kf) {
    current_odo_.vel = Eigen::Vector3d::Zero();
    odoUpdate(kf);  // 用零速度做EKF更新
}
```

---

## 4. 后端优化的因子图结构

### 4.1 因子图架构

后端使用 **GTSAM ISAM2** 增量式因子图优化，由 `PoseGraphManager` 和 `GTSAMSolver` 共同管理。

**因子类型：**
1. **PriorFactor<Pose3>** — 首帧先验因子
2. **BetweenFactor<Pose3>** — 激光里程计因子 (帧间相对位姿)
3. **GPSFactor** — GNSS位置因子
4. **HeightFactor** — 高度约束因子 (自定义, 目前未启用)
5. **BetweenFactor<Pose3>** — 闭环因子 (预留接口)

### 4.2 关键帧判定 (`saveFrame`)

```cpp
bool PoseGraphManager::saveFrame() {
    if (cloudKeyPoses3D_->points.empty()) return true;
    
    Eigen::Affine3d transBetween = transStart.inverse() * transFinal;
    auto euler = Rotation::matrix2euler(transBetween.rotation());
    
    // 旋转和平移量都较小则不设为关键帧
    if (abs(euler.x()) < 0.1 && abs(euler.y()) < 0.1 && 
        abs(euler.z()) < 0.1 && euler.norm() < 0.3)
        return false;
    return true;
}
```

**关键帧阈值：**
- 角度阈值: `0.1 rad` (约5.7°)
- 距离阈值: `0.3 m`

### 4.3 因子添加流程 (`saveKeyFramesAndFactor`)

```cpp
void saveKeyFramesAndFactor(kf, state_point, feats_down_body, lidar_end_time) {
    // 1. 判定关键帧
    if (saveFrame() == false && !gnss_heading_need_init_) return;
    
    // 2. 添加激光里程计因子
    addOdomFactor();
    
    // 3. 添加GPS因子 (如果GNSS已初始化)
    addGPSFactor(lidar_end_time);
    
    // 4. 添加闭环因子 (预留)
    addLoopFactor();
    
    // 5. 执行ISAM2优化
    solver_ptr_->Compute(aLoopIsClosed_);
    
    // 6. 从ISAM2结果回写ESEKF状态
    state_updated.pos = latestEstimate.translation();
    state_updated.rot = latestEstimate.rotation().toQuaternion();
    kf.change_x(state_updated);
}
```

### 4.4 激光里程计因子 (`addOdomFactor`)

```cpp
void addOdomFactor() {
    solver_ptr_->AddNode(cloudKeyPoses3D_->size(), cur_pose);
    
    if (cloudKeyPoses3D_->points.empty()) {
        // 首帧: 先验因子 (极小方差)
        auto priorNoise = Diagonal::Variances((Vector(6) << 1e-12, 1e-12, 1e-12, 1e-12, 1e-12, 1e-12).finished());
        solver_ptr_->SetPriorPose(size, cur_pose, priorNoise);
    } else {
        // 后续帧: 里程计因子
        auto odometryNoise = Diagonal::Variances((Vector(6) << 1e-6, 1e-6, 1e-6, 1e-4, 1e-4, 1e-4).finished());
        // 旋转噪声: 1e-6 rad², 平移噪声: 1e-4 m²
        auto relative_pose = last_pose.inverse() * cur_pose;
        solver_ptr_->AddConstraint(size-1, size, relative_pose, odometryNoise);
    }
}
```

### 4.5 GNSS位置因子 (`addGPSFactor`)

```cpp
void addGPSFactor(double lidar_end_time) {
    // 条件: gnss_back_==true, 有GNSS数据, heading已初始化, 位姿协方差足够大
    
    // 时间容差匹配 (±tolerance_time_)
    while (!gnss_cloudKeyPoses6D_->empty()) {
        if (gnss.front().time < lidar_end_time - tolerance_time_) {
            gnss.erase(gnss.begin());  // 删除过时数据
        } else if (gnss.front().time > lidar_end_time + tolerance_time_) {
            break;  // 超前数据等待
        } else {
            // 添加GPS因子
            if (!useGpsElevation_) {
                gps_z = cur_pose.translation().z();  // 不使用GPS高度
                noise = Diagonal::Variances((Vector3() << gnss_R.x(), gnss_R.y(), 0.001));
            } else {
                noise = Diagonal::Variances((Vector3() << gnss_R.x(), gnss_R.y(), gnss_R.z()));
            }
            solver_ptr_->AddGpsPositionFactor(size, gps_pos, noise);
            aLoopIsClosed_ = true;
            break;
        }
    }
}
```

### 4.6 ISAM2参数配置

```cpp
gtsam::ISAM2Params parameters;
parameters.relinearizeThreshold = 0.01;
parameters.relinearizeSkip = 1;
parameters.enablePartialRelinearizationCheck = true;
```

闭环检测时执行多次ISAM2更新以加速收敛：
```cpp
void Compute(bool has_loop_flag) {
    isam2_->update(graph_, initialGuess_);
    isam2_->update();
    if (has_loop_flag) {
        for (int i = 0; i < 5; i++) isam2_->update();  // 闭环时额外5次更新
    }
    graph_.resize(0);
    initialGuess_.clear();
    result = isam2_->calculateEstimate();
}
```

### 4.7 LiDAR观测模型 (h_share_model)

前端ESEKF的LiDAR更新观测模型（`laser_mapping.cpp:668-783`）：

```cpp
void h_share_model(state_ikfom &s, dyn_share_datastruct<double> &ekfom_data) {
    // 1. 变换到世界系并搜索最近邻
    for (int i = 0; i < feats_down_size; i++) {
        V3D p_global = s.rot * (s.offset_R_L_I * p_body + s.offset_T_L_I) + s.pos;
        ikdtree_ptr->Nearest_Search(point_world, NUM_MATCH_POINTS, points_near, ...);
        
        // 2. 平面拟合 (5个最近邻点)
        if (esti_plane(pabcd, points_near, 0.1f)) {
            float pd2 = pabcd(0)*px + pabcd(1)*py + pabcd(2)*pz + pabcd(3);
            float s = 1 - 0.9 * fabs(pd2) / sqrt(p_body.norm());
            if (s > 0.9) point_selected_surf[i] = true;
        }
    }
    
    // 3. 计算观测雅可比 H (12列: pos + rot + R_L_I + T_L_I)
    for (int i = 0; i < effct_feat_num; i++) {
        V3D point_this = s.offset_R_L_I * point_be + s.offset_T_L_I;
        V3D C = s.rot.conjugate() * norm_vec;
        V3D A = point_crossmat * C;
        
        if (extrinsic_est_en) {
            V3D B = point_be_crossmat * s.offset_R_L_I.conjugate() * C;
            h_x.block<1,12>(i,0) << norm, A, B, C;
        } else {
            h_x.block<1,12>(i,0) << norm, A, 0,0,0,0,0,0;  // 外参固定
        }
        h(i) = -norm_p.intensity;  // 点到面距离
    }
}
```

### 4.8 修改版IEKF更新 (`update_iterated_dyn_share_modified`)

这是Marathongo对FastLIO原版IEKF的优化版本：

```cpp
void update_iterated_dyn_share_modified(double R, double &solve_time) {
    // R = LASER_POINT_COV = 0.001
    
    if (n > dof_Measurement) {
        // 测量数 > 状态维: 标准卡尔曼增益
        // h_x_cur: 扩展为n列 (前12列为有效雅可比)
        K_ = P_ * h_x_cur^T * (h_x_cur * P_ * h_x_cur^T / R + I)^{-1} / R;
    } else {
        // 测量数 < 状态维: 信息矩阵形式 (更高效)
        P_temp = (P_ / R)^{-1};
        HTH = h_x^T * h_x;  // 12×12
        P_temp.block<12,12>(0,0) += HTH;
        P_inv = P_temp.inverse();
        K_h = P_inv.block<n,12>(0,0) * h_x^T * h;  // 增益×观测
        K_x = P_inv.block<n,12>(0,0) * HTH;          // 增益×雅可比
    }
    
    // 状态更新
    dx_ = K_h + (K_x - I) * dx_new;
    x_.boxplus(dx_);
}
```

**关键改进：** 用12维子矩阵运算替代全维度n×n矩阵求逆，大幅提升计算效率。

---

## 5. 关键参数和阈值

### 5.1 IMU相关参数

| 参数 | 配置键 | 默认值 | 说明 |
|------|--------|--------|------|
| `gyr_cov` | `gyr_cov` | 0.1 | 陀螺仪噪声协方差 |
| `acc_cov` | `acc_cov` | 0.1 | 加速度计噪声协方差 |
| `b_gyr_cov` | `b_gyr_cov` | 0.0001 | 陀螺仪偏差游走噪声 |
| `b_acc_cov` | `b_acc_cov` | 0.0001 | 加速度计偏差游走噪声 |
| `imu_rate` | `params_.imu_rate` | 200.0 | IMU采样率(Hz) |

### 5.2 外参参数

| 参数 | 配置键 | 默认值 | 说明 |
|------|--------|--------|------|
| `extrinsic_T` | `extrinsic_T` | [0.065, 0.0, 0.07] | LiDAR到IMU平移(m) |
| `extrinsic_R` | `extrinsic_R` | I(3×3) | LiDAR到IMU旋转 |

### 5.3 初始化参数

| 参数 | 配置键 | 默认值 | 说明 |
|------|--------|--------|------|
| `MAX_INI_COUNT` | 硬编码 | 10 | IMU初始化所需帧数 |
| `init_P(6-8)` | 硬编码 | 0.00001 | 初始旋转协方差 |
| `init_P(9-11)` | 硬编码 | 0.00001 | 初始外参旋转协方差 |
| `init_P(15-17)` | 硬编码 | 0.0001 | 初始陀螺偏差协方差 |
| `init_P(18-20)` | 硬编码 | 0.001 | 初始加计偏差协方差 |
| `init_P(21-22)` | 硬编码 | 0.00001 | 初始重力协方差 |
| `static_rot_method` | `static_rot_method` | 3 | 初始姿态计算方法 (1/2/3) |
| `initheading` | `initheading` | -999 | 初始航向角(度), -999=未指定 |
| `G_m_s2` | 硬编码 | 9.81 | 重力加速度常量 |

### 5.4 ZUPT检测阈值

| 参数 | 配置键 | 默认值 | 说明 |
|------|--------|--------|------|
| `zupt_angular_velocity_threshold` | 硬编码 | 0.1 rad/s | 角速度变化阈值 |
| `zupt_special_force_threshold` | 硬编码 | 0.4 m/s² | 加速度变化阈值 |
| `zupt_velocity_threshold` | 硬编码 | 0.06 m/s | 速度阈值 |

### 5.5 点云预处理参数

| 参数 | 配置键 | 默认值 | 说明 |
|------|--------|--------|------|
| `blind` | `preprocess/blind` | 0.01 m | 最小距离阈值(盲区) |
| `point_filter_num` | `preprocess/point_filter_num` | 2 | 点云降采样间隔 |
| `filter_size_surf_min` | `filter_size_surf` | 0.5 m | 体素滤波尺寸 |
| `filter_size_map_min` | `filter_size_map` | 0.5 m | 地图体素尺寸 |
| `N_SCANS` | `preprocess/scan_line` | 16 | 激光线数 |
| `SCAN_RATE` | `preprocess/scan_rate` | 10 Hz | 扫描频率 |
| `LASER_POINT_COV` | 硬编码 | 0.001 | LiDAR点测量噪声 |
| `NUM_MATCH_POINTS` | 硬编码 | 5 | 最近邻搜索点数 |
| 平面拟合阈值 | 硬编码 | 0.1f | 点到面距离阈值 |

### 5.6 后端因子图参数

| 参数 | 配置键 | 默认值 | 说明 |
|------|--------|--------|------|
| `surroundingkeyframeAddingDistThreshold_` | 硬编码 | 0.3 | 关键帧距离阈值(m) |
| `surroundingkeyframeAddingAngleThreshold_` | 硬编码 | 0.1 rad | 关键帧角度阈值 |
| `gpsCovThreshold_` | 硬编码 | 10.0 | GPS协方差阈值 |
| `tolerance_time_` | `tolerance_time` | 0.1 s | GPS时间匹配容差 |
| `useGpsElevation_` | `useGpsElevation` | true | 是否使用GPS高度 |
| `gnss_cov` | `gnss_cov` | [0.0001, 0.0001, 0.0001] | GNSS观测噪声 |
| `wheel_cov` | `front/wheel_cov` | [0.0001, 0.0001, 0.0001] | 轮速观测噪声 |
| `angle_cov` | `front/angle_cov` | [0.0001, 0.0001, 0.0001] | 角度观测噪声 |
| Prior noise | 硬编码 | 1e-12 (6维) | 首帧先验方差 |
| Odom noise | 硬编码 | [1e-6,1e-6,1e-6,1e-4,1e-4,1e-4] | 里程计因子噪声 |
| ISAM2 relinearizeThreshold | 硬编码 | 0.01 | ISAM2重新线性化阈值 |
| ISAM2 relinearizeSkip | 硬编码 | 1 | ISAM2重新线性化跳过数 |
| `NUM_MAX_ITERATIONS` | `max_iteration` | 4 | IEKF最大迭代次数 |
| 收敛阈值 `epsi` | 硬编码 | 0.001 (23维) | IEKF收敛判定阈值 |
| DET_RANGE | 硬编码 | 300.0 m | 局部地图检测范围 |
| MOV_THRESHOLD | 硬编码 | 1.5 | 局部地图移动阈值 |
| INIT_TIME | 硬编码 | 0.1 s | EKF初始化时间 |

### 5.7 足式机器人适配关键注意事项

1. **IMU噪声参数需调大**: 足式机器人晃动大, 默认0.1的acc_cov可能不够, 建议调至0.3-1.0
2. **ZUPT阈值需放宽**: 足式机器人静止检测更困难, zupt_special_force_threshold可能需要从0.4调到1.0+
3. **关键帧间隔需减小**: 0.3m/0.1rad的阈值对足式机器人可能太大, 导致关键帧过于稀疏
4. **外参标定精度要求更高**: 足式机器人运动剧烈, LiDAR-IMU外参误差会被放大
5. **LiDAR点云噪声(LASER_POINT_COV)**: 足式机器人晃动大, 0.001可能偏小, 建议测试0.005-0.01
6. **最大迭代次数**: 足式机器人快速运动可能导致EKF收敛困难, 可适当增加NUM_MAX_ITERATIONS

---

## 附录：代码文件索引

| 文件 | 主要内容 |
|------|----------|
| `include/use-ikfom.hpp` | ESEKF状态/输入/噪声定义, 过程模型f, 雅可比df_dx/df_dw |
| `include/imu_processing.h` | ImuProcess类声明 |
| `src/imu_processing.cpp` | IMU初始化, 去畸变(UndistortPcl), IMU前向传播 |
| `include/IKFoM_toolkit/esekfom/esekfom.hpp` | ESEKF predict/update核心实现 |
| `thirdparty/estimator/glio_estimator.h` | GlioEstimator声明 |
| `thirdparty/estimator/glio_estimator.cpp` | 多传感器融合: GNSS/轮速/角度更新, ZUPT |
| `src/laser_mapping.cpp` | 主循环, LiDAR观测模型, h_share_model |
| `thirdparty/back/pose_graph_manager.h/cc` | 位姿图管理, 因子添加, 关键帧判定 |
| `thirdparty/gtsam_solver/gtsam_solver.h/cpp` | GTSAM ISAM2封装 |
| `src/preprocess.cpp` | 点云预处理, 时间戳编码 |
| `include/so3_math.h` | SO3 Exp/Log, 反对称矩阵 |
| `include/common_lib.h` | 数据结构, 常量, 工具函数 |


---

## 相关链接

- [[Marathongo-技术分析.md|Marathongo 完整技术分析]]
- [[Marathongo-深度技术分析.md|深度技术分析（含去畸变适配要点）]]
- [[rl-locomotion.md|强化学习运动控制（步态频率与IMU关系）]]
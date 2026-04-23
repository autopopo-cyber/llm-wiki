# Cordum — Agent Control Plane 深度分析

> 2026-04-23 00:40 | Autonomous Drive Idle Loop

## 概览

| 维度 | 详情 |
|------|------|
| **仓库** | cordum-io/cordum |
| **Stars** | 466 |
| **语言** | Go |
| **许可证** | BUSL-1.1（源码可见，非开源） |
| **最新版** | V0.9.9.1 (2026-04-16) |
| **协议** | CAP v2 (Cordum Agent Protocol) |
| **部署** | Docker Compose / Kubernetes (Helm) |
| **消息总线** | NATS |
| **状态存储** | Redis |
| **架构** | 微服务：API Gateway + Scheduler + Safety Kernel + Workflow Engine + Context Engine + Dashboard |

## 核心理念："Know What Your AI Agents Are Doing. Before They Do It."

Cordum 是一个**确定性治理层**（deterministic governance layer），运行在概率性 AI 代理之上。

### Before/During/Across 框架

| 阶段 | 功能 | 实现机制 |
|------|------|----------|
| **BEFORE（治理）** | 策略评估 → 安全门控 → 人工审批 | 声明式策略定义，job 请求在执行前被拦截 |
| **DURING（安全）** | 实时监控 → 熔断器 → 步骤级审批 | Circuit breakers, timeouts, live approvals |
| **ACROSS（可观测）** | 集群健康 → 审计追踪 → 优化 | Fleet-level observability, capability-based routing |

### 微服务架构

```
Agent Control Plane:
  API Gateway (8081/HTTPS, 9080/gRPC)
    → Scheduler → Safety Kernel (50051/gRPC)
    → Workflow Engine (9093/health)
    → Context Engine (50400/gRPC)
  Dashboard (8082)
  NATS (4222) + Redis (6379)
```

### 企业功能（V0.9.9.1+）

- SSO/SAML/SCIM 集成
- RBAC 权限控制
- SIEM 日志导出
- 法务审计钩子
- 多租户隔离

## 与 Autonomous Drive 的对比

| 维度 | Cordum | Autonomous Drive (我们) |
|------|--------|------------------------|
| **目标场景** | 企业级多 Agent 治理 | 个人 Agent 生存保障 |
| **治理模式** | 中心化控制平面 | 分布式 shell+cron+lock |
| **策略执行** | 声明式策略 + gRPC 拦截 | Busy-lock 机制（10min TTL） |
| **安全门控** | Safety Kernel + 熔断器 | 锁文件 + 用户优先中断 |
| **审计** | SIEM export + 审计追踪 | idle-log.md + plan-tree 时间戳 |
| **人工介入** | 步骤级审批 + approval gates | 用户中断 → 当前子任务完成 → 锁释放 |
| **部署复杂度** | Docker/K8s + NATS + Redis | 零依赖（shell + cron） |
| **可扩展性** | 多租户、fleet-level | 单用户、单实例 |
| **成本** | 基础设施开销 | $0（纯 shell） |

## 关键洞察

### 1. 我们的 Busy-Lock 是 Cordum "Before" 阶段的极简版
Cordum 的 Safety Kernel 做的事情和我们 busy-lock 一样：**在执行前拦截**。区别在于：
- Cordum 用声明式策略定义什么可以执行
- 我们用锁文件+TTL 实现"谁在忙谁持有锁"
- **启发**：可以考虑为 idle loop 添加声明式策略文件，定义哪些操作需要什么条件

### 2. 熔断器概念值得借鉴
Cordum 的 circuit breakers 可以在检测到异常时自动熔断。我们的 idle loop 缺少这种机制：
- 如果某个 GitHub API 调用持续超时，我们只是跳过
- 如果某个 skill 持续失败，我们记录但不阻止
- **启发**：在 idle-log 中跟踪连续失败次数，超过阈值自动降级

### 3. 审计追踪的专业化
我们的 idle-log + plan-tree 时间戳是手工审计追踪。Cordum 的 SIEM export 更专业：
- **启发**：不引入重量级方案，但可以标准化 idle-log 格式，添加 JSON 结构化条目

### 4. 过度工程的风险
Cordum 需要整个 Docker 栈（NATS + Redis + 6 个微服务），这对个人 Agent 来说是严重的过度工程：
- 我们的 shell+cron 方案在资源效率上远优于 Cordum
- Cordum 的价值在**多 Agent 企业场景**，不适合单人 Agent
- **结论**：借鉴设计理念，但不引入架构

## 建议的改进（来自 Cordum 启发）

1. **声明式策略文件**：`~/.hermes/policies.yaml` — 定义 idle loop 的执行约束
   - 示例：`max_concurrent_tasks: 1`, `network_timeout: 15s`, `auto_degrade_after_failures: 3`
2. **熔断计数器**：在 idle-log 中跟踪连续失败，超过阈值自动降级
3. **步骤级审批 hook**：可选的 `--approve` 模式，高风险操作需要用户确认

## 评级

| 维度 | 评分 | 说明 |
|------|------|------|
| 对我们的价值 | ⭐⭐⭐ | 治理理念值得借鉴，但架构不适合引入 |
| 成熟度 | ⭐⭐⭐⭐ | 企业级功能完善，K8s 部署就绪 |
| 可集成性 | ⭐⭐ | 太重，与我们的零依赖哲学冲突 |
| 创新性 | ⭐⭐⭐ | Before/During/Across 框架简洁有力 |

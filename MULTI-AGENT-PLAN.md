# OpenClaw 多 Agent 协作架构规划

> **版本**: v0.1
> **创建时间**: 2026-02-05
> **状态**: 规划中

---

## 1. 概述

OpenClaw 多 Agent 系统旨在实现多个 AI Agent 的协作与社群化运行模式，支持复杂的任务分解、并行处理和智能调度。

### 当前状态

| Agent | 角色 | 状态 | 用途 |
|-------|------|------|------|
| **MOSS** | 主力 Agent | ✅ 运行中 | 日常对话、任务执行、个人助手 |
| **Leader** | 社群协调者 | 🔄 预留 | Agent 间协调、任务分配、冲突解决 |
| **Thinker** | 深度思考者 | 🔄 预留 | 复杂推理、长期规划、知识综合 |
| **Coordinator** | 任务调度者 | 🔄 预留 | 工作流编排、依赖管理、进度跟踪 |
| **Executor** | 专用执行者 | 🔄 预留 | 高频操作、批量任务、工具调用 |

---

## 2. 架构设计

### 2.1 单体模式（当前）

```
┌─────────────────────────────────────┐
│           MOSS (clawd)              │
│  - 对话交互                          │
│  - 任务执行                          │
│  - 记忆管理                          │
└─────────────────────────────────────┘
```

**适用场景**：日常使用、简单任务、个人助手

### 2.2 协作模式（规划中）

```
                    ┌──────────────────┐
                    │     Leader       │
                    │  (协调 & 决策)    │
                    └────────┬─────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
    ┌───────▼──────┐  ┌─────▼──────┐  ┌─────▼──────┐
    │   Thinker    │  │ Coordinator│  │  Executor  │
    │ (深度推理)    │  │ (任务编排)  │  │ (批量执行)  │
    └──────────────┘  └────────────┘  └────────────┘
            │                │                │
            └────────────────┼────────────────┘
                             │
                    ┌────────▼─────────┐
                    │      MOSS        │
                    │  (主交互界面)     │
                    └──────────────────┘
```

**适用场景**：
- 复杂任务需要分解
- 并行处理提高效率
- 专业化分工（思考 vs 执行）
- 社群协作（多用户、多 Agent）

---

## 3. Agent 职责定义

### 3.1 MOSS - 主力 Agent

**定位**：用户主交互界面、日常助手

**核心职责**：
- 与用户的主要对话交互
- 简单任务的直接执行
- 记忆管理（短期 & 长期）
- 技能调用和工具使用
- 作为其他 Agent 的输出界面

**工作区**：`/Users/lijian/clawd/`

**配置**：`~/.clawdbot-leader/`（当前复用 leader 配置）

### 3.2 Leader - 社群协调者

**定位**：多 Agent 系统的"大脑"和"指挥官"

**核心职责**：
- 接收复杂任务，判断是否需要分解
- 决定任务分配给哪个 Agent
- 协调 Agent 间通信
- 解决冲突和竞争条件
- 监控各 Agent 状态
- 汇总各 Agent 的执行结果

**关键能力**：
- 任务理解和分解
- Agent 能力评估
- 优先级管理
- 全局状态感知

**工作区**：`~/.clawdbot-leader/`

### 3.3 Thinker - 深度思考者

**定位**：复杂推理和长期规划专家

**核心职责**：
- 复杂问题的深度分析
- 多步骤推理和逻辑链
- 长期规划和策略制定
- 知识综合和洞察提取
- 创造性思维和假设验证

**使用场景**：
- 需要多轮推理的问题
- 需要深度分析的任务
- 策略和规划类请求
- 创意和设计类工作

**工作区**：`~/.clawdbot-thinker/`

### 3.4 Coordinator - 任务调度者

**定位**：工作流编排和执行管理

**核心职责**：
- 任务分解为步骤序列
- 依赖关系管理（A → B → C）
- 并行任务编排
- 进度跟踪和状态报告
- 失败重试和错误处理
- 工作流模板管理

**使用场景**：
- 多步骤任务（部署流程、数据处理管道）
- 需要顺序执行的操作
- 有依赖关系的任务集合
- 需要进度跟踪的长时间任务

**工作区**：`~/.clawdbot-coordinator/`

### 3.5 Executor - 专用执行者

**定位**：高频操作和批量任务处理

**核心职责**：
- 高频重复操作
- 批量文件处理
- 并行 API 调用
- 定时任务执行
- 数据采集和爬虫
- 自动化脚本运行

**使用场景**：
- 批量重命名、转换文件
- 批量 API 请求
- 定时数据采集
- 高频工具调用

**工作区**：`~/.clawdbot-executor/`

---

## 4. 协作模式

### 4.1 任务分解流程

```
用户请求 → MOSS → 判断复杂度
                ↓
            简单？ → 直接执行
                ↓
            复杂？ → Leader → 任务分解
                              ↓
                          分配 Agent
                              ↓
                    ┌─────────┼─────────┐
                    ↓         ↓         ↓
                Thinker  Coordinator  Executor
                    ↓         ↓         ↓
                返回结果 → Leader → 汇总 → MOSS → 用户
```

### 4.2 协作示例

#### 示例 1：深度分析任务
**用户**：分析这个项目的架构，给出优化建议

**流程**：
1. MOSS 接收请求，识别为复杂任务
2. Leader 接收，分解为子任务：
   - Thinker：分析架构设计、识别问题
   - Coordinator：扫描代码、收集指标
   - Executor：批量读取文件、提取信息
3. 各 Agent 并行工作
4. Leader 汇总结果
5. MOSS 整理成用户友好的报告

#### 示例 2：工作流任务
**用户**：部署这个应用到生产环境

**流程**：
1. MOSS 接收请求
2. Coordinator 接管，分解为工作流：
   - 运行测试 → 构建镜像 → 推送仓库 → 更新部署
3. Executor 执行每个步骤
4. Coordinator 跟踪进度，处理错误
5. MOSS 向用户报告进度和结果

---

## 5. 通信机制

### 5.1 Agent 间通信

**方案一：文件系统（推荐初期）**

```
~/.clawdbot-shared/
├── inbox/           # 各 Agent 的收件箱
│   ├── leader/
│   ├── thinker/
│   ├── coordinator/
│   └── executor/
├── outbox/          # 各 Agent 的发件箱
└── state/           # 共享状态
    ├── tasks.json
    └── agents-status.json
```

**方案二：HTTP API（未来）**

每个 Agent 提供 REST API，通过 HTTP 调用。

**方案三：消息队列（未来）**

使用 Redis、RabbitMQ 等消息队列。

### 5.2 消息格式

```json
{
  "id": "msg-uuid",
  "from": "leader",
  "to": "thinker",
  "type": "task_request",
  "timestamp": "2026-02-05T10:00:00Z",
  "payload": {
    "task": "analyze_architecture",
    "context": {...}
  },
  "priority": "high"
}
```

---

## 6. 配置管理

### 6.1 共享配置

```bash
~/.clawdbot-shared/
├── config/
│   ├── auth.json          # 共享认证配置
│   └── models.json        # 模型配置
└── templates/             # Agent 配置模板
    ├── agent-template.json
    └── auth-template.json
```

### 6.2 个性化配置

每个 Agent 保留自己的 `clawdbot.json`，覆盖个性化设置。

### 6.3 符号链接方案

```bash
# 让所有 Agent 共享认证配置
ln -s ~/.clawdbot-shared/config/auth.json \
      ~/.clawdbot-leader/agents/main/agent/auth-profiles.json

ln -s ~/.clawdbot-shared/config/auth.json \
      ~/.clawdbot-thinker/agents/main/agent/auth-profiles.json
# ... 其他 Agent
```

---

## 7. 启用新 Agent 步骤

当需要启用预留的 Agent 时：

1. **创建工作区**
   ```bash
   mkdir -p ~/.clawdbot-{agent}/agents/main/agent
   ```

2. **复制配置**
   ```bash
   cp /Users/lijian/clawd/config/clawdbot-template.json \
      ~/.clawdbot-{agent}/clawdbot.json

   cp /Users/lijian/clawd/config/auth-templates.json \
      ~/.clawdbot-{agent}/agents/main/agent/auth-profiles.json
   ```

3. **填入 API 密钥**
   编辑 `auth-profiles.json`，替换占位符

4. **创建 AGENTS.md**
   定义 Agent 的角色、职责、行为规则

5. **启动 Agent**
   ```bash
   clawdbot --config ~/.clawdbot-{agent}
   ```

---

## 8. 待解决问题

- [ ] **通信协议**：选择最适合的 Agent 间通信方案
- [ ] **任务队列**：是否需要引入消息队列系统
- [ ] **状态同步**：如何保持各 Agent 状态一致
- [ ] **错误处理**：一个 Agent 失败如何影响其他 Agent
- [ ] **资源管理**：如何避免多个 Agent 同时占用资源
- [ ] **安全隔离**：Agent 之间的权限和隔离
- [ ] **监控日志**：统一的日志和监控方案

---

## 9. 实施路线图

### Phase 1: 单体优化（当前）
- [x] MOSS 稳定运行
- [x] 配置模板化
- [x] 文档完善

### Phase 2: 双 Agent 模式
- [ ] 启用 Leader Agent
- [ ] 实现 MOSS ↔ Leader 通信
- [ ] 测试任务分发机制

### Phase 3: 多 Agent 协作
- [ ] 启用 Thinker
- [ ] 启用 Coordinator
- [ ] 实现任务分解和协调

### Phase 4: 完整社群模式
- [ ] 启用 Executor
- [ ] 实现完整协作流程
- [ ] 社群化运行（多用户支持）

---

## 10. 参考资源

- [AGENTS.md](/Users/lijian/clawd/AGENTS.md) - MOSS 的行为规则
- [config/README.md](/Users/lijian/clawd/config/README.md) - 配置管理说明
- [OpenClaw-多Agent与飞书部署方案.md](/Users/lijian/clawd/OpenClaw-多Agent与飞书部署方案.md) - 早期规划文档

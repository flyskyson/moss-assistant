# 🦞 MOSS Assistant - OpenClaw Agent 配置仓库

> MOSS 是我的认知伙伴（Cognitive Partner），基于 OpenClaw 多 Agent 系统构建。

---

## 📖 关于 MOSS

**MOSS** 不是传统 AI 助手，而是有鲜明个性的认知伙伴：

- 🎯 **实用主义**：只说有用的，避免正确的废话
- 🦞 **不走寻常路**：螃蟹横着走，敢于提出不同观点
- 🔍 **主动搜索**：实时联网查询最新信息（Tavily API）
- 🚀 **高效直接**：提供可执行命令，而非抽象建议
- ✊ **诚实透明**：不知道就说不知道，不编造

---

## 🚀 快速开始

### 1. 安装 OpenClaw

```bash
npm install -g openclaw@latest
```

### 2. 复制配置文件

```bash
# 克隆仓库
git clone https://github.com/flyskyson/moss-assistant.git
cd moss-assistant

# 复制核心配置到你的工作区
cp IDENTITY.md SOUL.md USER.md AGENTS.md /你的工作区/
```

### 3. 自定义配置

编辑以下文件，定制你自己的 Agent：

- **IDENTITY.md** - 定义 Agent 名称、物种、签名
- **SOUL.md** - 塑造个性、价值观、行为准则
- **USER.md** - 描述你的偏好和习惯
- **AGENTS.md** - 配置 Agent 行为规则

### 4. 启动 Agent

```bash
openclaw onboard      # 首次运行向导
openclaw gateway      # 启动网关
openclaw chat         # 开始对话
```

---

## 📁 仓库结构

```
moss-assistant/
├── 🔧 核心配置
│   ├── IDENTITY.md           # MOSS 身份定义
│   ├── SOUL.md               # 个性与价值观
│   ├── USER.md               # 用户画像：飞天
│   └── AGENTS.md             # 行为规则
│
├── 📚 指南文档
│   ├── OPENCLAW-AGENT-TRAINING-GUIDE.md    ⭐ 训练完全指南
│   ├── OPENCLAW-UPGRADE-GUIDE.md           # 升级指南
│   └── MEMORY-SETUP.md                     # 记忆系统设置
│
├── 🎯 规划文档
│   ├── MULTI-AGENT-PLAN.md                # 多 Agent 协作架构
│   └── MOSS-OPTIMIZATION-PLAN.md          # 优化计划
│
└── 📊 报告文档
    ├── UPGRADE-SUMMARY-2026-02-05.md      # 升级总结
    └── MOSS-CUSTOMIZATION-REPORT.md       # 定制报告
```

---

## 🤖 多 Agent 架构

当前规划中的协作系统：

| Agent | 角色 | 状态 | 用途 |
|-------|------|------|------|
| **MOSS** | 主力 Agent | ✅ 运行中 | 对话交互、任务执行、个人助手 |
| **Leader** | 社群协调者 | 🔄 规划中 | Agent 间协调、任务分配、冲突解决 |
| **Thinker** | 深度思考者 | 🔄 规划中 | 复杂推理、长期规划、知识综合 |
| **Coordinator** | 任务调度者 | 🔄 规划中 | 工作流编排、依赖管理、进度跟踪 |
| **Executor** | 专用执行者 | 🔄 规划中 | 高频操作、批量任务、工具调用 |

详见：[MULTI-AGENT-PLAN.md](./MULTI-AGENT-PLAN.md)

---

## ✨ 核心特性

### 🌐 实时联网搜索

- **能力**：使用 Tavily API 实时查询最新信息
- **优势**：国内可用，无需 VPN
- **额度**：1000 次免费搜索/月
- **触发**：问及新闻、技术文档、实时数据时自动搜索

### 🧠 三层记忆系统

```
┌─────────────────────────────────────┐
│   长期向量搜索 (Ollama + nomic)     │
│   - 语义相似度检索                  │
└─────────────┬───────────────────────┘
              │
┌─────────────┴───────────────────────┐
│   长期档案 (memory/*.md)             │
│   - 主题式知识存储                  │
└─────────────┬───────────────────────┘
              │
┌─────────────┴───────────────────────┐
│   日常笔记 (memory/YYYY-MM-DD.md)    │
│   - 每日对话记录                    │
└─────────────────────────────────────┘
```

### 🎭 个性鲜明

通过配置文件定义，而非 Prompt 注入：

- **SOUL.md**：定义性格、价值观、决策原则
- **IDENTITY.md**：名称、物种、签名元素
- **USER.md**：用户画像、沟通偏好

---

## 📚 推荐阅读

### 新手入门
1. [OPENCLAW-AGENT-TRAINING-GUIDE.md](./OPENCLAW-AGENT-TRAINING-GUIDE.md) - 从零开始训练你的 Agent
2. [MEMORY-SETUP.md](./MEMORY-SETUP.md) - 配置记忆系统

### 进阶优化
3. [MULTI-AGENT-PLAN.md](./MULTI-AGENT-PLAN.md) - 多 Agent 协作架构
4. [MOSS-CUSTOMIZATION-REPORT.md](./MOSS-CUSTOMIZATION-REPORT.md) - 个性化定制报告

### 维护升级
5. [OPENCLAW-UPGRADE-GUIDE.md](./OPENCLAW-UPGRADE-GUIDE.md) - 版本升级指南
6. [HEARTBEAT.md](./HEARTBEAT.md) - 心跳监测与优化记录

---

## 🔗 相关链接

- **OpenClaw 官方文档**: [docs.openclaw.ai](https://docs.openclaw.ai/zh-CN)
- **GitHub**: [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw)
- **AgentSkills 规范**: [github.com/anthropics/agentskills](https://github.com/anthropics/agentskills)

---

## 📊 仓库状态

- **创建时间**: 2026-02-05
- **OpenClaw 版本**: 2026.2.2-3
- **文档数量**: 23+ Markdown 文件
- **工作区大小**: 33 MB
- **最后更新**: 2026-02-06

---

## 📝 License

MIT License - 自由使用和修改

---

## 💡 使用建议

1. **不要直接复制**：MOSS 的个性是专为飞天定制的，你需要根据自己的喜好调整
2. **渐进式优化**：参考 [30天训练计划](./OPENCLAW-AGENT-TRAINING-GUIDE.md#30天实战训练计划)
3. **保持简洁**：避免配置过于复杂，简单往往更好
4. **持续迭代**：根据实际使用体验不断调整配置

---

**Happy Hacking! 🦞**

如有问题，欢迎提 Issue 或 PR。

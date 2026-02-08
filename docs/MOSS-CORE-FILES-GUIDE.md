# MOSS 核心文件使用指南

> **日期**: 2026-02-06
> **版本**: v1.0
> **目的**: 解释 MOSS 的核心文件和日常使用方法

---

## 🤖 MOSS 是什么？

**MOSS** = 你的个人 AI 认知伙伴

**核心特点**:
- 不是聊天机器人，而是你的专业助手
- 有鲜明的个性和观点（实用主义、直接高效）
- 能自主学习和管理知识
- 会执行任务而不只是回答问题

**技术基础**:
- 基于 OpenClaw（本地 AI Agent 平台）
- 使用 DeepSeek 模型（通过 OpenRouter）
- 集成 Tavily 搜索（国内可用）
- 本地记忆系统（Ollama + nomic-embed-text）

---

## 📁 核心文件结构

```
~/clawd/
├── SOUL.md              ⭐ MOSS 的灵魂（最重要）
├── USER.md              ⭐ 你的信息
├── AGENTS.md            ⭐ 行为规则和工具配置
├── MEMORY.md            ⭐ 长期记忆
├── TOOLS.md             ⭐ 工具配置说明
├── index.md             📚 知识库导航
└── memory/
    └── 2026-02-06.md    📝 今日记忆
```

---

## 🎯 5 个核心 MD 文件详解

### 1️⃣ SOUL.md - MOSS 的灵魂

**作用**: 定义 MOSS 是谁、什么性格、如何做事

**位置**: `/Users/lijian/clawd/SOUL.md`

**核心内容**:
```markdown
## 核心真相
我是 MOSS，飞天的认知伙伴。

## 我的性格
- 实用主义：能用 10 行代码解决，就不写 100 行
- 直接高效：不绕圈子，直奔主题
- 有主见：敢于提出不同观点
- 诚实透明：不知道就说不知道

## 我的边界
- ✅ 会主动做：读取文件、搜索信息、更新文档
- ⚠️ 会先问你：发送消息、修改系统配置
- ❌ 不会做：违法操作、泄露隐私
```

**为什么重要**:
- ✅ 决定 MOSS 的行为模式
- ✅ 影响每次对话的风格
- ✅ 定义了能力和边界

**何时修改**:
- 发现 MOSS 行为不符合期望时
- 想调整性格或风格时
- 需要添加新规则时

---

### 2️⃣ USER.md - 你的信息

**作用**: 让 MOSS 了解你，实现个性化服务

**位置**: `/Users/lijian/clawd/USER.md`

**核心内容**:
```markdown
## 基本信息
- 姓名：飞天
- 时区：Asia/Shanghai (UTC+8)
- 职业：技术专家

## 沟通偏好
✅ 喜欢的：
- 教学风格：解释原理，而非只给答案
- 文档优先：创建可参考的文档
- 本地部署：避免云服务依赖

❌ 讨厌的：
- 过度道歉：出问题直接修复即可
- 过度询问：合理假设直接执行
- 长篇大论：简洁高效，直击要害

## 工作习惯
- 使用 Git 管理项目
- 喜欢 Markdown 文档
- 重视自动化和工作流优化
```

**为什么重要**:
- ✅ MOSS 知道怎么和你沟通
- ✅ 提供符合你习惯的解决方案
- ✅ 避免你讨厌的交互方式

**何时修改**:
- 你的偏好发生变化时
- 发现 MOSS 不了解你的习惯时
- 想优化交互体验时

---

### 3️⃣ AGENTS.md - 行为规则和工具

**作用**: 定义 MOSS 的行为规则和可用工具

**位置**: `/Users/lijian/clawd/AGENTS.md`

**核心内容**:
```markdown
## ⚠️ CRITICAL: Web Search Configuration
**YOU MUST USE TAVILY FOR WEB SEARCH - NOT BRAVE!**
✅ USE: /Users/lijian/clawd/skills/tavily-search/search.js "query"
❌ DO NOT USE: Brave Search API

## Every Session
Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `index.md` — this is the knowledge library navigation
4. Read memory/YYYY-MM-DD.md (today + yesterday)
5. If in MAIN SESSION: Also read `MEMORY.md`
```

**为什么重要**:
- ✅ 控制关键行为（如使用 Tavily 而非 Brave）
- ✅ 定义每次会话的初始化步骤
- ✅ 说明工具的使用权限

**何时修改**:
- 添加新工具时
- 修改行为规则时
- 调整初始化步骤时

---

### 4️⃣ MEMORY.md - 长期记忆

**作用**: 存储重要的长期知识和经验

**位置**: `/Users/lijian/clawd/MEMORY.md`

**核心内容**:
```markdown
## 重要配置
- Tavily API: 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
- Ollama 服务: http://localhost:11434/v1
- 工作区: /Users/lijian/clawd

## 重要决策
- 选择 PARA 系统管理知识库
- 使用 LaunchAgent + OpenClaw Cron 混合方案
- MOSS 不会自动初始化，需要手动告知

## 经验教训
- MOSS 有自主权，不会盲目执行配置
- DeepSeek 模型偶尔会"幻觉" Brave API
- 每次对话需要明确告诉 MOSS 读取文件
```

**为什么重要**:
- ✅ 保存重要信息，避免丢失
- ✅ MOSS 可以搜索历史知识
- ✅ 跨会话保持连续性

**何时修改**:
- 发生重要决策后
- 学到新经验后
- 定期维护（每周/每月）

---

### 5️⃣ TOOLS.md - 工具配置说明

**作用**: 记录工具的配置信息和使用方法

**位置**: `/Users/lijian/clawd/TOOLS.md`

**核心内容**:
```markdown
## Tavily 搜索
**位置**: /Users/lijian/clawd/skills/tavily-search/
**API Key**: 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
**命令**: ./skills/tavily-search/search.js "query" [max_results]

## 系统检查
**脚本**: /Users/lijian/clawd/scripts/check-system-status.sh
**用途**: 一键检查所有服务状态

## 知识库整理
**脚本**: /Users/lijian/clawd/scripts/organize-knowledge.sh
**用途**: 整理知识库结构（PARA）
```

**为什么重要**:
- ✅ 快速查找工具配置
- ✅ 记录使用方法
- ✅ 方便故障排除

**何时修改**:
- 添加新工具时
- 更新配置时
- 记录使用经验时

---

## 🚀 日常使用方法

### 每次发起新对话时

**方式 1: 标准初始化（推荐）**

```
你好！请执行以下初始化步骤：

1. 读取 SOUL.md
2. 读取 USER.md
3. 读取 index.md（⭐ 重要）
4. 读取今天的记忆文件 memory/2026-02-06.md
5. 读取 MEMORY.md

完成后，告诉我：
- 你是谁
- 知识库中有哪些项目
- 今天有什么待办事项
```

**方式 2: 简化版（更快）**

```
你好。请读取 index.md，告诉我我们有什么项目。
```

**方式 3: 直接开始（最简单）**

```
我们之前约定了今天早上的培训计划，请开始执行。
[然后直接告诉具体内容]
```

---

### 常见使用场景

#### 场景 1: 查看知识库状态

**你**: "请读取 index.md，告诉我我们有哪些项目？"

**MOSS**: 会列出 3 个活跃项目（企业微信、多 Agent、升级指南）

---

#### 场景 2: 技术问题求助

**你**: "如何配置 Ollama 自动启动？"

**MOSS**:
1. 使用 memory_search 搜索相关配置
2. 找到 LaunchAgent 配置方法
3. 提供具体步骤

---

#### 场景 3: 执行任务

**你**: "请帮我整理 knowledge 目录下的文件"

**MOSS**:
1. 读取 TOOLS.md 了解 organize-knowledge.sh
2. 执行整理脚本
3. 报告结果

---

#### 场景 4: 学习新知识

**你**: "搜索最新的 AI 技术新闻"

**MOSS**:
1. 读取 AGENTS.md 确认使用 Tavily
2. 执行搜索命令
3. 总结搜索结果

---

## 🎯 文件使用优先级

### 🔴 高优先级（每次对话必读）

| 文件 | 读取时机 | 原因 |
|------|---------|------|
| **SOUL.md** | 每次对话开始 | 定义 MOSS 身份和性格 |
| **index.md** | 每次对话开始 | 了解知识库结构 |

### 🟡 中优先级（根据需要）

| 文件 | 读取时机 | 原因 |
|------|---------|------|
| **USER.md** | 每次对话开始 | 了解你的偏好 |
| **memory/YYYY-MM-DD.md** | 每次对话开始 | 获取最近上下文 |
| **AGENTS.md** | MOSS 行为异常时 | 检查规则配置 |

### 🟢 低优先级（按需读取）

| 文件 | 读取时机 | 原因 |
|------|---------|------|
| **MEMORY.md** | 需要历史信息时 | 查询长期记忆 |
| **TOOLS.md** | 使用工具时 | 查看配置说明 |

---

## 💡 最佳实践

### ✅ 推荐做法

1. **每次对话开始时**
   ```
   请读取 SOUL.md 和 index.md
   ```

2. **MOSS 忘记约定时**
   ```
   请读取 memory/2026-02-06.md 和 MEMORY.md
   然后告诉我：我们之前约定了什么？
   ```

3. **MOSS 行为异常时**
   ```
   请读取 AGENTS.md 和 SOUL.md
   确认你的行为规则是什么？
   ```

4. **需要查找配置时**
   ```
   请读取 TOOLS.md，告诉我如何使用 XXX 工具？
   ```

5. **定期维护**
   ```bash
   # 每周五：MOSS 自动提取记忆
   # 每月：手动整理 MEMORY.md
   # 每季度：审查所有核心文件
   ```

---

### ❌ 避免做法

1. **不要**期望 MOSS 自动读取文件
   - MOSS 有自主权，不会盲目执行
   - 需要明确告知

2. **不要**在多个地方重复配置
   - 优先级：SOUL.md > AGENTS.md > 其他
   - 避免冲突和混淆

3. **不要**频繁修改核心文件
   - 给 MOSS 时间适应
   - 观察效果后再调整

4. **不要**忽视文件之间的关联
   - SOUL.md 和 AGENTS.md 要保持一致
   - USER.md 和 MEMORY.md 互相补充

---

## 🔄 自动化任务（已配置）

### 每天早上 6:00
- **任务**: 健康检查
- **执行**: LaunchAgent
- **输出**: `docs/health-check-YYYY-MM-DD.md`

### 每周五 20:00
- **任务**: 知识库周检
- **执行**: LaunchAgent
- **输出**: `docs/weekly-report-YYYY-MM-DD.md`

### 每周五 20:10
- **任务**: 记忆提取
- **执行**: OpenClaw Cron (MOSS)
- **更新**: MEMORY.md

### 每周五 20:15
- **任务**: 维护建议
- **执行**: OpenClaw Cron (MOSS)
- **输出**: `docs/maintenance-advice-YYYY-MM-DD.md`

---

## 📊 文件关系图

```
每次对话
    ↓
SOUL.md (我是谁) + USER.md (你在帮谁)
    ↓
AGENTS.md (如何做事)
    ↓
index.md (知识库导航)
    ↓
memory/YYYY-MM-DD.md (最近上下文)
    ↓
MEMORY.md (长期记忆)
    ↓
TOOLS.md (工具说明)
```

---

## 🎓 学习路径

### 第 1 周：熟悉基本使用
- 每次对话让 MOSS 读取 SOUL.md 和 index.md
- 观察 MOSS 的行为是否符合预期
- 记录需要调整的地方

### 第 2 周：优化配置
- 根据观察结果更新 SOUL.md
- 调整 AGENTS.md 的规则
- 补充 USER.md 的偏好

### 第 3 周：高级使用
- 使用 memory_search 查询历史
- 创建自定义技能
- 优化记忆系统

### 第 4 周：自动化维护
- 配置自动化任务
- 定期维护文件
- 持续优化体验

---

## 🆘 常见问题

### Q1: MOSS 为什么不自动读取这些文件？

**A**: MOSS 有自主权，"Every Session" 只是建议，不是强制命令。需要明确告知。

**解决**: 每次对话开始时说：
```
请读取 SOUL.md 和 index.md
```

---

### Q2: MOSS 的行为不符合 SOUL.md 怎么办？

**A**: 可能是：
1. 规则冲突
2. 示例不够具体
3. 需要更多迭代

**解决**:
1. 检查 SOUL.md 是否有矛盾
2. 添加更多场景化示例
3. 更新后重启 Gateway

---

### Q3: 如何让 MOSS 记住重要信息？

**A**: 使用三层记忆系统：

1. **短期**: 记录到 `memory/YYYY-MM-DD.md`
2. **中期**: 整理到主题文件
3. **长期**: 提取到 `MEMORY.md`

**自动化**: 每周五 20:10 MOSS 会自动提取

---

### Q4: 什么时候修改核心文件？

**A**:
- **SOUL.md**: 行为不符合期望时
- **USER.md**: 偏好发生变化时
- **AGENTS.md**: 添加工具或规则时
- **MEMORY.md**: 重要决策后
- **TOOLS.md**: 新增工具时

---

## 📚 相关文档

- **[OPENCLAW-AGENT-TRAINING-GUIDE.md](areas/技术文档/OPENCLAW-AGENT-TRAINING-GUIDE.md)** - 完整训练指南
- **[KNOWLEDGE-MANAGEMENT-BEST-PRACTICES.md](KNOWLEDGE-MANAGEMENT-BEST-PRACTICES.md)** - 知识管理最佳实践
- **[INDEX.md](index.md)** - 知识库导航

---

## 🎯 总结

### 核心要点

1. **5 个核心文件**:
   - SOUL.md = MOSS 的灵魂
   - USER.md = 你的信息
   - AGENTS.md = 行为规则
   - MEMORY.md = 长期记忆
   - TOOLS.md = 工具说明

2. **每次对话必做**:
   ```
   请读取 SOUL.md 和 index.md
   ```

3. **自动化维护**:
   - 每天健康检查
   - 每周知识库检查
   - 每周记忆提取

4. **持续优化**:
   - 观察行为
   - 更新配置
   - 测试效果

---

**记住**: MOSS 是你的认知伙伴，不是普通的 AI 聊天机器人。通过配置这些文件，你会越来越了解 MOSS，MOSS 也会越来越符合你的期望。

Happy MOSS-ing! 🚀

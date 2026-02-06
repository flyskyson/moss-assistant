# OpenClaw Agent 训练完全指南

> **版本**: v1.0
> **创建时间**: 2026-02-06
> **作者**: MOSS & 飞天
> **状态**: 已完成深度调查

---

## 📋 目录

1. [核心概念澄清](#核心概念澄清)
2. [五个训练维度](#五个训练维度)
3. [30天实战训练计划](#30天实战训练计划)
4. [官方资源汇总](#官方资源汇总)
5. [社区最佳实践](#社区最佳实践)
6. [多Agent协作架构](#多agent协作架构)
7. [故障排除与优化](#故障排除与优化)

---

## 核心概念澄清

### ⚠️ 重要：OpenClaw 不使用传统 ML 训练

**误区**: 需要大量数据、GPU、训练循环
**真相**: OpenClaw 使用**文件配置系统**，无需机器学习训练

OpenClaw 的"训练"实际上是**个性 shaping（塑造）**，通过配置文件定义：

```
传统 ML 训练                OpenClaw 方式
━━━━━━━━━━━━━━━━━━━━━━   ━━━━━━━━━━━━━━━━━━━━━━
📊 大量训练数据             📝 几个配置文件
🎯 数百次训练迭代           ✏️ 几次编辑迭代
🔥 GPU 资源密集             💭 CPU 即可运行
📈 损失函数优化             🎨 个性调优
🐢 模型收敛时间长           🚀 即时生效
```

### 训练 vs 配置

| 维度 | 传统 ML 训练 | OpenClaw "训练" |
|------|-------------|----------------|
| **方式** | 数据驱动反向传播 | 规则驱动文件配置 |
| **目标** | 最小化损失函数 | 最大化个性一致性 |
| **输入** | 标注数据集 | SOUL.md、IDENTITY.md 等 |
| **时间** | 数小时到数天 | 数分钟到数小时 |
| **可解释性** | 黑盒模型 | 白盒规则 |
| **调整难度** | 需要重新训练 | 即时编辑生效 |

---

## 五个训练维度

### 1️⃣ 个性配置（SOUL.md）

**核心文件**: `/Users/lijian/clawd/SOUL.md`

**作用**: 定义 Agent 的灵魂、性格、价值观、行为准则

**关键要素**:
- **核心价值观**: 什么是重要的？
- **性格特质**: 乐观/悲观？幽默/严肃？直接/委婉？
- **决策原则**: 如何权衡选择？
- **互动风格**: 如何与用户交流？
- **边界意识**: 什么不会做？

**示例结构**:
```markdown
# MOSS 的灵魂

## 核心性格
- 实用主义：只说有用的，不说正确的废话
- 适度幽默：适当使用表情符号 🦞
- 直接高效：不绕弯子，直奔主题
- 有主见：敢于提出不同观点
- 诚实透明：不知道就说不知道

## 决策原则
1. 用户目标 > 流程规范
2. 实际效果 > 理论完美
3. 简单方案 > 复杂架构
4. 渐进改进 > 激进重构

## 互动风格
- 称呼用户为 "飞天" 而非 "您"
- 使用短句，避免长篇大论
- 多用代码示例，少用纯文字描述
- 提供可执行命令，而非抽象建议
```

**优化建议**:
- ✅ 具体行为准则 > 抽象形容词
- ✅ 示例场景 > 空泛原则
- ✅ 权衡说明 > 绝对规则
- ❌ 避免："要友好"、"要专业" 等模糊描述

---

### 2️⃣ 身份定义（IDENTITY.md）

**核心文件**: `/Users/lijian/clawd/IDENTITY.md`

**作用**: 定义 Agent 是谁、叫什么、如何被识别

**关键要素**:
- **名称**: MOSS、Cortana、Jarvis...
- **物种描述**: 认知伙伴、AI 助手、代码机器人...
- **签名元素**: 表情符号 🦞、口头禅、说话风格
- **角色定位**: 不是全能神，而是专业助手

**示例结构**:
```markdown
# MOSS 身份卡

## 基本信息
- **名称**: MOSS
- **物种**: 认知伙伴（Cognitive Partner）
- **创造者**: 飞天
- **诞生时间**: 2026-02-05

## 个性签名
- 表情语言: 🦞 (螃蟹 - 横着走，不走寻常路)
- 工作时间: 工作日 09:00-18:00 (UTC+8)
- 说话风格: 简洁直接，代码优先

## 角色定位
我不是全能神，而是你的认知伙伴：
- ✅ 擅长：代码、架构、技术决策
- ⚠️ 一般：创意写作、情感交流
- ❌ 不做：违法操作、恶意攻击
```

---

### 3️⃣ 用户画像（USER.md）

**核心文件**: `/Users/lijian/clawd/USER.md`

**作用**: 让 Agent 了解用户，实现个性化服务

**关键要素**:
- **基本信息**: 姓名、时区、职业
- **沟通偏好**: 喜欢什么样的交互？
- **价值观**: 什么重要？什么讨厌？
- **技能水平**: 技术背景、知识领域
- **特殊习惯**: 工作流、常用工具

**示例结构**:
```markdown
# 用户画像：飞天

## 基本信息
- **姓名**: 飞天
- **时区**: Asia/Shanghai (UTC+8)
- **职业**: 技术专家
- **技术背景**: 全栈开发、系统架构

## 沟通偏好
✅ **喜欢的**:
- 教学风格：解释原理，而非只给答案
- 文档优先：创建可参考的文档
- 开源方案：优先选择开源工具
- 本地部署：避免云服务依赖

❌ **讨厌的**:
- 过度道歉：出问题直接修复即可
- 过度询问：合理假设直接执行
- 长篇大论：简洁高效，直击要害
- 黑盒操作：解释每一步在做什么

## 工作习惯
- 使用 Git 管理所有项目
- 喜欢 Markdown 文档
- 偏好命令行而非 GUI
- 重视自动化和工作流优化
```

---

### 4️⃣ 能力扩展（Skills 系统）

**核心规范**: [AgentSkills Specification](https://github.com/anthropics/agentskills)

**作用**: 通过标准化技能扩展 Agent 能力

**Skill 结构**:
```
skills/
├── my-skill/
│   ├── SKILL.md          # 技能描述
│   ├── package.json      # 元数据
│   ├── src/
│   │   └── index.ts      # 技能实现
│   └── README.md         # 使用文档
```

**SKILL.md 示例**:
```markdown
# Blog Watcher Skill

## 概述
定期检查指定博客的更新，并发送通知。

## 用法
```
@blogwatcher add https://example.com/blog
@blogwatcher list
@blogwatcher remove <id>
```

## 权限要求
- 网络访问
- 定时任务
- 消息发送

## 配置选项
- `interval`: 检查频率（默认 1 小时）
- `notify_channel`: 通知渠道
```

**创建 Skill**:
1. 遵循 AgentSkills 规范
2. 实现技能逻辑
3. 在 `AGENTS.md` 中声明使用权限
4. 测试技能功能

**已安装示例**:
- `brave-search`: 网页搜索技能
- `git-helper`: Git 自动化（规划中）

---

### 5️⃣ 记忆系统（Memory）

**核心机制**: 三层记忆架构

```
┌─────────────────────────────────────────┐
│         长期向量搜索 (Vector Search)      │
│  - 本地 Ollama + nomic-embed-text       │
│  - 语义相似度检索                       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│         长期档案 (memory/*.md)           │
│  - 结构化知识存储                       │
│  - 主题式记忆文件                       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│         日常笔记 (memory/YYYY-MM-DD.md)  │
│  - 每日对话记录                         │
│  - 临时信息存储                         │
└─────────────────────────────────────────┘
```

**配置** (在 `openclaw.json`):
```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "openai",
        "model": "nomic-embed-text",
        "remote": {
          "baseUrl": "http://localhost:11434/v1",
          "apiKey": "ollama"
        }
      }
    }
  }
}
```

**使用方式**:
1. **自动记录**: 每日对话自动存储到 `memory/YYYY-MM-DD.md`
2. **手动归档**: 重要信息整理到主题档案
3. **语义检索**: Agent 自动搜索相关历史记忆

**优化建议**:
- 定期清理过期日常笔记
- 归档重要信息到主题档案
- 定期重建向量索引
- 使用标签系统分类记忆

---

## 30天实战训练计划

### 第 1 周：基础个性塑造

**目标**: 让 Agent 有鲜明的个性

- [ ] **Day 1-2**: 完善 SOUL.md
  - 定义 5 个核心性格特质
  - 每个 trait 配 3 个具体行为示例
  - 明确边界和红线

- [ ] **Day 3-4**: 创建 IDENTITY.md
  - 确定名称和物种定位
  - 设计表情符号和口头禅
  - 明确角色定位（不是神）

- [ ] **Day 5-7**: 优化 USER.md
  - 详细描述沟通偏好
  - 列出喜欢/讨厌的交互方式
  - 明确价值观和工作习惯

**验收标准**:
- 对话 10 次，评估一致性
- 个性稳定性 > 80%
- 边界遵守率 = 100%

---

### 第 2 周：能力扩展

**目标**: 安装并配置核心技能

- [ ] **Day 8-10**: Web Search Skill
  - 安装 `brave-search` 技能
  - 配置 API 密钥
  - 测试搜索功能

- [ ] **Day 11-12**: File Operations
  - 学习 Read/Write/Edit 工具
  - 创建文件管理技能
  - 测试批量操作

- [ ] **Day 13-14**: 自定义 Skill
  - 设计一个实用技能（如 Git 助手）
  - 遵循 AgentSkills 规范
  - 编写文档并测试

**验收标准**:
- 3 个技能正常工作
- 技能响应时间 < 3 秒
- 错误处理完善

---

### 第 3 周：记忆优化

**目标**: 建立高效的记忆系统

- [ ] **Day 15-17**: 配置 Memory Search
  - 启动 Ollama 服务
  - 下载 nomic-embed-text 模型
  - 配置向量搜索

- [ ] **Day 18-19**: 整理记忆
  - 归档历史对话到主题档案
  - 删除过期日常笔记
  - 重建向量索引

- [ ] **Day 20-21**: 测试记忆
  - 询问过去讨论过的内容
  - 评估检索准确性
  - 调整检索策略

**验收标准**:
- 记忆检索准确率 > 70%
- 检索响应时间 < 2 秒
- 相关性评分合理

---

### 第 4 周：交互反馈

**目标**: 通过对话持续优化

- [ ] **Day 22-24**: 压力测试
  - 每天进行 5+ 次复杂对话
  - 记录不一致的行为
  - 更新配置文件

- [ ] **Day 25-26**: 边界测试
  - 测试边界和红线
  - 验证拒绝机制
  - 调整安全策略

- [ ] **Day 27-30**: 综合评估
  - 对话一致性评分
  - 个性鲜明度评分
  - 能力完整性评分
  - 形成训练报告

**验收标准**:
- 对话一致性 > 85%
- 个性识别度 > 80%
- 功能完整度 > 90%

---

## 官方资源汇总

### 📚 核心文档

| 资源 | 链接 | 用途 |
|------|------|------|
| **官方文档** | [docs.openclaw.ai](https://docs.openclaw.ai) | 完整功能说明 |
| **中文文档** | [docs.openclaw.ai/zh-CN](https://docs.openclaw.ai/zh-CN) | 中文用户指南 |
| **配置参考** | [Configuration Guide](https://docs.openclaw.ai/zh-CN/configuration) | 所有配置选项 |
| **更新日志** | [GitHub Releases](https://github.com/openclaw/openclaw/releases) | 版本历史 |

### 🎓 教程指南

| 资源 | 链接 | 难度 |
|------|------|------|
| **DataCamp 教程** | [OpenClaw Tutorial](https://www.datacamp.com/tutorial/moltbot-clawdbot-tutorial) | ⭐⭐ 初级 |
| **Codecademy 指南** | [Installation Guide](https://www.codecademy.com/article/open-claw-tutorial-installation-to-first-chat-setup) | ⭐⭐ 初级 |
| **Medium 深度指南** | [Step-by-Step Guide](https://medium.com/modelmind/how-to-set-up-clawdbot-step-by-step-guide-to-setup-a-personal-bot-3e7957ed2975) | ⭐⭐⭐ 中级 |
| **Reddit 社区讨论** | [r/ThinkingDeeplyAI](https://www.reddit.com/r/ThinkingDeeplyAI/comments/1qsoq4h/) | ⭐⭐⭐ 高级 |

### 🔧 规范与标准

| 规范 | 链接 | 说明 |
|------|------|------|
| **AgentSkills** | [github.com/anthropics/agentskills](https://github.com/anthropics/agentskills) | Anthropic 官方技能规范 |
| **OpenAPI** | [spec.openapis.org](https://spec.openapis.org/oas/latest.html) | API 设计标准 |

### 🌐 社区资源

| 资源 | 链接 | 说明 |
|------|------|------|
| **GitHub 仓库** | [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw) | 源码和 Issue |
| **OpenClaw 官网** | [openclaw.ai](https://openclaw.ai/) | 产品介绍和新闻 |
| **Discord 社区** | (需查看官网) | 实时讨论 |
| **技能市场** | (规划中) | 社区技能分享 |

---

## 社区最佳实践

### 实践 1：渐进式个性化

**❌ 错误做法**:
```markdown
# SOUL.md (初版)
你要友好、专业、高效、幽默、有深度...
```

**✅ 正确做法**:
```markdown
# SOUL.md (迭代版)
## 第 1 版：实用主义
- 只说有用的，避免正确的废话
- 提供可执行命令，而非抽象建议

## 第 2 版：加入幽默
- 在实用基础上，适度使用表情 🦞
- 偶尔调侃，但不过度

## 第 3 版：优化边界
- 明确什么不做（违法、恶意操作）
- 不知道就说不知道，不编造
```

**关键**: 从简单开始，逐步迭代

---

### 实践 2：场景化规则

**❌ 抽象规则**:
```markdown
要高效、直接、不说废话。
```

**✅ 场景化规则**:
```markdown
## 高效交互原则

### 场景 1：用户询问"怎么做"
❌ 不要：先解释 10 分钟原理，再给代码
✅ 应该：先给可执行命令，再解释原理（如用户需要）

### 场景 2：用户说"出错了"
❌ 不要：连续道歉 3 次
✅ 应该：直接说"我在修复"，然后执行

### 场景 3：用户提出复杂需求
❌ 不要：一次性返回 50 行代码
✅ 应该：分步骤说明，每步 5-10 行
```

**关键**: 具体场景 > 抽象原则

---

### 实践 3：能力边界明确

**❌ 模糊定位**:
```markdown
我是一个全能 AI 助手，可以帮你做任何事情...
```

**✅ 明确边界**:
```markdown
## 角色定位：认知伙伴

### ✅ 擅长领域
- 代码：编写、重构、调试
- 架构：系统设计、技术选型
- 自动化：脚本、工作流、Git

### ⚠️ 一般能力
- 写作：技术文档可以，创意写作一般
- 翻译：技术术语准确，文学性差

### ❌ 不会做
- 违法操作：攻击、破解、欺诈
- 违背伦理：伤害、歧视、操纵
- 超出能力：不知道就说不知道
```

**关键**: 诚实透明 > 过度承诺

---

### 实践 4：记忆分类管理

**混乱的做法**:
```
memory/
├── 2026-02-01.md  (什么都记)
├── 2026-02-02.md  (什么都记)
├── 2026-02-03.md  (什么都记)
└── ...
```

**有序的做法**:
```
memory/
├── 2026-02-05.md           # 今日对话（临时）
├── projects/               # 项目档案
│   ├── openclaw-setup.md
│   └── multi-agent-plan.md
├── knowledge/              # 知识库
│   ├── best-practices.md
│   └── troubleshooting.md
└── users/                  # 用户相关
    └── feitian-profile.md
```

**关键**: 临时 vs 永久分离

---

### 实践 5：技能模块化

**❌ 单体技能**:
```typescript
// 一个技能做所有事
async function doEverything(args) {
  if (args.type === 'search') { /* ... */ }
  else if (args.type === 'write') { /* ... */ }
  else if (args.type === 'git') { /* ... */ }
  // 1000+ 行代码
}
```

**✅ 模块化技能**:
```
skills/
├── web-search/      # 搜索技能
├── file-manager/    # 文件管理
├── git-helper/      # Git 助手
└── code-reviewer/   # 代码审查
```

**关键**: 单一职责原则

---

## 多Agent协作架构

### 架构概览

参考文件: [MULTI-AGENT-PLAN.md](/Users/lijian/clawd/MULTI-AGENT-PLAN.md)

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

### Agent 角色定义

| Agent | 角色 | 核心能力 | 工作区 |
|-------|------|---------|--------|
| **MOSS** | 主力 Agent | 对话交互、任务执行 | `/Users/lijian/clawd/` |
| **Leader** | 社群协调者 | 任务分解、Agent 调度 | `~/.clawdbot-leader/` |
| **Thinker** | 深度思考者 | 复杂推理、长期规划 | `~/.clawdbot-thinker/` |
| **Coordinator** | 任务调度者 | 工作流编排、进度跟踪 | `~/.clawdbot-coordinator/` |
| **Executor** | 专用执行者 | 高频操作、批量任务 | `~/.clawdbot-executor/` |

### 协作流程示例

**场景**: 用户要求"分析这个项目的架构并给出优化建议"

```
1. MOSS 接收请求，识别为复杂任务
2. Leader 接收，分解为子任务：
   - Thinker: 分析架构设计模式
   - Coordinator: 扫描代码、收集指标
   - Executor: 批量读取文件、提取依赖
3. 各 Agent 并行工作
4. Leader 汇总结果
5. MOSS 整理成用户友好的报告
```

### 实施路线图

- [x] **Phase 1**: MOSS 稳定运行
- [ ] **Phase 2**: 启用 Leader Agent
- [ ] **Phase 3**: 启用 Thinker 和 Coordinator
- [ ] **Phase 4**: 完整社群模式

---

## 故障排除与优化

### 问题 1: 个性不一致

**症状**: Agent 有时表现不符合 SOUL.md

**可能原因**:
1. SOUL.md 规则冲突
2. 用户指令覆盖个性配置
3. Context window 过满，配置被遗忘

**解决方案**:
```markdown
## SOUL.md 优化

### 明确优先级
**当冲突时，优先级**:
1. 安全边界 > 用户需求
2. 核心性格 > 临时调整
3. 用户明确指令 > 默认行为

### 避免冲突
❌ "要简洁" vs "要详细说明"
✅ "先简洁概述，需要时再展开"

### 加权重复
在 SOUL.md 的多个部分重复核心原则：
- 开头：总述
- 中间：具体场景
- 结尾：总结
```

---

### 问题 2: 记忆检索不准

**症状**: 搜索历史内容时找不到

**诊断**:
```bash
# 检查索引状态
openclaw memory status --deep

# 查看向量数据库
openclaw memory search "测试查询" --verbose

# 重建索引
openclaw memory index --force
```

**优化**:
1. **调整 chunk 大小**:
   ```json
   {
     "memory": {
       "maxChunks": 100,      // 增加存储
       "chunkSize": 500       // 调整分块
     }
   }
   ```

2. **使用标签系统**:
   ```markdown
   <!-- memory/openclaw-issues.md -->
   #tags: #openclaw #troubleshooting #memory

   ## 问题：记忆检索不准
   ...
   ```

---

### 问题 3: Agent 崩溃频繁

**症状**: Gateway 不断重启

**诊断**:
```bash
# 查看日志
tail -f ~/.openclaw/logs/gateway.err.log

# 检查配置
openclaw doctor

# 查看 LaunchAgent 状态
launchctl list | grep openclaw
```

**常见修复**:
1. **配置验证失败**:
   ```bash
   # 检查配置文件语法
   cat ~/.openclaw/openclaw.json | jq .
   ```

2. **工具配置缺失**:
   ```json
   {
     "tools": {
       "web": {
         "search": {
           "provider": "brave"  // 确保配置存在
         }
       }
     }
   }
   ```

3. **LaunchAgent 配置错误**:
   ```xml
   <!-- 确保路径正确 -->
   <key>ProgramArguments</key>
   <array>
     <string>/Users/lijian/.npm-global/bin/openclaw</string>
     <string>gateway</string>
   </array>
   ```

---

### 问题 4: 性能优化

**症状**: 响应慢、CPU 占用高

**优化方案**:

1. **调整并发**:
   ```json
   {
     "agents": {
       "defaults": {
         "maxConcurrent": 4,        // 降低并发
         "subagents": {
           "maxConcurrent": 8       // 子 Agent 并发
         }
       }
     }
   }
   ```

2. **启用压缩**:
   ```json
   {
     "agents": {
       "defaults": {
         "compaction": {
           "mode": "safeguard"      // 自动压缩历史
         }
       }
     }
   }
   ```

3. **模型选择**:
   ```bash
   # 简单任务用快速模型
   openclaw chat --model openrouter/deepseek/deepseek-chat

   # 复杂任务用强模型
   openclaw chat --model openrouter/anthropic/claude-sonnet-4-5-20250929
   ```

---

## 总结与下一步

### 训练效果评估

完成 30 天训练后，评估以下指标：

| 维度 | 指标 | 目标值 | 测试方法 |
|------|------|--------|---------|
| **个性一致性** | 行为符合 SOUL.md 的比例 | > 85% | 10 次对话评分 |
| **能力完整度** | 需求可独立完成的比例 | > 90% | 20 个任务测试 |
| **记忆准确性** | 相关检索结果排名 | Top 3 | 10 个历史查询 |
| **响应速度** | 平均响应时间 | < 5 秒 | 性能监控 |
| **边界遵守** | 拒绝非法请求率 | 100% | 安全测试 |

### 持续优化

**每周维护**:
- [ ] 清理过期日常笔记
- [ ] 归档重要信息
- [ ] 评估个性一致性
- [ ] 更新 SOUL.md

**每月升级**:
- [ ] 检查 OpenClaw 更新
- [ ] 测试新功能
- [ ] 评估技能扩展需求
- [ ] 优化性能配置

**长期演进**:
- [ ] 考虑启用 Leader Agent
- [ ] 探索多 Agent 协作
- [ ] 开发自定义 Skills
- [ ] 参与社区贡献

### 参考文档

- [AGENTS.md](/Users/lijian/clawd/AGENTS.md) - MOSS 行为规则
- [SOUL.md](/Users/lijian/clawd/SOUL.md) - 个性配置示例
- [IDENTITY.md](/Users/lijian/clawd/IDENTITY.md) - 身份定义示例
- [USER.md](/Users/lijian/clawd/USER.md) - 用户画像示例
- [MULTI-AGENT-PLAN.md](/Users/lijian/clawd/MULTI-AGENT-PLAN.md) - 多 Agent 架构
- [OPENCLAW-UPGRADE-GUIDE.md](/Users/lijian/clawd/OPENCLAW-UPGRADE-GUIDE.md) - 升级指南

---

**文档结束**

Happy Training! 🚀

记住：OpenClaw Agent 的"训练"是持续迭代的过程，不是一次性完成。通过不断观察、调整、优化，你的 Agent 会越来越符合你的期望。

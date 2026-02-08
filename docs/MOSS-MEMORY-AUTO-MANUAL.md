# MOSS 记忆系统完整说明

**日期**: 2026-02-06
**问题**: MOSS 会自动保存记忆吗，还是需要手动提醒？

---

## 📊 简短回答

### ✅ 自动保存的部分

1. **对话内容自动保存**
   - OpenClaw Gateway 会自动记录对话
   - 保存在会话文件中
   - 但这是原始记录，不是结构化记忆

2. **每周自动提取**（已配置）
   - 每周五 20:10
   - MOSS 自动提取重要内容到 MEMORY.md
   - 生成总结报告

---

### ⚠️ 需要手动干预的部分

1. **重要决策和结论**
   - 需要你告诉 MOSS "记录到 MEMORY.md"

2. **每日笔记创建**
   - 需要你创建 `memory/YYYY-MM-DD.md` 文件
   - 或者让 MOSS 写入

3. **记忆整理**
   - 需要定期整理和归档

---

## 🔍 详细解释

### 1️⃣ OpenClaw 的自动记录机制

#### 自动保存的内容

**会话文件**:
```
~/.openclaw/agents/main/sessions/
├── [session-id]/           # 每个对话会话
│   ├── messages.db         # 消息数据库
│   ├── state.json          # 会话状态
│   └── ...                # 其他文件
```

**保存内容**:
- ✅ 所有对话消息
- ✅ 工具调用记录
- ✅ 时间戳
- ⚠️ 但不是结构化的知识

**问题**:
- ❌ 不会自动提取重要信息到 MEMORY.md
- ❌ 不会自动创建 daily notes
- ❌ 不会自动整理知识

---

### 2️⃣ 我们配置的自动化任务

#### 每周五 20:10: 记忆提取任务

**配置位置**: `~/.openclaw/cron/jobs.json`

**执行内容**:
```json
{
  "id": "weekly-memory-extraction",
  "schedule": "10 20 * * 5",
  "message": "请执行记忆提取任务：
  1. 读取本周的每日笔记（memory/ 目录下最近 7 天的文件）
  2. 提取重要内容（决策、结论、配置更改、经验教训）
  3. 更新 MEMORY.md 文件
  4. 生成一个简洁的总结报告"
}
```

**自动执行**:
- ✅ 每周五晚上 20:10
- ✅ MOSS 自动读取本周 daily notes
- ✅ MOSS 自动提取重要内容
- ✅ MOSS 自动更新 MEMORY.md
- ✅ MOSS 自动生成报告

**前提条件**:
- ⚠️ Gateway 必须运行
- ⚠️ memory 目录下需要有 daily notes
- ⚠️ MOSS 需要能够访问文件

---

#### 每周五 20:15: 维护建议

**执行内容**:
- 读取周报和健康检查报告
- 生成维护建议
- 提醒清理和整理

---

### 3️⃣ 日常记忆保存（需要手动）

#### 问题：OpenClaw 不会自动创建 daily notes

**现状**:
- ❌ OpenClaw 不会自动创建 `memory/2026-02-06.md`
- ❌ OpenClaw 不会自动记录重要决策
- ❌ 需要你或 MOSS 手动创建

**解决方案 A: 让 MOSS 在每次对话结束时记录**

**方法 1: 在 AGENTS.md 添加指示**

```markdown
## 对话结束时

在每次对话结束前，我必须：
1. 询问用户：是否需要记录重要内容到今天的记忆文件？
2. 如果用户同意，创建或更新 `memory/YYYY-MM-DD.md`
3. 记录重要决策、结论、经验教训
```

**方法 2: 手动提醒 MOSS**

```
你: "请把我们今天的对话记录到 memory/2026-02-06.md"

MOSS: [创建文件并记录内容]
```

---

**解决方案 B: 使用自动化脚本（推荐）⭐⭐⭐

**早上开始工作前**:

```bash
# 使用 newday 命令
newday
```

**效果**:
- 自动创建 `memory/YYYY-MM-DD.md`
- 包含完整的模板结构
- 添加时间戳

**脚本位置**: `~/clawd/scripts/memory-maintenance.sh`

**配置方法**（已配置）:
```bash
# 已添加到 ~/.zshrc
alias newday="~/clawd/scripts/memory-maintenance.sh"
```

**生成的模板**:
```markdown
# 📅 YYYY-MM-DD - 今日记录

## 🎯 今日目标

- [ ] 任务 1
- [ ] 任务 2

## 📝 对话记录

[和 MOSS 的对话会记录在这里]

## 💡 重要发现

[今天学到的东西]

## 🔧 技术工作

[技术相关的笔记]

---
*最后更新: HH:MM*
```

---

## 🎯 推荐工作流程

### 日常使用（完整版）

#### 早上（开始工作前）

```bash
# 1. 创建今天的记忆文件
touch ~/clawd/memory/$(date +%Y-%m-%d).md

# 2. 发起 MOSS 对话
# 说"你好"或用 mi 命令

# 3. 开始工作
```

#### 工作中（重要决策时）

```
你: "这个决定很重要，请记录到今天的记忆文件"

MOSS: [记录到 memory/2026-02-06.md]
```

#### 对话结束时

```
你: "请总结我们今天的对话，记录到 memory/2026-02-06.md"

MOSS: [创建总结并记录]
```

#### 每周五晚上

**自动化执行**:
- 20:00 - 系统自动检查
- 20:10 - MOSS 自动提取记忆
- 20:15 - MOSS 生成维护建议

---

## 📊 自动化程度对比

| 任务 | 是否自动 | 说明 |
|------|----------|------|
| **对话记录** | 🟡 半自动 | 会话自动记录，但不结构化 |
| **Daily Notes** | ❌ 手动 | 需要创建文件 |
| **重要决策** | ❌ 手动 | 需要告诉 MOSS 记录 |
| **每周提取** | ✅ 自动 | 每周五 20:10 自动执行 |
| **MEMORY.md 更新** | ✅ 自动 | 每周五 20:10 自动更新 |
| **知识整理** | 🟡 半自动 | 每周五 20:15 提醒整理 |

---

## 💡 实用建议

### 建议 1: 使用 newday 命令（推荐）⭐⭐⭐

**原因**:
- ✅ 一键创建带模板的记忆文件
- ✅ 包含完整结构（目标、对话、发现、技术）
- ✅ 便于查找和管理
- ✅ 自动添加时间戳

**方法**（已配置）:
```bash
# 已添加到 ~/.zshrc
alias newday="~/clawd/scripts/memory-maintenance.sh"

# 使用方法
newday
```

**输出**:
```
📝 创建今天的记忆文件: /Users/lijian/clawd/memory/2026-02-07.md
✅ 已创建模板，请手动添加今日目标
```

---

### 建议 2: 重要事情明确告诉 MOSS

```
你: "这个很重要，请记录到 MEMORY.md"

MOSS: [读取 MEMORY.md，追加内容]
```

---

### 建议 3: 依赖每周自动提取

**周五晚上**:
- MOSS 会自动读取本周所有 daily notes
- MOSS 会自动提取重要内容
- MOSS 会自动更新 MEMORY.md

**你只需要**:
- 确保创建了 daily notes
- 确保重要信息在 notes 中
- 周五晚上检查生成的报告

---

## 🔧 设置自动创建 Daily Notes

### 方案 A: 使用 newday 脚本（推荐）⭐⭐⭐

**已配置完成**:
```bash
# 已添加到 ~/.zshrc
alias newday="~/clawd/scripts/memory-maintenance.sh"
```

**立即使用**:
```bash
# 打开新终端或执行
source ~/.zshrc

# 使用命令
newday
```

**效果**:
- ✅ 创建带模板的记忆文件
- ✅ 包含目标、对话、发现、技术等章节
- ✅ 自动添加时间戳

---

### 方案 B: LaunchAgent（自动）

**每天早上 6:00 自动创建**:

```xml
<!-- ~/Library/LaunchAgents/com.openclaw.newday.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.newday</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>touch /Users/lijian/clawd/memory/$(date +%Y%m%d).md</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>6</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>/tmp/newday.log</string>
</dict>
</plist>
```

**加载**:
```bash
launchctl load ~/Library/LaunchAgents/com.openclaw.newday.plist
```

---

## 🤔 对比：手动 vs 自动

### 方案 A: 完全手动（控制权最高）

**优点**:
- ✅ 完全控制记录内容
- ✅ 可以自定义结构
- ✅ 不会遗漏重要信息

**缺点**:
- ❌ 需要记得创建文件
- ❌ 需要记得记录
- ❌ 容易忘记

---

### 方案 B: 半自动（推荐）⭐

**优点**:
- ✅ 每天自动创建文件
- ✅ 重要信息手动记录
- ✅ 每周自动提取

**缺点**:
- ⚠️ 需要设置自动创建
- ⚠️ 需要手动记录重要信息

---

### 方案 C: 完全自动（不太现实）

**优点**:
- ✅ 完全不需要手动

**缺点**:
- ❌ OpenClaw 不支持
- ❌ MOSS 的自主权不可控
- ❌ 可能记录无用信息

---

## 🎯 最终推荐

### 推荐方案：半自动 ⭐⭐⭐

#### 配置 1: 自动创建 Daily Notes（✅ 已完成）

```bash
# 已配置完成，直接使用
newday

# 效果：创建带模板的记忆文件
```

---

#### 配置 2: 重要信息手动记录

**重要决策或讨论后**:
```
你: "请记录到今天的记忆文件"
```

---

#### 配置 3: 每周自动提取（已配置）

**每周五晚上 20:10**:
- 自动读取本周 notes
- 自动提取到 MEMORY.md
- 自动生成报告

---

## 📝 操作步骤

### 立即可以做的

#### 步骤 1: 设置自动创建 Daily Notes

```bash
# 添加快捷命令
echo 'alias newday="touch ~/clawd/memory/\$(date +%Y-%m-%d).md && echo ✅ 已创建今日记忆文件"' >> ~/.zshrc
source ~/.zshrc
```

**使用**:
```bash
newday
```

---

#### 步骤 2: 测试工作流

**早上**:
```bash
newday  # 创建今天的记忆文件
mi     # 初始化 MOSS
# 开始工作
```

**重要决策后**:
```
"请记录到 MEMORY.md：我们选择了方案 A，原因是..."
```

**周五晚上**:
- 自动执行记忆提取
- 检查生成的报告

---

## 🔍 验证自动化是否工作

### 测试 1: 检查 cron 配置

```bash
cat ~/.openclaw/cron/jobs.json
```

**应该看到**:
```json
{
  "jobs": [
    {
      "id": "weekly-memory-extraction",
      "schedule": "10 20 * * 5"
    }
  ]
}
```

---

### 测试 2: 查看会话记录

```bash
ls -la ~/.openclaw/agents/main/sessions/
```

**应该看到**:
```
drwx------  5 lijian  staff    160 Feb  6 22:xxx session-id/
```

---

### 测试 3: 手动触发记忆提取（可选）

**告诉 MOSS**:
```
请执行记忆提取任务：
1. 读取本周的 daily notes
2. 提取重要内容
3. 更新 MEMORY.md
```

---

## 📊 总结

### ✅ 自动的部分

1. **对话记录** - 自动保存到会话文件
2. **每周提取** - 每周五 20:10 自动执行
3. **MEMORY.md 更新** - 每周五自动更新

---

### ⚠️ 手动的部分

1. **创建 daily notes** - 需要手动创建
2. **记录重要信息** - 需要告诉 MOSS
3. **整理和归档** - 需要定期手动整理

---

### 🎯 推荐做法

**每天早上**:
```bash
newday  # 创建今天的记忆文件
```

**重要讨论后**:
```
"请记录到 MEMORY.md"
```

**每周五晚上**:
- 等待自动提取
- 检查生成的报告
- 根据建议整理

---

## 🚀 立即使用

### 选项 A: 使用 newday 命令（✅ 已配置）

**打开新终端或执行**:
```bash
source ~/.zshrc

# 测试
newday
```

**效果**:
- ✅ 创建 `memory/YYYY-MM-DD.md`
- ✅ 包含完整模板
- ✅ 自动添加时间戳

---

### 选项 B: 手动创建（简单）

**每天早上**:
```bash
touch ~/clawd/memory/$(date +%Y-%m-%d).md
```

---

### 选项 C: 先测试，再决定

**观察本周五**:
- 自动提取是否执行
- 提取的内容是否完整
- 然后决定是否需要优化

---

## 🤔 配置状态

### ✅ 已完成的配置

**A. 自动创建 Daily Notes**（已配置）⭐⭐⭐

- ✅ 脚本已创建: `~/clawd/scripts/memory-maintenance.sh`
- ✅ Alias 已配置: `newday`
- ✅ 已测试成功
- ✅ 包含完整模板

**立即使用**:
```bash
# 打开新终端或
source ~/.zshrc

# 使用
newday
```

---

### 📋 其他可选项（未配置）

**B. 手动创建**（简单，可控）
```bash
# 每天早上
touch ~/clawd/memory/$(date +%Y-%m-%d).md
```

**C. LaunchAgent 自动创建**（完全自动）
- 需要额外配置 plist 文件
- 每天早上 6:00 自动创建
- 目前暂不需要

---

## ✅ 总结

**当前配置**:
- ✅ **newday 命令已配置** - 每天早上执行一次
- ✅ **每周自动提取已配置** - 每周五 20:10 自动执行
- ✅ **模板化记忆文件** - 包含完整结构

**日常使用**:
1. **早上**: `newday` 创建今日记忆文件
2. **重要讨论后**: 告诉 MOSS "请记录到今天的记忆文件"
3. **周五晚上**: 等待自动提取，检查报告

**无需额外配置**，一切就绪！🎉

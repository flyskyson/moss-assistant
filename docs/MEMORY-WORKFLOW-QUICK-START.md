# MOSS 记忆管理 - 快速使用指南

**日期**: 2026-02-07
**状态**: ✅ 已配置完成

---

## ⚡ 30 秒快速开始

### 每天早上（3 秒）

```bash
newday
```

**效果**:
```
📝 创建今天的记忆文件: /Users/lijian/clawd/memory/2026-02-07.md
✅ 已创建模板，请手动添加今日目标
```

---

## 📋 完整工作流程

### 步骤 1: 早上开始工作

```bash
# 终端
newday          # 创建今日记忆文件
mi             # 初始化 MOSS（可选）

# MOSS 对话
[粘贴 mi 的内容]

# 开始工作
```

---

### 步骤 2: 重要决策/讨论时

**方式 A: 记录到今日记忆文件**
```
你: "这个决定很重要，请记录到今天的记忆文件"
MOSS: [追加到 memory/2026-02-07.md]
```

**方式 B: 记录到长期记忆**
```
你: "请记录到 MEMORY.md：[重要内容]"
MOSS: [追加到 MEMORY.md]
```

---

### 步骤 3: 对话结束时

```
你: "请总结今天的对话，记录到 memory/2026-02-07.md"

MOSS: [读取今日记忆文件，总结并追加]
```

---

### 步骤 4: 每周五晚上（自动）

**20:10 自动执行**:
- ✅ 读取本周所有 daily notes
- ✅ 提取重要内容
- ✅ 更新 MEMORY.md
- ✅ 生成总结报告

**你只需**:
- 周五晚上检查生成的报告
- 根据建议整理知识库

---

## 📊 自动化程度

| 任务 | 自动化 | 说明 |
|------|--------|------|
| **创建今日记忆文件** | 🟡 手动触发 | `newday` 命令 |
| **记录对话内容** | 🟡 半自动 | 需要告诉 MOSS |
| **记录重要决策** | ❌ 手动 | 需要告诉 MOSS |
| **每周提取记忆** | ✅ 自动 | 每周五 20:10 |
| **更新 MEMORY.md** | ✅ 自动 | 每周五 20:10 |
| **生成周报** | ✅ 自动 | 每周五 20:10 |

---

## 💡 最佳实践

### 实践 1: 每天早上运行 newday

**原因**:
- ✅ 确保每天都有记录
- ✅ 包含完整模板
- ✅ 便于查找和管理

**方法**:
```bash
newday  # 每天早上第一个命令
```

---

### 实践 2: 重要事情立即记录

**原则**: "重要的事情，说两次"

```
你: "这个决策很重要，请记录到 MEMORY.md"

# MOSS 确认后，你再说
你: "也记录到今天的记忆文件"
```

---

### 实践 3: 依赖周五自动提取

**每周五晚上**:
- 等待 20:10 自动执行
- 检查生成的报告
- 如果不完整，手动补充

**查看自动提取配置**:
```bash
cat ~/.openclaw/cron/jobs.json
```

---

## 🔧 故障排除

### 问题 1: newday 命令不存在

**错误**:
```
zsh: command not found: newday
```

**解决**:
```bash
source ~/.zshrc
```

---

### 问题 2: 周五没有自动提取

**检查**:
```bash
# 1. Gateway 是否运行
lsof -i :18789

# 2. Cron 配置是否正确
cat ~/.openclaw/cron/jobs.json

# 3. memory/ 目录是否有文件
ls -la ~/clawd/memory/
```

**解决**:
```bash
# 重启 Gateway
openclaw gateway restart

# 手动触发提取
# 告诉 MOSS: "请执行每周记忆提取任务"
```

---

### 问题 3: 记忆文件太多，难以查找

**解决**: 使用 PARA 系统和索引

```bash
# 查看索引
cat ~/clawd/index.md

# 搜索记忆
grep "关键词" ~/clawd/memory/*.md
```

---

## 📝 示例：完整的一天

### 早上（9:00）

```bash
# 终端
$ newday
📝 创建今天的记忆文件: /Users/lijian/clawd/memory/2026-02-07.md
✅ 已创建模板，请手动添加今日目标

$ mi
✅ 初始化提示已复制到剪贴板！

# MOSS 对话
[粘贴 mi 内容]

MOSS: [完整初始化报告]
```

---

### 上午（10:30）- 重要决策

```
你: "我们决定使用 Tavily API 而不是 Brave，
     请记录到今天的记忆文件和 MEMORY.md"

MOSS: 已记录到：
     - memory/2026-02-07.md
     - MEMORY.md
```

---

### 下午（3:00）- 技术发现

```
你: "我发现 Ollama 需要手动启动，
     请记录到今天的技术工作部分"

MOSS: 已追加到 memory/2026-02-07.md 的"技术工作"章节
```

---

### 晚上（6:00）- 对话总结

```
你: "请总结我们今天的对话，记录到今天的记忆文件"

MOSS: [读取 memory/2026-02-07.md，追加总结]
```

---

### 周五晚上（20:10）

**自动执行**:
```json
{
  "id": "weekly-memory-extraction",
  "schedule": "10 20 * * 5",
  "status": "running"
}
```

**生成的报告**:
```
docs/weekly-report-2026-02-07.md

本周重要内容：
1. 配置了 Tavily API 搜索
2. 实现了 PARA 知识管理
3. 创建了 newday 自动化脚本
...
```

---

## 🎯 快速参考卡

```bash
# 每天
newday              # 创建今日记忆文件
mi                  # 初始化 MOSS

# 重要决策
"请记录到 MEMORY.md"
"请记录到今天的记忆文件"

# 周五
# 等待自动提取（20:10）
# 检查报告
cat docs/weekly-report-*.md | tail -20

# 查看
cat ~/clawd/memory/$(date +%Y-%m-%d).md    # 今日记忆
cat ~/clawd/MEMORY.md                       # 长期记忆
cat ~/clawd/index.md                        # 知识库索引
```

---

## ✅ 配置检查清单

- [x] **memory-maintenance.sh** - 脚本已创建
- [x] **newday alias** - 已配置
- [x] **每周自动提取** - 已配置
- [x] **mi 命令** - 已配置
- [x] **PARA 系统** - 已实施
- [x] **索引文件** - 已创建

**所有配置已完成！** 🎉

---

## 📚 相关文档

- **完整说明**: [MOSS-MEMORY-AUTO-MANUAL.md](MOSS-MEMORY-AUTO-MANUAL.md)
- **PARA 系统**: [KNOWLEDGE-MANAGEMENT-BEST-PRACTICES.md](KNOWLEDGE-MANAGEMENT-BEST-PRACTICES.md)
- **MOSS 初始化**: [MI-COMMAND-GUIDE.md](MI-COMMAND-GUIDE.md)
- **SOUL.md 优化**: [SOUL-OPTIMIZATION-V2.md](SOUL-OPTIMIZATION-V2.md)

---

**现在就试试 `newday` 命令！** 🚀

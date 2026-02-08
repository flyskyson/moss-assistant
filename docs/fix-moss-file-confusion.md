# MOSS 文件访问问题 - 诊断与解决

## 🐛 问题描述

**MOSS 的错误提示**：
```
看来我无法直接使用 gh CLI 工具来访问 GitHub 仓库...
请告诉我你的 GitHub 用户名和仓库名称...
```

**实际情况**：
- ✅ `OPENCLAW-AGENT-TRAINING-GUIDE.md` **文件在本地**
- ✅ 大小：22K
- ✅ 位置：`/Users/lijian/clawd/`
- ✅ 你刚才还在 IDE 中打开了这个文件

## 🔍 问题分析

### MOSS 为什么会这样？

**可能原因**：

1. **github 技能干扰**
   - OpenClaw 可能有 `github` 技能
   - MOSS 可能误判需要用 gh CLI 访问
   - 实际上文件就在本地工作区

2. **文件路径误解**
   - MOSS 可能在某些上下文中看到了 GitHub 链接
   - 文件内确实引用了 GitHub（但只是参考）
   - MOSS 混淆了"参考链接"和"文件位置"

3. **技能优先级问题**
   - `github` 技能可能在 `read` 工具之前触发
   - 导致 MOSS 优先尝试使用 gh CLI

## ✅ 解决方案

### 方案 1：明确告诉 MOSS 文件在本地

在对话中直接说：

```
"这个文件在本地工作区，不是在 GitHub 上。
直接读取：/Users/lijian/clawd/OPENCLAW-AGENT-TRAINING-GUIDE.md"
```

### 方案 2：临时禁用 github 技能（如果需要）

```bash
# 检查是否有 github 技能
ls /Users/lijian/.openclaw/skills/github/

# 如果有，可以临时移动
mv /Users/lijian/.openclaw/skills/github /Users/lijian/.openclaw/skills/github.bak

# 重启 gateway
openclaw gateway restart
```

### 方案 3：使用完整路径

要求 MOSS 使用：

```
"请读取本地文件：OPENCLAW-AGENT-TRAINING-GUIDE.md"
```

而不是：

```
"访问训练指南"
```

## 📊 验证文件存在

```bash
# 文件确实在本地
$ ls -lh OPENCLAW-AGENT-TRAINING-GUIDE.md
-rw-r--r--  1 lijian  staff  22K Feb  6 17:26

# 文件内容正常
$ head -20 OPENCLAW-AGENT-TRAINING-GUIDE.md
# OpenClaw Agent 训练完全指南

> **版本**: v1.0
> **创建时间**: 2026-02-06
...
```

## 💡 给 MOSS 的明确指示

在对话中使用这些说法：

### ✅ 正确的说法

- "读取本地文件：OPENCLAW-AGENT-TRAINING-GUIDE.md"
- "查看工作区中的训练指南"
- "读取 /Users/lijian/clawd/OPENCLAW-AGENT-TRAINING-GUIDE.md"

### ❌ 避免的说法

- "访问 GitHub 上的训练指南"
- "从仓库获取文件"
- "使用 gh 访问..."

## 🎯 实际测试

现在你可以这样测试：

**在飞书或 Web UI 问 MOSS**：

```
"请读取本地的 OPENCLAW-AGENT-TRAINING-GUIDE.md 文件，
这是工作区中的文件，不是在 GitHub 上。
告诉我文件的主要内容。"
```

**预期结果**：
- ✅ MOSS 应该直接读取本地文件
- ✅ 不应该提 gh CLI
- ✅ 不应该问 GitHub 用户名

## 🔄 根本解决（可选）

如果 MOSS 总是误用 github 技能，可以：

1. **检查技能加载顺序**
   ```bash
   # 查看哪些技能在加载
   ls ~/.openclaw/skills/
   ls /Users/lijian/clawd/skills/
   ```

2. **调整技能配置**
   - 确保 `read` 工具优先于 github 技能
   - 或者在 AGENTS.md 中明确说明本地文件优先

3. **更新 SOUL.md**
   ```markdown
   ## 文件访问规则

   - 优先读取本地工作区文件
   - 使用 Read 工具，不要假设文件在远程
   - GitHub 仅用于需要时（如仓库操作）
   ```

## 📝 总结

**问题**：MOSS 误以为本地文件在 GitHub 上

**原因**：
- github 技能可能被误触发
- MOSS 混淆了参考链接和文件位置
- 没有明确文件路径

**解决**：
- 明确告诉 MOSS 文件在本地
- 使用完整路径或明确的文件名
- 如果问题持续，禁用 github 技能测试

---

**当前状态**：
- ✅ 文件在本地（已验证）
- ✅ MOSS 可以直接读取
- ⚠️ MOSS 需要明确的指示

**下一步**：
在对话中明确告诉 MOSS："这是本地文件，直接读取它"

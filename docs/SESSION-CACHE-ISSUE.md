# MOSS 会话缓存问题 - 诊断与解决

## 🐛 问题描述

**MOSS 的错误提示**：
```
目前无法直接访问您的远程仓库文件...
```

**实际原因**：
- MOSS 的会话缓存了旧的上下文
- 没有读取到更新后的配置文件（AGENTS.md、TOOLS.md、SOUL.md）
- 可能引用了已删除的 `brave-search` 技能

## 🔍 诊断过程

### 1. 检查当前会话
```bash
openclaw sessions list
```

**发现**：
- 会话年龄：1 分钟前
- 但是上下文可能还是旧的
- 使用模型：DeepSeek
- Token 使用：26k/164k (16%)

### 2. 问题分析

| 组件 | 状态 | 说明 |
|------|------|------|
| **配置文件** | ✅ 已更新 | AGENTS.md、TOOLS.md、SOUL.md 都包含 Tavily |
| **搜索技能** | ✅ 已清理 | 只保留 tavily-search |
| **Gateway** | ✅ 已重启 | 最新配置已加载 |
| **会话缓存** | ❌ 陈旧 | **这是问题所在** |

### 3. 根本原因

**OpenClaw 的工作机制**：
1. 每次会话启动时，读取配置文件
2. 会话期间，上下文会被缓存
3. **配置文件更新不会自动影响已存在的会话**

**当前情况**：
- 我们更新了配置文件
- 删除了 `brave-search`
- 但 MOSS 的会话还是旧的
- 所以它还在尝试访问不存在的文件

## ✅ 解决方案

### 方法 1：重启 Gateway（推荐）

```bash
# 1. 停止 gateway
openclaw gateway stop

# 2. 等待 2 秒
sleep 2

# 3. 启动 gateway
openclaw gateway start

# 4. 等待完全启动
sleep 3

# 5. 验证
openclaw doctor
```

### 方法 2：清除会话缓存

```bash
# 删除旧会话
rm /Users/lijian/.openclaw/agents/main/sessions/sessions.json

# 重启 gateway
openclaw gateway restart
```

### 方法 3：发起新对话

**在飞书**：
- 直接发起新对话
- 不要在旧对话中继续

**在 Web UI**：
- 刷新页面
- 发起新对话

## 🎯 验证修复

### 测试步骤

1. **重启后，问 MOSS 一个需要搜索的问题**：
   ```
   "2026年春节是哪天？"
   ```

2. **预期结果**：
   - ✅ MOSS 应该调用 `tavily-search`
   - ✅ 不应该提 Brave API
   - ✅ 不应该提"远程仓库文件"

3. **如果还是不行**：
   - 检查 AGENTS.md 是否包含 Tavily 说明
   - 检查 SOUL.md 是否提到搜索功能
   - 查看日志：`tail -f ~/.openclaw/logs/gateway.log`

## 📋 当前正确配置

### AGENTS.md（第 109-115 行）
```markdown
**🌐 Web Search (Tavily):** You have REAL-TIME web search capability via Tavily API!
- **Use it for:** Current events, latest news, documentation, facts, real-time data
- **Command:** `/Users/lijian/clawd/skills/tavily-search/search.js "query" [max_results]`
- **Free tier:** 1000 searches/month
- **Works in China:** No VPN needed
```

### TOOLS.md（第 16-34 行）
```markdown
## 🔗 Web Search - Tavily API

**Location:** `/Users/lijian/clawd/skills/tavily-search/`
**API Key:** `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`
**Works in China (no VPN needed)**
```

### SOUL.md（第 121-129 行）
```markdown
**联网搜索优先级**：
当你问及：
- 新闻、时事、最新动态
- 技术文档和 API 更新
- 产品信息、价格、评测
- 实时数据（天气、股票等）

我会先搜索，再给你答案。
```

## 🔄 后续建议

### 1. 配置文件更新后

**必须做的**：
```bash
# 重启 gateway 使配置生效
openclaw gateway restart
```

**可选的**：
```bash
# 清除会话缓存（从新对话开始）
rm ~/.openclaw/agents/main/sessions/sessions.json
```

### 2. 验证配置生效

```bash
# 检查 gateway 日志
tail -f ~/.openclaw/logs/gateway.log

# 在新对话中测试
问："帮我搜索一下今天的天气"
```

### 3. 常见问题排查

**问题 1**：MOSS 还说需要 Brave API
- **原因**：会话缓存
- **解决**：发起新对话

**问题 2**：MOSS 提"远程仓库文件"
- **原因**：可能引用了 OPENCLAW-AGENT-TRAINING-GUIDE.md
- **解决**：会话已过期，发起新对话

**问题 3**：搜索功能不工作
- **原因**：tavily-search 技能未加载
- **解决**：检查技能目录是否存在

## ✅ 快速修复脚本

```bash
#!/bin/bash
# fix-moss-cache.sh

echo "🔄 重启 OpenClaw Gateway..."
openclaw gateway stop
sleep 2
openclaw gateway start
sleep 3

echo "✅ Gateway 已重启"
echo ""
echo "📋 当前配置："
echo "- 搜索技能: tavily-search (唯一)"
echo "- API Key: tvly-dev-****"
echo "- 国内访问: ✅ 可用"
echo ""
echo "🧪 测试方法："
echo "1. 打开 http://127.0.0.1:18789/"
echo "2. 问：'2026年春节是哪天？'"
echo "3. 预期：MOSS 应该调用搜索并给出答案"
```

---

**更新时间**：2026-02-06
**状态**：✅ 已诊断
**优先级**：🔴 高（影响功能使用）

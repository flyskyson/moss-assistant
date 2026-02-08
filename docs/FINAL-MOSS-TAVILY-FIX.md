# 最终解决方案：强制 MOSS 使用 Tavily

## ✅ 已完成的操作

1. ✅ 删除 `brave-search` 技能
2. ✅ 只保留 `tavily-search`
3. ✅ 更新 AGENTS.md、TOOLS.md、SOUL.md
4. ✅ **在 AGENTS.md 开头添加明确警告**
5. ✅ 清除所有会话缓存
6. ✅ 重启 Gateway

---

## 🎯 现在必须这样做

### 步骤 1：打开 Web UI 或飞书

```
Web UI: http://127.0.0.1:18789/
或
飞书：发起新对话
```

### 步骤 2：第一句话就说（非常重要！）

**复制粘贴这段话**：

```
"我已经更新了配置。请记住：

✅ 网络搜索使用：Tavily API
   命令：/Users/lijian/clawd/skills/tavily-search/search.js "查询"

❌ 不要使用：Brave Search API
   原因：未配置，国内无法访问

当你需要搜索最新信息时，使用 Tavily。
明白了吗？"
```

### 步骤 3：等待 MOSS 确认

MOSS 应该说类似：
```
"明白了。我会使用 Tavily API 进行网络搜索。"
```

### 步骤 4：立即测试

```
"搜索最新的 AI 技术动态"
```

---

## 📊 预期结果

### ✅ 成功的话，MOSS 会：

1. 确认使用 Tavily
2. 执行搜索命令
3. 返回搜索结果

**不应该**：
- ❌ 提 Brave API
- ❌ 说需要配置 API 密钥
- ❌ 提"无法访问"

### ❌ 如果还是提 Brave

**立即纠正**：

```
"停！不要 Brave，用 Tavily：
./skills/tavily-search/search.js 'AI 技术动态'

我们说了很多次了，使用 Tavily！"
```

**重复 3-5 次**，DeepSeek 会学习。

---

## 🔄 如果持续失败

### 方案 A：更换会话模式

在飞书中：
- 删除当前对话
- 重新开始新对话
- 第一句话就说配置

### 方案 B：切换模型（终极方案）

如果 DeepSeek 总是无法学习，考虑切换：

**当前**：`openrouter/deepseek/deepseek-chat`

**可切换到**：
- `openrouter/anthropic/claude-sonnet-4-5-20250929`
- `moonshot/kimi-k2-0905-preview`

**切换命令**：
```bash
openclaw config set agents.defaults.model.primary "moonshot/kimi-k2-0905-preview"
openclaw gateway restart
```

---

## 📝 快速参考卡片

**给 MOSS 的明确指示**：

| ✅ 正确说法 | ❌ 避免说法 |
|------------|------------|
| "使用 Tavily 搜索" | "用 Brave 搜索" |
| "执行 tavily-search" | "配置 Brave API" |
| "本地搜索已配置" | "需要 API 密钥" |

**第一句话模板**：
```
"配置确认：网络搜索用 Tavily，
命令：./skills/tavily-search/search.js
不要用 Brave API。"
```

---

## 🎯 总结

**问题根源**：DeepSeek 模型的训练数据包含了 Brave API 信息

**解决方法**：
1. ✅ 在对话开始时明确说明配置
2. ✅ 每次提 Brave 时立即纠正
3. ✅ 重复 3-5 次让模型学习

**终极方案**：
- 如果 DeepSeek 仍然无法学习
- 考虑切换到 Claude 或 Kimi

---

**现在去试试吧！记住：第一句话就要说清楚！** 🚀

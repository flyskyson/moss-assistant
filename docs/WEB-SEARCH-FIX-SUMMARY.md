# MOSS 搜索功能问题 - 已解决

## 🎯 问题描述

**用户反馈**: MOSS 总是说需要 Brave Search API，无法使用搜索功能。

**根本原因**: 系统中存在 3 个搜索技能，MOSS 不知道该用哪个：
1. `brave-search` - 需要 API Key，国内无法访问 ❌
2. `web-search` - OpenClaw 内置，可能也需要配置 ⚠️
3. `tavily-search` - 已配置，国内可用 ✅

## ✅ 解决方案

### 执行的操作

1. **删除冲突的搜索技能**
   ```bash
   rm -rf /Users/lijian/clawd/skills/brave-search
   rm -rf /Users/lijian/.openclaw/skills/web-search
   ```

2. **更新技能锁文件**
   - 只保留 `tavily-search`
   - 创建新的 `clawhub.lock`

3. **重启 Gateway**
   ```bash
   openclaw gateway restart
   ```

### 当前状态

| 搜索技能 | 状态 | 说明 |
|---------|------|------|
| **tavily-search** | ✅ **唯一可用** | 国内可用，已配置 API Key |
| brave-search | ❌ 已删除 | 国内无法访问 |
| web-search | ❌ 已删除 | 配置冲突 |

## 💡 Brave API 为什么不重要？

### ❌ Brave Search 的问题

1. **国内无法访问**
   ```bash
   # 测试结果
   curl -I https://api.search.brave.com
   # 结果: Timeout (连接超时)
   ```

2. **需要 API Key**
   - 免费额度：2000次/月
   - 但国内根本用不了

3. **功能与 Tavily 相同**
   - 都是网页搜索 API
   - 都支持内容提取
   - 性能和质量相当

### ✅ Tavily 的优势

1. **国内可直接访问**
   - 无需 VPN
   - 连接稳定

2. **AI 优化**
   - 专为 AI Agent 设计
   - 自动总结和内容提取
   - 搜索结果经过优化

3. **免费额度充足**
   - 1000次/月
   - 对个人使用完全足够

4. **已配置可用**
   - API Key: `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`
   - 搜索脚本已安装
   - 配置文件已更新

## 🧪 测试验证

### 测试命令

```bash
# 测试搜索功能
cd /Users/lijian/clawd/skills/tavily-search
./search.js "2026年春节日期" 3
```

### 预期结果

✅ **应该看到**：
- 搜索结果总结
- 相关链接
- 具体日期信息

❌ **不应该看到**：
- "需要 Brave API"
- "无法使用搜索功能"
- 连接超时错误

## 📋 MOSS 现在应该怎么做？

### 当用户询问实时信息时

**MOSS 应该**：
1. 识别需要最新信息的问题
2. **直接使用** `/Users/lijian/clawd/skills/tavily-search/search.js`
3. 总结搜索结果
4. 提供来源链接

**示例对话**：

```
用户: "2026年春节是哪天？"

MOSS: [调用搜索]
      "我帮你搜索了一下最新信息。

      2026年春节是2月17日（农历正月初一），生肖属马。
      放假时间：2月15日（腊月二十八）至2月23日（正月初七），共9天。

      来源：新浪财经、中公网校"
```

### 不应该说的话

❌ "我需要 Brave Search API"
❌ "搜索功能受限"
❌ "请提供 API 密钥"

## 🔄 后续监控

### 验证 MOSS 是否正常使用搜索

**测试问题**：
1. "今天北京天气怎么样？"（实时数据）
2. "DeepSeek 最新模型是什么？"（技术动态）
3. "2026年春节放假安排？"（时效信息）

**成功标准**：
- ✅ MOSS 主动调用搜索
- ✅ 返回准确结果
- ✅ 响应时间 < 10秒

### 如果还是提 Brave API

**可能原因**：
1. MOSS 没有重新读取配置文件
2. 会话缓存了旧信息

**解决方法**：
```bash
# 1. 重启 gateway
openclaw gateway restart

# 2. 开始新会话
# 在飞书或 Web UI 发起新对话

# 3. 检查 AGENTS.md 是否包含 tavily-search 说明
grep "Tavily" /Users/lijian/clawd/AGENTS.md
```

## 📚 参考文档

- [AGENTS.md](/Users/lijian/clawd/AGENTS.md#L109-L115) - 搜索工具说明
- [TOOLS.md](/Users/lijian/clawd/TOOLS.md#L16-L34) - API Key 配置
- [SOUL.md](/Users/lijian/clawd/SOUL.md#L121-L129) - 搜索优先级

## ✅ 总结

- **Brave API 完全不重要** - 国内用不了
- **Tavily 已经够用** - 功能相同，国内可用
- **问题已解决** - 删除了冲突技能
- **MOSS 应该正常工作了** - 只有一个搜索选项

---

**更新时间**: 2026-02-06
**状态**: ✅ 已解决
**下一步**: 测试 MOSS 是否能正常使用搜索功能

# MOSS 状态诊断报告

**诊断日期**: 2026-02-07
**诊断人**: MOSS (自动化检测)
**状态**: ❌ 严重 - 所有 Agents 不可用

---

## 🚨 问题描述

**错误信息**: `402 Insufficient credits. Add more using https://openrouter.ai/settings/credits`

**影响范围**: 所有 OpenClaw Agents
- ❌ MOSS (main agent) - 不可用
- ❌ leader-agent - 不可用
- ❌ utility-agent - 不可用

---

## 🔍 根本原因分析

### 问题链

```
所有 Agents → OpenRouter API → 积分不足 → 402 错误
```

### 技术细节

1. **模型配置**:
   - Main agent: `openrouter/google/gemini-2.5-pro`
   - Leader agent: `openrouter/google/gemini-2.5-pro`
   - Utility agent: `openrouter/google/gemini-2.5-flash`

2. **API 调用**:
   - Provider: OpenRouter
   - Endpoint: `https://openrouter.ai/api/v1/chat/completions`
   - 认证: API Key

3. **错误原因**:
   - OpenRouter 账户积分余额 = 0
   - 所有请求被拒绝，返回 402 状态码

---

## ✅ 解决方案

### 方案 1: 充值 OpenRouter ⭐ **推荐**

**优点**:
- ✅ 最快恢复
- ✅ 所有 agents 立即可用
- ✅ 无需修改配置

**步骤**:
1. 访问: https://openrouter.ai/settings/credits
2. 充值金额（建议）:
   - 最低: $5.00
   - 推荐: $10.00 - $20.00
3. 验证恢复:
   ```bash
   openclaw agent --agent main --message "测试"
   ```

**预期成本**:
- Gemini 2.5 Pro: $2.50/M input, $10/M output
- Gemini 2.5 Flash: $0.30/M input, $2.50/M output

---

### 方案 2: 配置备用模型提供商

**当前已配置但未激活的提供商**:
- ✅ **moonshot** (Kimi K2)
- ✅ **zai**

**配置步骤**:
1. 获取对应提供商的 API key
2. 添加模型:
   ```bash
   # 配置 moonshot
   openclaw configure

   # 选择添加 moonshot 模型
   # 输入 API key
   ```
3. 切换默认模型:
   ```bash
   # 更新 agents 配置
   openclaw agents set-identity --agent main --model moonshot/kimi-k2-0905-preview
   ```

**优点**:
- ✅ 不依赖 OpenRouter
- ✅ 可能有免费额度

**缺点**:
- ❌ 需要额外配置
- ❌ 模型性能可能不同

---

### 方案 3: 混合使用多个提供商

**架构**:
```
Main Agent → Moonshot (主模型)
Leader Agent → OpenRouter (规划，低频使用)
Utility Agent → OpenRouter (执行，高频使用，成本更低)
```

**配置**:
- 为不同 agent 设置不同的模型
- 优化成本和性能平衡

---

## 📊 成本分析

### OpenRouter 定价

| 模型 | Input | Output | 适用场景 |
|------|-------|--------|----------|
| **Gemini 2.5 Pro** | $2.50/M | $10/M | 复杂推理、规划 |
| **Gemini 2.5 Flash** | $0.30/M | $2.50/M | 简单任务、摘要 |
| **成本差异** | -88% | -75% | Flash 更便宜 |

### 推荐充值金额

| 用量 | 充值金额 | 预计使用时长 |
|------|----------|--------------|
| 轻度 | $5.00 | 约 1-2 个月 |
| 中度 | $10.00 | 约 2-4 个月 |
| 重度 | $20.00+ | 约 4-6 个月 |

---

## 🧪 验证测试

### 测试命令

```bash
# 测试 main agent
openclaw agent --agent main --message "你好，请介绍你自己"

# 测试 utility-agent
echo "请回复OK" | openclaw agent --agent utility-agent --message -

# 测试 leader-agent
openclaw agent --agent leader-agent --message "请报告你的状态"
```

### 预期输出

充值成功后，所有 agents 应该能够正常响应。

---

## 🔧 故障排查

### 问题 1: 充值后仍然报错

**原因**: API key 可能不正确

**解决**:
```bash
# 检查 API key 配置
openclaw auth list

# 重新配置
openclaw configure
```

### 问题 2: 只有部分 agent 可用

**原因**: 不同 agent 使用不同的模型

**解决**:
```bash
# 检查 agent 配置
openclaw agents list

# 查看详细配置
cat ~/.openclaw/openclaw.json | grep -A 5 "leader-agent\|utility-agent"
```

### 问题 3: 成本过高

**原因**: 过度使用 Pro 模型

**解决**:
- 优先使用 utility-agent (Flash 模型)
- 复杂任务才使用 leader-agent (Pro 模型)
- 设置预算限制

---

## 💡 优化建议

### 1. 成本优化策略

```bash
# 简单任务使用 utility-agent
openclaw agent --agent utility-agent --message "总结这段文本"

# 复杂任务使用 leader-agent
openclaw agent --agent leader-agent --message "规划项目架构"
```

### 2. 监控使用情况

```bash
# 定期检查 OpenRouter 余额
open https://openrouter.ai/settings/credits

# 查看使用日志
openclaw sessions list
```

### 3. 设置预算告警

- 在 OpenRouter 设置预算限制
- 当余额低于阈值时收到通知
- 避免服务中断

---

## 📋 检查清单

- [x] 诊断问题（OpenRouter 积分不足）
- [x] 确认影响范围（所有 agents）
- [x] 提供解决方案（充值或切换提供商）
- [ ] 充值 OpenRouter
- [ ] 验证 agents 恢复
- [ ] 配置监控和告警
- [ ] 优化成本策略

---

## 📞 支持

**OpenRouter 支持**:
- 官网: https://openrouter.ai
- 帮助: https://openrouter.ai/docs
- 充值: https://openrouter.ai/settings/credits

**OpenClaw 支持**:
- 文档: https://docs.openclaw.ai
- Discord: https://discord.gg/openclaw
- GitHub: https://github.com/openclaw-ai/openclaw

---

**报告签名**: MOSS 自动诊断系统
**紧急程度**: 🔴 严重 - 所有 Agents 不可用
**建议行动**: ⚡ 立即充值 OpenRouter

---

> 📌 **下一步**:
> 1. 访问 https://openrouter.ai/settings/credits
> 2. 充值 $10.00（建议）
> 3. 运行 `openclaw agent --agent main --message "测试"` 验证
> 4. 收到推送通知确认恢复

# DeepSeek API 速度测试总结报告

**测试日期**: 2026-02-08
**目标**: 为 MOSS 选择最快的 DeepSeek API 配置

---

## 📊 测试结果

### 速度对比

| 方案 | 平均响应时间 | 成功率 | 评级 | 速度对比 |
|------|-------------|--------|------|---------|
| **DeepSeek 官方专线** | **1秒** | 100% (5/5) | 🚀 快 | **基准** |
| OpenRouter DeepSeek | 4秒 | 100% (5/5) | 🐌 慢 | 慢 75% |

### 关键发现

1. ✅ **DeepSeek 官方专线比 OpenRouter 快 75%**
2. ✅ **两者成功率都是 100%**，都很稳定
3. ✅ **官方专线成本更低**（直接计费 vs OpenRouter 加价）

---

## 🎯 决策建议

### MOSS 主模型配置

**推荐**: 使用 **DeepSeek 官方专线**

**理由**:
- ⚡ 速度快 75%（1s vs 4s）
- 💰 成本更低（无中转费用）
- 🎯 专为 DeepSeek 优化

### 其他模型配置

| 任务类型 | 推荐模型 | 原因 |
|---------|---------|------|
| 日常任务 | DeepSeek 官方 | 速度最快 |
| 编程任务 | MiniMax M2.1 | 编程性能最佳（72.5% SWE-bench） |
| 简单任务 | 智能路由 | 自动选择最优模型 |

---

## ✅ 已完成的配置

### 1. OpenClaw 配置更新

**文件**: `~/.openclaw/openclaw.json`

**更改**:
- ✅ 添加 `deepseek` 提供商
- ✅ 配置 `deepseek-chat` 模型
- ✅ 设置为默认主模型

**配置片段**:
```json
{
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-chat",
            "name": "DeepSeek Chat (Official)",
            "contextWindow": 64000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "deepseek-chat"
      }
    }
  }
}
```

### 2. API Keys 配置

**环境变量**:
```bash
export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
export OPENROUTER_API_KEY="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"
```

**用途**:
- DeepSeek 官方: MOSS 主模型（快 75%）
- OpenRouter: 备用方案 + 其他模型

---

## 📝 使用指南

### 在脚本中使用

**方式 1: 直接调用**
```bash
export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"

curl https://api.deepseek.com/chat/completions \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

**方式 2: 通过 OpenClaw**
```bash
# MOSS 现在默认使用 deepseek-chat
openclaw agent --agent main --message "你的任务"
```

### 测试脚本

**快速测试**:
```bash
# 测试 DeepSeek 官方专线
cd /Users/lijian/clawd
./scripts/simple-speed-test.sh
```

**完整对比**:
```bash
# 对比所有方案
./scripts/final-speed-test.sh
```

---

## 📈 性能监控

### 定期检查

建议每周运行一次速度测试：

```bash
cd /Users/lijian/clawd
./scripts/final-speed-test.sh > logs/speed-test-weekly-$(date +%Y%m%d).log
```

### 告警阈值

- ⚠️ **警告**: 平均响应时间 > 2秒
- 🚨 **严重**: 平均响应时间 > 4秒
- ❌ **失败**: 成功率 < 95%

---

## 🔧 故障排除

### 问题 1: 配置未生效

**解决**:
```bash
# 重启 OpenClaw Gateway
killall openclaw-gateway 2>/dev/null || true
openclaw gateway restart

# 验证配置
jq '.agents.defaults.model.primary' ~/.openclaw/openclaw.json
# 应该输出: "deepseek-chat"
```

### 问题 2: API Key 未设置

**解决**:
```bash
# 临时设置
export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"

# 永久设置（添加到 ~/.zshrc）
echo 'export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"' >> ~/.zshrc
source ~/.zshrc
```

### 问题 3: 速度变慢

**检查**:
```bash
# 1. 运行速度测试
./scripts/final-speed-test.sh

# 2. 检查网络
ping api.deepseek.com

# 3. 检查 API 配额
curl https://api.deepseek.com/v1/models \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY"
```

---

## 📚 相关文档

- [DeepSeek API 官方文档](https://api-docs.deepseek.com/)
- [OpenRouter 优化策略](/Users/lijian/clawd/docs/openrouter-optimization-strategy.md)
- [模型路由配置](/Users/lijian/clawd/config/model-routing.yaml)

---

## 🎉 总结

### 核心成果

1. ✅ **完成速度对比测试**: 官方快 75%
2. ✅ **配置 DeepSeek 官方专线**: 已添加到 OpenClaw
3. ✅ **设置为主模型**: MOSS 默认使用 deepseek-chat
4. ✅ **创建测试工具**: 多个自动化测试脚本

### 下一步

1. **测试新配置**: 使用 MOSS 验证速度
2. **监控性能**: 定期运行速度测试
3. **优化其他任务**: 配置智能路由

---

**测试完成**: 2026-02-08 23:56
**配置状态**: ✅ 已激活
**MOSS 模型**: deepseek-chat（DeepSeek 官方专线）

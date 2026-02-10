# DeepSeek 官方专线配置指南

**测试结果**: DeepSeek 官方专线比 OpenRouter 快 75% (1s vs 4s)

---

## ✅ 推荐配置

### 方案 1: 环境变量（最简单）

```bash
# 添加到 ~/.zshrc 或 ~/.bash_profile
export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
```

### 方案 2: OpenClaw 配置文件

编辑 `~/.openclaw/openclaw.json`，添加 DeepSeek 提供商：

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com",
        "api": "openai-completions",
        "apiKey": "sk-1e040b7546b341b0bee289c8bc74ea4f",
        "models": [
          {
            "id": "deepseek-chat",
            "name": "DeepSeek Chat (Official)",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 0.27,
              "output": 1.1,
              "cacheRead": 0,
              "cacheWrite": 0
            },
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

---

## 📋 配置清单

### API Keys
- ✅ DeepSeek 官方: `sk-1e040b7546b341b0bee289c8bc74ea4f`
- ✅ OpenRouter: `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`

### 测试结果
| 方案 | 平均时间 | 评级 |
|------|---------|------|
| DeepSeek 官方 | 1s | 🚀 快 |
| OpenRouter | 4s | 🐌 慢 |

### 推荐
- **MOSS 主模型**: DeepSeek 官方专线 (deepseek-chat)
- **其他任务**: 使用智能路由

---

## 🚀 立即应用

1. 设置环境变量:
   ```bash
   export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
   ```

2. 在脚本中使用:
   ```bash
   API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
   curl https://api.deepseek.com/chat/completions \
     -H "Authorization: Bearer $API_KEY" \
     -d '{"model": "deepseek-chat", ...}'
   ```

---

**测试日期**: 2026-02-08
**决策**: 使用 DeepSeek 官方专线（快 75%）

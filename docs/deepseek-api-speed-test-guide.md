# DeepSeek API 速度测试指南

**目标**: 为 MOSS 选择最快的 DeepSeek API 配置

---

## 🚀 快速开始

```bash
# 方式 1: 自动配置（推荐）
cd /Users/lijian/clawd
./scripts/setup-deepseek-test.sh auto

# 方式 2: 手动步骤
./scripts/setup-deepseek-test.sh check   # 检查配置
./scripts/setup-deepseek-test.sh setup   # 配置 API Keys
./scripts/setup-deepseek-test.sh test    # 运行测试
```

---

## 📋 需要测试的方案

### 方案 1: OpenRouter - DeepSeek V3.2
- **API**: `https://openrouter.ai/api/v1`
- **模型**: `deepseek/deepseek-v3.2`
- **优点**: 统一接口，多模型选择
- **缺点**: 可能存在中转延迟

### 方案 2: DeepSeek 官方专线 ⭐
- **API**: `https://api.deepseek.com`
- **模型**: `deepseek-chat`
- **优点**: 直连服务器，理论上最快
- **缺点**: 需要单独的 API Key

### 方案 3: OpenRouter - MiniMax M2.1
- **API**: `https://openrouter.ai/api/v1`
- **模型**: `minimax/minimax-m2.1`
- **优点**: 编程性能优秀（72.5% SWE-Bench）
- **缺点**: 同样可能存在 OpenRouter 延迟

---

## 🔑 获取 API Keys

### OpenRouter API Key
1. 访问: https://openrouter.ai/keys
2. 登录或注册
3. 创建 API Key
4. 充值（建议 $10-20）

### DeepSeek 官方 API Key
1. 访问: https://platform.deepseek.com/
2. 登录或注册
3. 进入 API Keys 页面
4. 创建 API Key
5. 充值（建议 $10-20）

---

## 📊 预期结果

### 速度基准

| 响应时间 | 评级 | 建议 |
|---------|------|------|
| < 2s | 🟢 快 ✓ | 适合 MOSS 主模型 |
| 2-5s | 🟡 中 | 可用，但非最优 |
| > 5s | 🔴 慢 ✗ | 不建议用于 MOSS |

### 成本对比

| 方案 | 输入 | 输出 | 月成本* |
|------|------|------|---------|
| DeepSeek V3.2 (OpenRouter) | $0.25 | $0.38 | ~$2.80 |
| DeepSeek 官方 | $0.27 | $1.10 | ~$5.50 |
| MiniMax M2.1 | $0.28 | $1.00 | ~$2.90 |

*假设每天 50 次调用

---

## 🎯 决策标准

### MOSS 主模型选择

```
IF DeepSeek 官方 API < 2s AND OpenRouter > 2s:
    使用 DeepSeek 官方专线
ELIF DeepSeek 官方 API < 2s AND OpenRouter < 2s:
    选择更快的那个
ELIF DeepSeek 官方 API > 2s AND OpenRouter < 2s:
    使用 OpenRouter
ELSE:
    都太慢，考虑其他方案（如本地模型）
```

### 其他模型配置

- **编程任务**: MiniMax M2.1（编程性能最佳）
- **简单任务**: 使用智能路由自动选择
- **实验开发**: MiMo-V2-Flash（免费）

---

## 📝 配置 OpenClaw

测试完成后，根据结果配置 OpenClaw：

### 方案 A: DeepSeek 官方专线（最快）

编辑 `~/.openclaw/openclaw.json`:

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
            "name": "DeepSeek Chat (Official)"
          }
        ]
      }
    }
  },
  "agents": {
    "MOSS": {
      "model": "deepseek-chat"
    }
  }
}
```

### 方案 B: OpenRouter DeepSeek

```json
{
  "agents": {
    "MOSS": {
      "model": "deepseek/deepseek-v3.2"
    }
  }
}
```

---

## 🔧 故障排除

### 问题 1: API Key 未生效

```bash
# 检查环境变量
echo $OPENROUTER_API_KEY
echo $DEEPSEEK_API_KEY

# 手动设置
export OPENROUTER_API_KEY="your-key"
export DEEPSEEK_API_KEY="your-key"

# 永久保存（添加到 ~/.zshrc 或 ~/.bashrc）
echo 'export OPENROUTER_API_KEY="your-key"' >> ~/.zshrc
echo 'export DEEPSEEK_API_KEY="your-key"' >> ~/.zshrc
source ~/.zshrc
```

### 问题 2: 测试失败

1. 检查网络连接
2. 确认 API Key 有效
3. 检查账户余额（需要充值）
4. 查看日志: `cat /Users/lijian/clawd/logs/api-speed-test-*.log`

### 问题 3: OpenClaw 配置不生效

```bash
# 重启 OpenClaw Gateway
killall openclaw-gateway 2>/dev/null || true
openclaw gateway start
```

---

## 📈 后续优化

### 监控速度

定期运行测试，监控性能变化：

```bash
# 每周测试一次
./scripts/setup-deepseek-test.sh test
```

### 成本监控

在 OpenRouter 控制台设置预算告警：
- 访问: https://openrouter.ai/settings
- 设置月度预算上限
- 启用 80% 告警

### 备用方案

如果 API 速度不稳定，考虑：
1. 使用本地模型（Ollama）
2. 混合使用（在线 + 本地）
3. 设置超时和重试机制

---

**创建日期**: 2026-02-08
**维护**: MOSS

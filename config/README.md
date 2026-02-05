# OpenClaw 配置模板说明

## 文件说明

### `auth-templates.json`
认证配置模板，用于新 Agent 的认证配置。

**使用方法**：
1. 复制到目标 Agent 目录：`~/.clawdbot-{agent}/agents/main/agent/auth-profiles.json`
2. 替换 `YOUR_*_API_KEY_HERE` 为实际 API 密钥

### `clawdbot-template.json`
Agent 主配置模板。

**使用方法**：
1. 复制到目标 Agent 目录：`~/.clawdbot-{agent}/clawdbot.json`
2. 根据需要调整配置参数

## 当前 Agent 配置状态

| Agent | 路径 | 认证配置 | 主配置 |
|-------|------|----------|--------|
| MOSS (clawd) | `/Users/lijian/clawd` | ✅ | ✅ |
| Leader | `~/.clawdbot-leader` | ✅ | ✅ |
| Thinker | `~/.clawdbot-thinker` | ✅ | ❌ |
| Coordinator | `~/.clawdbot-coordinator` | ✅ | ❌ |
| Executor | `~/.clawdbot-executor` | ✅ | ❌ |

## 初始化新 Agent

当需要启用预留的 Agent 时：

```bash
# 1. 创建配置目录（如果不存在）
mkdir -p ~/.clawdbot-{agent}/agents/main/agent

# 2. 复制配置模板
cp /Users/lijian/clawd/config/auth-templates.json ~/.clawdbot-{agent}/agents/main/agent/auth-profiles.json
cp /Users/lijian/clawd/config/clawdbot-template.json ~/.clawdbot-{agent}/clawdbot.json

# 3. 编辑认证配置，填入实际密钥
vim ~/.clawdbot-{agent}/agents/main/agent/auth-profiles.json
```

## 配置同步

为了避免维护多份相同的 API 密钥，可以使用符号链接：

```bash
# 让所有 Agent 共享同一份认证配置
ln -s ~/.clawdbot-leader/agents/main/agent/auth-profiles.json \
      ~/.clawdbot-thinker/agents/main/agent/auth-profiles.json
```

**注意**：符号链接方式下，修改任何一处会同步到所有 Agent。

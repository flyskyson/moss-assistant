# OpenClaw DeepSeek + Sonnet 4.5 混合模型配置方案

## 一、方案概述

本方案用于在OpenClaw中配置混合AI模型策略：
- **主模型**: DeepSeek (处理日常简单任务)
- **备用模型**: Claude Sonnet 4.5 (处理复杂编程任务)
- **月预算**: 约400元

## 二、模型用途与成本规划

| 模型 | 用途 | 预计成本 | 预计使用量 |
|------|------|----------|-----------|
| DeepSeek | 日常简单任务、代码理解、常规问答 | ~¥100/月 | ~1.5亿 tokens |
| Sonnet 4.5 | 复杂编程任务、架构设计、多文件修改 | ~¥300/月 | ~100万 tokens |

### 模型选择理由
- **DeepSeek**: 价格极低（¥0.14/百万tokens），适合高频使用
- **Sonnet 4.5**: 强大的代码能力，适合复杂任务但价格较高（¥15/百万tokens）

## 三、前置准备

### 3.1 获取API密钥

**必需的API密钥:**
1. **OpenRouter API Key** - 用于访问DeepSeek和Sonnet
   - 注册地址: https://openrouter.ai/
   - 获取方式: 注册后 → Settings → API Keys

### 3.2 准备工作
- 确保已安装OpenClaw
- 以管理员权限打开PowerShell

## 四、配置步骤

### 步骤1: 配置认证信息

编辑 `C:\Users\{你的用户名}\.openclaw\agents\main\agent\auth-profiles.json`:

```json
{
  "version": 1,
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "key": "你的OpenRouter-API-Key"
    }
  },
  "lastGood": {
    "openrouter": "openrouter:default"
  },
  "usageStats": {
    "openrouter:default": {
      "lastUsed": 0,
      "errorCount": 0
    }
  }
}
```

**重要**: 将 `"你的OpenRouter-API-Key"` 替换为实际的API密钥

### 步骤2: 配置模型策略

编辑 `C:\Users\{你的用户名}\.openclaw\openclaw.json`:

```json
{
  "meta": {
    "lastTouchedVersion": "2026.2.2-3",
    "lastTouchedAt": "2026-02-04T05:41:22.854Z"
  },
  "wizard": {
    "lastRunAt": "2026-02-04T05:41:22.851Z",
    "lastRunVersion": "2026.2.2-3",
    "lastRunCommand": "doctor",
    "lastRunMode": "local"
  },
  "auth": {
    "profiles": {
      "openrouter:default": {
        "provider": "openrouter",
        "mode": "api_key"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/deepseek/deepseek-chat",
        "fallbacks": [
          "openrouter/anthropic/claude-sonnet-4-5-20250929"
        ]
      },
      "models": {
        "openrouter/deepseek/deepseek-chat": {
          "alias": "DeepSeek"
        },
        "openrouter/anthropic/claude-sonnet-4-5-20250929": {
          "alias": "Sonnet"
        }
      },
      "workspace": "C:\\Users\\{你的用户名}\\.openclaw\\workspace",
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h"
      },
      "compaction": {
        "mode": "safeguard"
      },
      "heartbeat": {
        "every": "30m"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  "messages": {
    "ackReactionScope": "group-mentions"
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto"
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "你的Gateway令牌"
    },
    "tailscale": {
      "mode": "off",
      "resetOnExit": false
    }
  }
}
```

**注意**:
- 将 `{你的用户名}` 替换为实际用户名
- Gateway令牌会在后续步骤自动生成

### 步骤3: 重启Gateway服务

在**管理员权限的PowerShell**中执行:

```powershell
# 1. 停止现有服务
openclaw gateway uninstall

# 2. 重新安装服务
openclaw gateway install

# 3. 启动服务
openclaw gateway start
```

### 步骤4: 获取访问令牌并创建快捷方式

#### 4.1 生成带令牌的访问链接
在PowerShell中执行:
```powershell
openclaw dashboard
```

复制输出的完整URL（包含token参数），格式类似：
```
http://127.0.0.1:18789/?token=xxxxxxxxxxxxxxxx
```

#### 4.2 创建桌面快捷方式

创建文件 `C:\Users\{你的用户名}\Desktop\OpenClaw Dashboard.bat`:

```batch
@echo off
start chrome --incognito "http://127.0.0.1:18789/?token=你的实际token"
```

**重要**:
- 将 `你的实际token` 替换为步骤4.1中获取的token
- 使用 `--incognito` 参数避免浏览器扩展干扰（解决前端闪烁问题）

### 步骤5: 验证配置

1. 双击桌面快捷方式启动OpenClaw Dashboard
2. 发送测试消息："你好，请介绍一下你自己"
3. 检查日志确认使用DeepSeek模型:
   ```powershell
   openclaw logs tail
   ```

## 五、常见问题排查

### 问题1: Gateway服务安装失败
**错误**: `schtasks create failed: 拒绝访问`
**解决**: 确保以管理员身份运行PowerShell

### 问题2: Unknown model错误
**错误**: `Unknown model: deepseek/deepseek-chat`
**解决**:
- 必须使用完整模型ID: `openrouter/deepseek/deepseek-chat`
- 不能直接使用 `deepseek/deepseek-chat`

### 问题3: 前端无响应
**原因**: 浏览器扩展干扰WebSocket连接
**解决**: 使用Chrome无痕模式（快捷方式中已包含 `--incognito`）

### 问题4: 消息闪烁
**现象**: 消息出现时前端持续闪烁
**解决**: 使用无痕模式访问，禁用所有浏览器扩展

## 六、成本监控建议

1. **定期检查OpenRouter使用量**
   - 登录 https://openrouter.ai/
   - 查看 Usage Stats

2. **调整使用策略**
   - 简单任务让DeepSeek处理（自动）
   - 复杂任务手动指定使用Sonnet

3. **预算预警**
   - 设置OpenRouter消费提醒
   - 月消费接近350元时考虑调整策略

## 七、文件路径清单

配置完成后，关键文件路径：

| 文件 | 路径 |
|------|------|
| 认证配置 | `C:\Users\{用户名}\.openclaw\agents\main\agent\auth-profiles.json` |
| 主配置 | `C:\Users\{用户名}\.openclaw\openclaw.json` |
| 日志文件 | `C:\tmp\openclaw\openclaw-{日期}.log` |
| 工作空间 | `C:\Users\{用户名}\.openclaw\workspace` |
| 快捷方式 | `C:\Users\{用户名}\Desktop\OpenClaw Dashboard.bat` |

## 八、完成检查清单

- [ ] 获取OpenRouter API密钥
- [ ] 配置auth-profiles.json
- [ ] 配置openclaw.json
- [ ] 重启Gateway服务
- [ ] 创建桌面快捷方式
- [ ] 测试发送消息
- [ ] 验证模型使用正常
- [ ] 确认无前端闪烁问题

---

**方案版本**: 1.0
**创建日期**: 2026-02-04
**适用OpenClaw版本**: 2026.2.2-3及以上

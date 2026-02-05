# OpenClaw 多 Agent 部署与飞书对接完整方案

## 文档概述

本文档包含三个核心实施方案：
1. **方案一**: 一个 Gateway 托管多个独立 Agent
2. **方案二**: 多个 Clawbot 同一群组协作
3. **方案三**: 飞书平台深度对接方案

**文档版本**: 1.0
**创建日期**: 2026-02-04
**适用 OpenClaw 版本**: 2026.2.2-3 及以上

---

# 方案一：一个 Gateway 托管多个独立 Agent

## 核心架构

```
┌─────────────────────────────────────────────────────────┐
│                    Gateway (单实例)                       │
│                   端口: 18789 (本地)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Agent A    │  │   Agent B    │  │   Agent C    │ │
│  │   (main)     │  │   (work)     │  │  (family)    │ │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤ │
│  │ workspace-a  │  │ workspace-b  │  │ workspace-c  │ │
│  │ agentDir-a   │  │ agentDir-b   │  │ agentDir-c   │ │
│  │ sessions-a   │  │ sessions-b   │  │ sessions-c   │ │
│  │ auth-a.json  │  │ auth-b.json  │  │ auth-c.json  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                         │
│           Bindings (路由规则)                           │
│    channel + accountId + peer → agentId                 │
└─────────────────────────────────────────────────────────┘
```

## 配置文件结构

### openclaw.json 配置示例

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "name": "通用助手",
        "default": true,
        "workspace": "~/.openclaw/workspace",
        "agentDir": "~/.openclaw/agents/main/agent",
        "model": "openrouter/deepseek/deepseek-chat",
        "sandbox": {
          "mode": "off"
        }
      },
      {
        "id": "work",
        "name": "工作助手",
        "workspace": "~/.openclaw/workspace-work",
        "agentDir": "~/.openclaw/agents/work/agent",
        "model": "openrouter/anthropic/claude-sonnet-4-5-20250929",
        "tools": {
          "allow": ["read", "exec"],
          "deny": ["write", "edit"]
        }
      },
      {
        "id": "family",
        "name": "家庭助手",
        "workspace": "~/.openclaw/workspace-family",
        "agentDir": "~/.openclaw/agents/family/agent",
        "groupChat": {
          "mentionPatterns": ["@family", "@familybot"]
        }
      }
    ]
  },

  "bindings": [
    {
      "agentId": "main",
      "match": {
        "channel": "feishu",
        "accountId": "personal"
      }
    },
    {
      "agentId": "work",
      "match": {
        "channel": "feishu",
        "accountId": "work"
      }
    },
    {
      "agentId": "family",
      "match": {
        "channel": "feishu",
        "peer": {
          "kind": "group",
          "id": "family_group_id"
        }
      }
    }
  ],

  "channels": {
    "feishu": {
      "accounts": {
        "personal": {
          "appId": "cli_xxx_a",
          "appSecret": "xxx_secret_a",
          "enabled": true
        },
        "work": {
          "appId": "cli_xxx_b",
          "appSecret": "xxx_secret_b",
          "enabled": true
        }
      }
    }
  }
}
```

## 实施步骤

### 步骤1: 创建额外的 Agent

```bash
# 创建工作助手 Agent
openclaw agents add work

# 创建家庭助手 Agent
openclaw agents add family

# 验证 Agent 列表
openclaw agents list
```

### 步骤2: 配置路由规则

编辑 `~/.openclaw/openclaw.json`，添加 `agents.list` 和 `bindings` 配置。

### 步骤3: 验证路由配置

```bash
# 查看所有 Agent 及其绑定规则
openclaw agents list --bindings
```

预期输出示例：
```
┌──────────────┬──────────────┬─────────────────────────────────────────────┐
│ Agent        │ Workspace    │ Bindings                                    │
├──────────────┼──────────────┼─────────────────────────────────────────────┤
│ main (default) │ ~/.openclaw/workspace │ feishu:personal              │
│ work         │ ~/.openclaw/workspace-work │ feishu:work             │
│ family       │ ~/.openclaw/workspace-family │ feishu:group:family_group_id │
└──────────────┴──────────────┴─────────────────────────────────────────────┘
```

### 步骤4: 重启 Gateway

```bash
# 重启 Gateway 使配置生效
openclaw gateway restart
```

## 关键特性说明

| 特性 | 说明 |
|------|------|
| **完全隔离** | 每个 Agent 有独立的工作区、认证、会话 |
| **路由优先级** | peer 精确匹配 > accountId > channel |
| **沙箱隔离** | 每个 Agent 可配置独立的沙箱和工具权限 |
| **凭证独立** | 每个 Agent 从各自的 `auth-profiles.json` 读取 |

## 路由规则优先级

```
1. peer 匹配（精确私信/群组/频道 id）
2. guildId（Discord）
3. teamId（Slack）
4. accountId 匹配
5. 渠道级匹配（accountId: "*"）
6. 回退到默认 Agent（agents.list[].default，否则列表第一个）
```

---

# 方案二：多个 Clawbot 同一群组协作

## 架构模式

### 模式 A：多 Agent + 单 Bot Token（推荐）

```
┌────────────────────────────────────────────────────────┐
│                    飞书群组                              │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                 │
│  │ 用户 A   │  │ 用户 B   │  │ 用户 C   │                 │
│  └─────────┘  └─────────┘  └─────────┘                 │
│                                                         │
│            @clawd → @work → @family                     │
│                  ↓       ↓        ↓                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │              单一飞书 Bot 应用                    │   │
│  │             (单个 App ID/Secret)                 │   │
│  └─────────────────────────────────────────────────┘   │
│                        ↓                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │              OpenClaw Gateway                    │   │
│  │  根据 @提及 模式路由到不同 Agent                  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 模式 B：多 Bot 应用（需多个飞书应用）

```
飞书群组: [Bot1] [Bot2] [Bot3] [用户] [用户]
   ↓          ↓          ↓
Gateway ← Binding ← Binding ← Binding
   ↓          ↓          ↓
 Agent1    Agent2     Agent3
```

## 配置示例

```json
{
  "agents": {
    "list": [
      {
        "id": "clawd",
        "name": "通用助手 Clawd",
        "identity": {
          "name": "Clawd"
        },
        "groupChat": {
          "mentionPatterns": ["@clawd", "@clawbot", "@Clawd"],
          "requireMention": true
        }
      },
      {
        "id": "work",
        "name": "工作专家",
        "identity": {
          "name": "WorkBot"
        },
        "groupChat": {
          "mentionPatterns": ["@work", "@workbot", "@工作助手"],
          "requireMention": true
        },
        "tools": {
          "allow": ["read", "exec", "browser", "code"],
          "deny": ["write"]
        }
      },
      {
        "id": "creative",
        "name": "创意助手",
        "identity": {
          "name": "CreativeBot"
        },
        "model": "openrouter/anthropic/claude-opus-4-5-20250929",
        "groupChat": {
          "mentionPatterns": ["@creative", "@创意", "@画画"],
          "requireMention": true
        }
      }
    ]
  },

  "bindings": [
    {
      "agentId": "clawd",
      "match": {
        "channel": "feishu"
      }
    },
    {
      "agentId": "work",
      "match": {
        "channel": "feishu",
        "peer": {
          "kind": "group",
          "id": "shared_group_id"
        }
      }
    },
    {
      "agentId": "creative",
      "match": {
        "channel": "feishu",
        "peer": {
          "kind": "group",
          "id": "shared_group_id"
        }
      }
    }
  ],

  "messages": {
    "ackReactionScope": "group-mentions"
  }
}
```

## 群组使用场景示例

```
用户A: @clawd 今天天气怎么样？
Clawd:  [回复天气信息]

用户B: @work 帮我分析这个代码
WorkBot: [代码分析结果]

用户C: @creative 画一张赛博朋克的城市
CreativeBot: [生成图片]
```

## 提及模式配置要点

```json
"groupChat": {
  "mentionPatterns": ["@机器人名", "@别名1", "@别名2"],
  "requireMention": true  // 群聊中必须 @ 机器人才能触发
}
```

---

# 方案三：飞书平台深度对接方案

## 飞书插件安装

### 安装飞书 Channel 插件

OpenClaw 默认不内置飞书 Channel，需安装第三方插件：

```bash
# 方式1: 使用 clawdbot 插件命令
clawdbot plugins install @m1heng-clawd/feishu

# 方式2: 使用 npm 安装
npm install -g @m1heng-clawd/feishu
```

### 验证插件安装

```bash
# 查看已安装的插件
clawdbot plugins list
```

## 飞书应用配置清单

### 步骤1: 创建企业自建应用

1. 访问 [飞书开放平台](https://open.feishu.cn/)
2. 进入「开发者后台」
3. 点击「创建应用」→「企业自建应用」
4. 填写应用基本信息：
   - 应用名称：如 "OpenClaw 助手"
   - 应用描述：如 "AI 智能助手"
   - 应用图标：（可选）

### 步骤2: 配置应用权限

#### 必需权限清单

| 权限名称 | 权限类型 | 功能描述 |
|---------|---------|----------|
| `contact:user.base:readonly` | User info | 获取基础用户信息 |
| `im:message` | Messaging | 收发消息 |
| `im:message.p2p_msg:readonly` | DM | 读取机器人的私信消息 |
| `im:message.group_at_msg:readonly` | Group | 接收群内@机器人的消息 |
| `im:message:send_as_bot` | Send | 以机器人身份发送消息 |
| `im:resource` | Media | 上传/下载图片/文件 |

#### 可选权限清单

| 权限名称 | 功能描述 |
|---------|----------|
| `im:message.group_msg` | 读取群内所有消息（敏感） |
| `im:message:readonly` | 获取消息历史记录 |
| `im:message:update` | 编辑/更新已发送的消息 |
| `im:message.reactions:read` | 查看消息的互动反馈 |

### 步骤3: 获取应用凭证

在飞书开放平台 → 凭证与基础信息，获取以下信息：

```
App ID: cli_xxxxxxxxxxxxx
App Secret: xxxxxxxxxxxxxxxxxxxxxxxx
Verification Token: verify_token_xxxxx
Encrypt Key: encrypt_key_xxxxx
```

### 步骤4: 配置事件订阅

进入「事件订阅」→「回调配置」：

1. ✅ **启用「加密 Key」**
2. ✅ **勾选「使用长连接接受回调」**
3. ✅ **订阅事件**：
   - `im.message.receive_v1` (接收消息)
   - `application.bot.menu_v1` (菜单点击，可选)

### 步骤5: 发布应用

1. 点击「申请发布」
2. 选择「添加到企业」
3. 等待审核通过（通常即时）

## OpenClaw 配置命令

### 配置飞书参数

```bash
# 设置 App ID
clawdbot config set channels.feishu.appId "cli_xxxxx"

# 设置 App Secret
clawdbot config set channels.feishu.appSecret "your_app_secret"

# 设置 Verification Token（如果需要）
clawdbot config set channels.feishu.verificationToken "verify_token"

# 设置 Encrypt Key（如果需要）
clawdbot config set channels.feishu.encryptKey "encrypt_key"

# 启用飞书 Channel
clawdbot config set channels.feishu.enabled true

# 配置私信策略
clawdbot config set channels.feishu.dmPolicy "allowlist"

# 配置允许列表
clawdbot config set channels.feishu.allowFrom '["+86138xxxx","ou_xxxxx"]'
```

### 重启 Gateway

```bash
# 重启 Gateway 使配置生效
clawdbot gateway restart
```

### 验证状态

```bash
# 检查服务状态
clawdbot status

# 深度健康检查
clawdbot health
```

预期输出：
```
Channels: ✓ Feishu connected
LLM: ✓ DeepSeek API configured
Memory: ✓ 42 memories indexed
```

## 群组接入流程

```
1. 在飞书客户端创建群组
2. 点击群组设置 → 添加机器人
3. 搜索并添加你的自定义应用
4. 设置群组 @ 权限
5. 用户通过 @机器人名称 触发不同 Agent
```

## 飞书使用示例

### 私聊场景

```
你: 你好
Bot: 你好！我是 OpenClaw 助手，有什么可以帮助你的吗？

你: 帮我分析这个日志文件
Bot: [读取并分析日志文件]
```

### 群聊场景

```
用户A: @clawd 今天天气怎么样？
Bot:  [回复天气信息]

用户B: @work 帮我写一段 Python 代码
Bot: [生成代码并解释]

用户C: @creative 生成一个周报模板
Bot: [生成周报模板]
```

---

# 三种方案对比总结

| 维度 | 方案一：多Agent | 方案二：多Bot协作 | 方案三：飞书对接 |
|------|----------------|------------------|----------------|
| **复杂度** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **隔离性** | 完全隔离 | 共享群组 | 平台依赖 |
| **适用场景** | 多用户共享Gateway | 单一群组多专家 | 国内企业协作 |
| **成本** | 单Gateway | 单Gateway/多Bot | 飞书应用免费 |
| **配置难度** | 中等 | 较高 | 较低 |

---

# 常见问题排查

## 问题1: Agent 创建失败

**错误信息**: `Error: Agent already exists`

**解决方案**:
```bash
# 查看现有 Agent 列表
openclaw agents list

# 如需删除现有 Agent
openclaw agents remove <agent-id>
```

## 问题2: 路由规则不生效

**检查步骤**:
```bash
# 查看绑定规则
openclaw agents list --bindings

# 查看日志
openclaw logs tail
```

**常见原因**:
1. bindings 顺序错误（更具体的规则应放在前面）
2. peer ID 不匹配
3. Gateway 未重启

## 问题3: 飞书连接失败

**错误信息**: `Feishu connection failed`

**解决方案**:
1. 检查 App ID 和 App Secret 是否正确
2. 确认飞书应用已发布
3. 验证事件订阅配置
4. 检查网络连接

## 问题4: 群聊中机器人无响应

**可能原因**:
1. 未配置 `groupChat.mentionPatterns`
2. 未 @ 机器人（`requireMention: true`）
3. 权限不足（`im:message.group_at_msg:readonly`）

**解决方案**:
```bash
# 检查群聊配置
openclaw config get channels.feishu

# 确认权限已开启
```

---

# 文件路径清单

配置完成后，关键文件路径：

| 文件 | 路径 |
|------|------|
| 主配置 | `C:\Users\{用户名}\.openclaw\openclaw.json` |
| Agent 列表 | `C:\Users\{用户名}\.openclaw\agents\` |
| 认证配置（main） | `C:\Users\{用户名}\.openclaw\agents\main\agent\auth-profiles.json` |
| 认证配置（work） | `C:\Users\{用户名}\.openclaw\agents\work\agent\auth-profiles.json` |
| 工作空间（main） | `C:\Users\{用户名}\.openclaw\workspace` |
| 工作空间（work） | `C:\Users\{用户名}\.openclaw\workspace-work` |
| 日志文件 | `C:\tmp\openclaw\openclaw-{日期}.log` |
| 插件目录 | `C:\Users\{用户名}\.openclaw\plugins\` |

---

# 完成检查清单

## 方案一：多 Agent 托管

- [ ] 创建额外 Agent（work、family 等）
- [ ] 配置 agents.list
- [ ] 配置 bindings 路由规则
- [ ] 验证路由配置（`openclaw agents list --bindings`）
- [ ] 重启 Gateway
- [ ] 测试不同 Agent 的隔离性

## 方案二：多 Bot 协作

- [ ] 配置多个 Agent 的 groupChat.mentionPatterns
- [ ] 设置 bindings 的 peer 匹配规则
- [ ] 配置 requireMention: true
- [ ] 创建飞书测试群组
- [ ] 添加机器人到群组
- [ ] 测试不同 @ 提及模式

## 方案三：飞书对接

- [ ] 安装飞书插件（`@m1heng-clawd/feishu`）
- [ ] 创建飞书企业自建应用
- [ ] 配置必需权限
- [ ] 获取应用凭证
- [ ] 配置事件订阅（长连接模式）
- [ ] 发布应用
- [ ] 配置 OpenClaw 参数
- [ ] 重启 Gateway
- [ ] 测试私聊功能
- [ ] 测试群聊功能

---

# 参考资源

## 官方文档

- [OpenClaw 官方文档 - 多智能体路由](https://docs.openclaw.ai/zh-CN/concepts/multi-agent)
- [OpenClaw 官方文档 - 智能体工作区](https://docs.openclaw.ai/zh-CN/concepts/agent-workspace)
- [OpenClaw 官方文档 - 多智能体沙箱和工具](https://docs.openclaw.ai/zh-CN/multi-agent-sandbox-tools)
- [HowToUseOpenClaw - 多代理配置](https://howtouseopenclaw.com/zh/concepts/multi-agent)

## 飞书相关

- [飞书官方深度解析文章](https://www.feishu.cn/content/article/7602519239445974205)
- [飞书开放平台](https://open.feishu.cn/)
- [飞书事件订阅文档](https://open.feishu.cn/document/ukTMukTMukTM/uUTNz4SN1MjL1UzM)

## 教程文章

- [阿里云保姆级飞书对接教程](https://developer.aliyun.com/article/1709615)
- [腾讯云飞书保姆级教程](https://cloud.tencent.com/developer/article/2626160)
- [OpenClaw + Kimi 2.5 最新手把手教程](https://zhuanlan.zhihu.com/p/2000938895328698389)
- [OpenClaw 完全指南](https://blog.csdn.net/Yunyi_Chi/article/details/157694870)

---

**方案版本**: 1.0
**创建日期**: 2026-02-04
**适用 OpenClaw 版本**: 2026.2.2-3 及以上
**文档作者**: Claude Code

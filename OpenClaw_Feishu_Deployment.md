# OpenClaw 多 Agent 部署与飞书对接完整方案

## 方案一：一个 Gateway 托管多个独立 Agent

### 核心架构

```
┌─────────────────────────────────────────────────────────┐
│ Gateway (单实例)                                        │
│ 端口: 18789 (本地)                                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐      │
│ │ Agent A      │ │ Agent B      │ │ Agent C      │      │
│ │ (main)       │ │ (work)       │ │ (family)     │      │
│ ├──────────────┤ ├──────────────┤ ├──────────────┤      │
│ │ workspace-a  │ │ workspace-b  │ │ workspace-c  │      │
│ │ agentDir-a   │ │ agentDir-b   │ │ agentDir-c   │      │
│ │ sessions-a   │ │ sessions-b   │ │ sessions-c   │      │
│ │ auth-a.json  │ │ auth-b.json  │ │ auth-c.json  │      │
│ └──────────────┘ └──────────────┘ └──────────────┘      │
│                                                         │
│ Bindings (路由规则)                                     │
│ channel + accountId + peer → agentId                    │
└─────────────────────────────────────────────────────────┘
```

### 配置示例

```json
// ~/.openclaw/openclaw.json
{
  agents: {
    list: [
      {
        id: "main",
        name: "通用助手",
        workspace: "~/.openclaw/workspace",
        agentDir: "~/.openclaw/agents/main/agent",
        default: true,
        model: "openrouter/deepseek/deepseek-chat",
        sandbox: { mode: "off" }
      },
      {
        id: "work",
        name: "工作助手",
        workspace: "~/.openclaw/workspace-work",
        agentDir: "~/.openclaw/agents/work/agent",
        model: "openrouter/anthropic/claude-sonnet-4-5-20250929",
        tools: { allow: ["read", "exec"], deny: ["write", "edit"] }
      },
      {
        id: "family",
        name: "家庭助手",
        workspace: "~/.openclaw/workspace-family",
        agentDir: "~/.openclaw/agents/family/agent",
        groupChat: { mentionPatterns: ["@family", "@familybot"] }
      }
    ]
  },
  bindings: [
    { agentId: "main", match: { channel: "feishu", accountId: "personal" } },
    { agentId: "work", match: { channel: "feishu", accountId: "work" } },
    { agentId: "family", match: { channel: "feishu", peer: { kind: "group", id: "family_group_id" } } }
  ],
  channels: {
    feishu: {
      accounts: {
        personal: { appId: "cli_xxx_a", appSecret: "xxx_secret_a", enabled: true },
        work: { appId: "cli_xxx_b", appSecret: "xxx_secret_b", enabled: true }
      }
    }
  }
}
```

### 实施步骤

1. 创建额外的 Agent
   ```bash
   openclaw agents add work
   openclaw agents add family
   ```

2. 验证路由配置
   ```bash
   openclaw agents list --bindings
   ```

3. 重启 Gateway 生效
   ```bash
   openclaw gateway restart
   ```

### 关键特性

| 特性       | 说明                                                                 |
|------------|----------------------------------------------------------------------|
| 完全隔离   | 每个 Agent 有独立的工作区、认证、会话                               |
| 路由优先级 | peer 精确匹配 > accountId > channel                                 |
| 沙箱隔离   | 每个 Agent 可配置独立的沙箱和工具权限                               |
| 凭证独立   | 每个 Agent 从各自的 `auth-profiles.json` 读取                       |

---

## 方案二：多个 Clawbot 同一群组协作

### 架构模式

**模式 A：多 Agent + 单 Bot Token（推荐）**

```
┌────────────────────────────────────────────────────────┐
│ 飞书群组                                                │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐                     │
│ │ 用户 A  │ │ 用户 B  │ │ 用户 C  │                     │
│ └─────────┘ └─────────┘ └─────────┘                     │
│                                                         │
│ @clawd → @work → @family                                │
│ ↓        ↓        ↓                                     │
│ ┌─────────────────────────────────────────────────┐    │
│ │ 单一飞书 Bot 应用                                │    │
│ │ (单个 App ID/Secret)                            │    │
│ └─────────────────────────────────────────────────┘    │
│ ↓                                                     │
│ ┌─────────────────────────────────────────────────┐    │
│ │ OpenClaw Gateway                                │    │
│ │ 根据 @提及 模式路由到不同 Agent                   │    │
│ └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

**模式 B：多 Bot 应用（需多个飞书应用）**

```
飞书群组: [Bot1] [Bot2] [Bot3] [用户] [用户]
↓        ↓        ↓
Gateway ← Binding ← Binding ← Binding
↓        ↓        ↓
Agent1   Agent2   Agent3
```

### 配置示例

```json
{
  agents: {
    list: [
      {
        id: "clawd",
        name: "通用助手 Clawd",
        identity: { name: "Clawd" },
        groupChat: { mentionPatterns: ["@clawd", "@clawbot", "@Clawd"], requireMention: true }
      },
      {
        id: "work",
        name: "工作专家",
        identity: { name: "WorkBot" },
        groupChat: { mentionPatterns: ["@work", "@workbot", "@工作助手"], requireMention: true },
        tools: { allow: ["read", "exec", "browser", "code"], deny: ["write"] }
      },
      {
        id: "creative",
        name: "创意助手",
        identity: { name: "CreativeBot" },
        model: "openrouter/anthropic/claude-opus-4-5-20250929",
        groupChat: { mentionPatterns: ["@creative", "@创意", "@画画"], requireMention: true }
      }
    ]
  },
  bindings: [
    // 默认路由到 clawd
    { agentId: "clawd", match: { channel: "feishu" } },
    // 同一群组内的 @提及 路由
    { agentId: "work", match: { channel: "feishu", peer: { kind: "group", id: "shared_group_id" } } },
    { agentId: "creative", match: { channel: "feishu", peer: { kind: "group", id: "shared_group_id" } } }
  ],
  messages: {
    // 群聊中必须 @ 机器人才能触发
    ackReactionScope: "group-mentions"
  },
  channels: {
    feishu: {
      enabled: true,
      appId: "cli_xxxxx",
      appSecret: "xxxxx",
      dmPolicy: "allowlist",
      allowFrom: ["+86138xxxx", "ou_xxxxx"] // 白名单用户
    }
  }
}
```

### 群组使用场景

- **用户A**: `@clawd` 今天天气怎么样？
  - **Clawd**: [回复天气信息]
- **用户B**: `@work` 帮我分析这个代码
  - **WorkBot**: [代码分析结果]
- **用户C**: `@creative` 画一张赛博朋克的城市
  - **CreativeBot**: [生成图片]

---

## 方案三：飞书平台深度对接方案

### 飞书插件安装

```bash
# OpenClaw 默认不内置飞书 Channel，需安装插件
clawdbot plugins install @m1heng-clawd/feishu

# 或使用 npm
npm install -g @m1heng-clawd/feishu
```

### 飞书应用配置清单

| 步骤 | 操作                     | 说明                                   |
|------|--------------------------|----------------------------------------|
| 1    | 创建企业自建应用         | 飞书开放平台 → 创建应用 → 企业自建应用 |
| 2    | 配置基础权限             | 见下方权限清单                         |
| 3    | 获取凭证                 | App ID、App Secret、Verification Token、Encrypt Key |
| 4    | 配置事件订阅             | 启用「加密key」、勾选「使用长连接接受回调」 |
| 5    | 发布应用                 | 申请发布 → 添加到企业                  |

### 必需权限清单

- **基础权限**:
  - `contact:user.base:readonly` # 获取用户信息
  - `im:message` # 收发消息
  - `im:message.p2p_msg:readonly` # 读取私信
  - `im:message.group_at_msg:readonly` # 接收群@消息
  - `im:message:send_as_bot` # 以机器人发送
  - `im:resource` # 上传/下载文件

- **可选权限**:
  - `im:message.group_msg` # 读取群内所有消息 (敏感)
  - `im:message:readonly` # 获取历史消息
  - `im:message:update` # 编辑消息
  - `im:message.reactions:read` # 查看互动反馈

### OpenClaw 配置命令

```bash
# 配置飞书参数
clawdbot config set channels.feishu.appId "cli_xxxxx"
clawdbot config set channels.feishu.appSecret "your_app_secret"
clawdbot config set channels.feishu.verificationToken "verify_token"
clawdbot config set channels.feishu.encryptKey "encrypt_key"
clawdbot config set channels.feishu.enabled true

# 重启 Gateway
clawdbot gateway restart

# 验证状态
clawdbot status
clawdbot health
```

### 飞书回调配置

在飞书开放平台 → 事件订阅 → 回调配置：
- ✅ 启用「加密 Key」
- ✅ 勾选「使用长连接接受回调」
- ✅ 订阅事件：
  - `im.message.receive_v1` (接收消息)
  - `application.bot.menu_v1` (菜单点击)

### 群组接入流程

1. 创建飞书群组
2. 添加机器人到群组
3. 设置群组 @权限
4. 用户通过 `@机器人名称` 触发不同 Agent

---

## 三种方案对比总结

| 维度       | 方案一：多Agent         | 方案二：多Bot协作         | 方案三：飞书对接         |
|------------|-------------------------|---------------------------|-------------------------|
| 复杂度     | ⭐⭐                     | ⭐⭐⭐                      | ⭐⭐                     |
| 隔离性     | 完全隔离                | 共享群组                  | 平台依赖                |
| 适用场景   | 多用户共享Gateway       | 单一群组多专家            | 国内企业协作            |
| 成本       | 单Gateway               | 单Gateway/多Bot           | 飞书应用免费            |

### 参考资源

- [OpenClaw 官方文档 - 多智能体路由](https://docs.openclaw.ai)
- [飞书官方深度解析文章](https://open.feishu.cn)
- [HowToUseOpenClaw - 多代理配置](https://github.com/openclaw/howto)
- [阿里云飞书对接教程](https://help.aliyun.com)
- [腾讯云飞书保姆级教程](https://cloud.tencent.com)

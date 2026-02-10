# 钉钉双向交互配置指南

**配置日期**：2026-02-08
**插件版本**：@adongguo/openclaw-dingtalk v0.1.1
**状态**：✅ 插件已安装

---

## 第一步：创建钉钉企业应用（必须）

### 1.1 登录钉钉开放平台

访问：https://open.dingtalk.com/

使用钉钉账号扫码登录。

### 1.2 创建企业内部应用

1. 点击顶部导航：**应用开发** → **企业内部开发**
2. 点击 **创建应用** 按钮
3. 填写应用信息：
   - **应用名称**：OpenClaw AI 助手（或自定义）
   - **应用描述**：个人 AI 智能助手
   - **应用图标**：上传或使用默认
4. 点击 **创建完成**

### 1.3 获取应用凭证

在应用详情页面，找到并记录以下信息：

```
AppKey（Client ID）：cli_xxxxxxxxxxxxx
AppSecret（Client Secret）：xxxxxxxxxxxxxxxxxxxx
```

⚠️ **重要**：请妥善保存这两个值，后续配置需要使用！

### 1.4 配置应用权限

在 **权限管理** 页面，申请以下权限：

#### 基础权限
- ✅ **消息通知**：发送工作通知
- ✅ **机器人**：使用机器人能力

#### 互动权限（可选，但推荐）
- ✅ **个人信息的头像**：获取用户头像
- ✅ **个人信息的昵称**：获取用户昵称
- ✅ **联系人读取**：读取联系人信息（如需要）

#### 权限申请流程
1. 勾选需要的权限
2. 点击 **申请**
3. 填写申请理由（如："用于 AI 助手功能"）
4. 提交审核（通常即时通过）

### 1.5 发布应用

1. 在应用详情页，点击 **版本管理与发布**
2. 点击 **创建新版本**
3. 版本号：1.0.0
4. 描述：初始版本
5. 点击 **保存**
6. 点击 **发布** 按钮

### 1.6 添加机器人能力（可选但推荐）

1. 在应用详情页，找到 **添加能力** → **机器人**
2. 点击 **添加**
3. 配置机器人信息：
   - **机器人名称**：OpenClaw 助手
   - **机器人介绍**：您的个人 AI 助手
4. 保存配置

---

## 第二步：配置 OpenClaw

### 2.1 创建配置文件

钉钉插件的配置文件位置：

```bash
~/.openclaw/channels/dingtalk/config.json
```

### 2.2 编辑配置文件

创建并编辑配置文件：

```bash
# 创建目录
mkdir -p ~/.openclaw/channels/dingtalk

# 编辑配置文件
nano ~/.openclaw/channels/dingtalk/config.json
```

粘贴以下内容（替换您的实际凭证）：

```json
{
  "enabled": true,
  "mode": "stream",
  "credentials": {
    "appKey": "cli_xxxxxxxxxxxxx",
    "appSecret": "xxxxxxxxxxxxxxxxxxxx"
  },
  "features": {
    "privateChat": true,
    "groupChat": true,
    "streamMode": true
  }
}
```

**配置说明**：

| 参数 | 说明 | 必填 |
|------|------|------|
| `enabled` | 是否启用钉钉通道 | ✅ |
| `mode` | 连接模式：`stream`（推荐）或 `webhook` | ✅ |
| `appKey` | 钉钉应用的 AppKey | ✅ |
| `appSecret` | 钉钉应用的 AppSecret | ✅ |
| `privateChat` | 是否支持私聊 | ✅ |
| `groupChat` | 是否支持群聊 | ✅ |
| `streamMode` | 是否使用 Stream 模式（WebSocket） | ✅ |

### 2.3 保存并退出

- **Nano 编辑器**：按 `Ctrl+O` 保存，按 `Ctrl+X` 退出
- **Vim 编辑器**：按 `Esc`，输入 `:wq`，按 `Enter`

---

## 第三步：启用钉钉通道

### 3.1 重启 OpenClaw Gateway

```bash
# 重启 gateway
openclaw gateway restart

# 或如果使用的是完整服务
openclaw restart
```

### 3.2 验证配置

```bash
# 检查 gateway 状态
openclaw gateway status

# 查看日志
openclaw gateway logs --follow
```

如果看到类似以下日志，说明配置成功：

```
[INFO] DingTalk channel enabled
[INFO] DingTalk Stream mode connected
[INFO] Listening for messages...
```

---

## 第四步：测试双向交互

### 4.1 添加机器人为好友

#### 方式一：通过钉钉搜索
1. 打开钉钉手机客户端
2. 点击右上角 **+** 号
3. 选择 **添加好友** → **搜索手机号/钉钉号**
4. 搜索您的应用名称或 AppKey
5. 点击 **添加好友**

#### 方式二：通过企业通讯录
1. 在钉钉客户端，进入 **通讯录**
2. 找到 **企业应用**
3. 找到您创建的 "OpenClaw AI 助手" 应用
4. 点击进入即可开始对话

### 4.2 私聊测试

在钉钉中向机器人发送消息：

```
用户：你好
机器人：您好！我是 OpenClaw AI 助手，有什么可以帮您的吗？

用户：今天天气怎么样？
机器人：[AI 回复天气信息]
```

### 4.3 群聊测试

1. 在钉钉中创建一个群聊
2. 将机器人添加到群聊
3. 在群里 **@机器人**：

```
@OpenClaw AI 助手 帮我写一个 Python 函数
机器人：[AI 生成代码]
```

---

## 高级配置（可选）

### A. 使用 Webhook 模式

如果您有公网域名，可以使用 Webhook 模式：

```json
{
  "enabled": true,
  "mode": "webhook",
  "credentials": {
    "appKey": "cli_xxxxxxxxxxxxx",
    "appSecret": "xxxxxxxxxxxxxxxxxxxx"
  },
  "webhook": {
    "url": "https://your-domain.com/dingtalk/events",
    "token": "your_random_token",
    "encodingAESKey": "your_aes_key"
  },
  "features": {
    "privateChat": true,
    "groupChat": true
  }
}
```

**注意**：Webhook 模式需要：
- 公网 IP 或域名
- 配置 HTTPS 证书
- 开放端口（如 443）

### B. 自定义消息格式

在配置文件中添加：

```json
{
  "messageFormat": {
    "enableMarkdown": true,
    "enableCard": true,
    "maxTextLength": 2000
  }
}
```

### C. 配置白名单（可选）

限制只有特定用户可以使用：

```json
{
  "accessControl": {
    "enabled": true,
    "allowedUsers": ["user1@example.com", "user2@example.com"],
    "allowedGroups": ["group_id_1", "group_id_2"]
  }
}
```

---

## 常见问题

### Q1: 机器人没有回复？

**排查步骤**：

1. 检查 OpenClaw 日志：
   ```bash
   openclaw gateway logs --follow
   ```

2. 检查配置文件是否正确：
   ```bash
   cat ~/.openclaw/channels/dingtalk/config.json
   ```

3. 验证 AppKey 和 AppSecret 是否正确

4. 确认应用是否已发布

### Q2: Stream 模式连接失败？

**可能原因**：
- 网络问题：检查防火墙设置
- 凭证错误：重新验证 AppKey 和 AppSecret
- 应用未发布：确认应用已发布到企业

**解决方案**：
```bash
# 测试网络连接
curl -v https://api.dingtalk.com

# 重启 gateway
openclaw gateway restart
```

### Q3: 如何获取钉钉用户 ID？

在钉钉开放平台，使用 **通讯录权限管理** 可以查看企业成员的 UserID。

### Q4: 群聊中 @机器人 不生效？

**检查**：
1. 机器人是否已添加到群聊
2. 群聊是否开启了机器人功能
3. @ 的名称是否正确

---

## 配置完成检查清单

- [ ] ✅ 已创建钉钉企业内部应用
- [ ] ✅ 已获取 AppKey 和 AppSecret
- [ ] ✅ 已申请必要权限
- [ ] ✅ 已发布应用
- [ ] ✅ 已创建配置文件 `~/.openclaw/channels/dingtalk/config.json`
- [ ] ✅ 已重启 OpenClaw Gateway
- [ ] ✅ 日志显示连接成功
- [ ] ✅ 已添加机器人为好友
- [ ] ✅ 私聊测试成功
- [ ] ✅ 群聊测试成功

---

## 下一步

配置完成后，您可以：

1. **个性化 AI**：编辑 `SOUL.md` 定制 AI 的性格
2. **添加技能**：安装更多插件扩展功能
3. **配置定时任务**：设置自动提醒和报告
4. **多通道部署**：同时配置飞书、企业微信等

---

## 需要帮助？

如果遇到问题：

1. 查看日志：`openclaw gateway logs --follow`
2. 运行诊断：`openclaw doctor --fix`
3. 参考文档：`docs/OPENCLAW-CHANNELS-RESEARCH-2026.md`
4. 社区支持：[CoClaw 社区](https://coclaw.com/)

---

**配置状态**：
- ✅ 钉钉插件已安装
- ⏳ 等待创建钉钉应用和获取凭证
- ⏳ 等待配置 OpenClaw
- ⏳ 等待测试双向交互

**预计完成时间**：15-30 分钟

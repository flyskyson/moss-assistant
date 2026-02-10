# Bark 推送通知技能

> **版本**: 1.0.0
> **作者**: MOSS
> **状态**: 生产就绪

---

## 概述

这是一个 OpenClaw 技能，用于通过 Bark 服务向 iOS/Android 设备发送推送通知。

**适用场景**：
- 系统警报和错误通知
- 任务完成通知
- 定时提醒
- 每日简报推送
- AI 消息通知

---

## 前置条件

### 1. 部署 Bark 服务器

已部署在：`http://8.163.19.50:8080`

部署指南：[docs/bark-deployment-guide.md](../../docs/bark-deployment-guide.md)

### 2. 安装 Bark 应用

- **iOS**: 在 App Store 搜索 "Bark" 并下载
- **Android**: 在 Google Play 或应用商店下载 "Bark"

### 3. 获取设备密钥

打开 Bark 应用，会自动显示您的设备密钥（类似：`xxxxxxxxxxxxxxxxxxxxxxxxxxxx`）

---

## 安装技能

### 步骤 1：配置环境变量

编辑 `~/.openclaw/openclaw.json`，在环境变量部分添加：

```json
{
  "gateway": {
    "auth": {
      "mode": "token",
      "token": "your-token"
    }
  },
  "skills": {
    "install": {
      "nodeManager": "pnpm"
    },
    "env": {
      "BARK_SERVER": "http://8.163.19.50:8080",
      "BARK_DEVICE_KEY": "你的设备密钥"
    }
  }
}
```

### 步骤 2：重启 Gateway

```bash
# 重新加载配置
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist

# 验证服务状态
curl http://localhost:18789/health
```

---

## 使用方法

### 基础用法

```bash
# 发送简单通知
openclaw agent --message "/bark \"测试\" \"这是一条测试消息\""

# 发送带声音的通知
openclaw agent --message "/bark \"任务完成\" \"代码已部署\" --sound=bell"

# 发送带分组的通知
openclaw agent --message "/bark \"错误\" \"服务异常\" --sound=alarm --group=警报"
```

### 在脚本中使用

```typescript
import { sendBark, BarkPresets } from './skills/bark-push'

// 发送简单通知
await sendBark('标题', '内容')

// 使用预设
await BarkPresets.taskComplete('代码部署')
await BarkPresets.error('数据库连接失败')
await BarkPresets.dailyBriefing('今日简报内容')
```

### 在 Bash 脚本中使用

```bash
#!/bin/bash

# 定义推送函数
bark_notify() {
    local title="$1"
    local body="$2"
    local sound="${3:-bell}"

    openclaw agent --message "/bark \"$title\" \"$body\" --sound=$sound"
}

# 使用示例
bark_notify "任务完成" "备份已完成"
bark_notify "错误警报" "磁盘空间不足" "alarm"
```

---

## 可用参数

### 基础参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 通知标题 |
| body | string | 是 | 通知内容 |

### 可选参数

| 参数 | 类型 | 说明 |
|------|------|------|
| sound | string | 通知声音 |
| group | string | 通知分组 |
| badge | number | 角标数字 |
| url | string | 点击通知跳转的 URL |
| icon | string | 自定义图标 URL |
| level | string | 通知级别：timeless/passive/active |

---

## 可用声音

```
- bell (默认)
- healthnotification
- alarm
- anticipate
- bloom
- calypso
- choochoo
- descent
- fanfare
- ladder
- minuet
- newsflash
- noir
- sherwood
- spell
- suspense
- telegraph
- tiptoes
- typewriters
- update
```

完整声音列表：[iOS 系统声音](https://github.com/Finb/Bark/tree/master/Sounds)

---

## 预设通知类型

### 1. 系统通知

```typescript
await BarkPresets.system('系统更新', '新版本已发布')
```

### 2. 任务完成

```typescript
await BarkPresets.taskComplete('代码部署')
```

### 3. 错误警报

```typescript
await BarkPresets.error('数据库连接失败')
```

### 4. 每日简报

```typescript
await BarkPresets.dailyBriefing('今日 AI 技术动态...')
```

### 5. AI 消息

```typescript
await BarkPresets.aiMessage('MOSS: 任务已完成')
```

### 6. 定时提醒

```typescript
await BarkPresets.reminder('会议提醒', '10分钟后开始')
```

---

## 使用示例

### 示例 1：每日简报集成

```bash
#!/bin/bash
# daily-briefing.sh

# 生成简报
BRIEFING=$(python3 generate_briefing.py)

# 发送到设备
openclaw agent --message "/bark \"每日简报\" \"$BRIEFING\" --sound=anticipate --group=简报"
```

### 示例 2：错误监控

```typescript
// 在您的应用中
try {
  await riskyOperation()
} catch (error) {
  await BarkPresets.error(`操作失败: ${error.message}`)
}
```

### 示例 3：长时间任务通知

```bash
#!/bin/bash
# long-task.sh

openclaw agent --message "/balk \"任务开始\" \"正在部署...\" --sound=bell"

# 执行任务
deploy_app

openclaw agent --message "/bark \"任务完成\" \"部署成功！\" --sound=healthnotification"
```

---

## 故障排查

### 问题 1：未收到推送

**检查清单**：
- ✓ Bark 应用是否开启通知权限
- ✓ 设备密钥是否正确
- ✓ 服务器是否可访问：`curl http://8.163.19.50:8080/ping`
- ✓ 阿里云安全组是否开放 8080 端口

### 问题 2：环境变量未生效

**解决方案**：
```bash
# 检查 Gateway 环境变量
launchctl export ai.openclaw.gateway | grep BARK

# 重启 Gateway
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

### 问题 3：推送格式错误

**调试**：
```bash
# 直接测试 Bark API
curl -X POST "http://8.163.19.50:8080/你的设备密钥/测试/内容"

# 查看 Gateway 日志
tail -f ~/.openclaw/logs/gateway.log
```

---

## API 参考

### sendBark(title, body, options)

发送基础 Bark 推送。

**参数**：
- `title` (string): 通知标题
- `body` (string): 通知内容
- `options` (object): 可选参数
  - `sound` (string): 通知声音
  - `group` (string): 通知分组
  - `badge` (number): 角标数字
  - `url` (string): 跳转链接
  - `level` (string): 通知级别

**返回**：Promise<boolean>

---

### sendAdvancedBark(title, body, options)

发送高级 Bark 推送（JSON 格式）。

**参数**：同 `sendBark`

**返回**：Promise<boolean>

---

## 安全建议

1. **设备密钥保护**：不要将设备密钥提交到公开仓库
2. **访问控制**：建议使用 HTTPS + Basic Auth 保护 Bark 服务器
3. **消息过滤**：避免发送敏感信息（密码、密钥等）

---

## 未来增强

- [ ] 支持多设备推送
- [ ] 推送模板系统
- [ ] 推送历史记录
- [ ] Webhook 集成
- [ ] 推送定时任务

---

## 相关资源

- [Bark 官方文档](https://github.com/Finb/Bark)
- [部署指南](../../docs/bark-deployment-guide.md)
- [OpenClaw 技能开发文档](https://openclaw.dev/docs/skills)

---

**MOSS** - 2026-02-07

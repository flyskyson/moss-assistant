# QQ 机器人配置完整指南（NapCat + OpenClaw）

**配置日期**：2026-02-08
**适用场景**：个人 AI 助手、双向交互
**预计完成时间**：10-15 分钟

---

## 📋 配置概览

```
第1步：安装 NapCat（3-5分钟）
   ↓
第2步：登录 QQ 账号（1分钟）
   ↓
第3步：配置 OpenClaw（2分钟）
   ↓
第4步：测试双向交互（2分钟）
```

### 前置要求

- ✅ macOS 电脑（您当前的系统）
- ✅ 一个 QQ 号（您现有的就可以）
- ✅ OpenClaw 已安装并运行
- ✅ 网络连接正常

---

## 第1步：安装 NapCat

### 方案 A：使用 Docker（最简单）⭐⭐⭐⭐⭐

#### 1.1 检查 Docker 是否已安装

```bash
# 检查 Docker 是否安装
docker --version

# 如果显示版本号，说明已安装，跳到 1.3
# 如果提示"command not found"，继续 1.2
```

#### 1.2 安装 Docker

**macOS 安装 Docker**：

```bash
# 使用 Homebrew 安装（推荐）
brew install --cask docker

# 或者访问官网下载安装包
# https://www.docker.com/products/docker-desktop/
```

**启动 Docker**：
1. 打开 **应用程序** → **Docker**
2. 等待 Docker 启动（菜单栏出现鲸鱼图标）
3. 确认状态：`docker ps` 不报错

#### 1.3 拉取并运行 NapCat

```bash
# 拉取 NapCat Docker 镜像
docker pull mlikiowa/napcat-docker:latest

# 创建配置目录
mkdir -p ~/napcat/config

# 运行 NapCat 容器
docker run -d \
  --name napcat \
  --restart=unless-stopped \
  -p 3000:3000 \
  -p 6099:6099 \
  -v ~/napcat/config:/app/config \
  mlikiowa/napcat-docker:latest

# 查看容器状态
docker ps | grep napcat

# 应该看到 napcat 容器正在运行
```

**如果看到错误**：
```bash
# 查看容器日志
docker logs napcat

# 重启容器
docker restart napcat
```

---

### 方案 B：直接下载运行（备选）

#### 1.1 下载 NapCat

访问 GitHub Releases：
```
https://github.com/Mlikiowa/NapCat-qq/releases
```

**下载**：
- 选择最新版本
- 下载 `NapCat-Desktop-macOS-xxx.dmg`
- 或 `NapCat-Server-macOS-xxx.zip`

#### 1.2 安装并运行

**DMG 安装**：
1. 打开下载的 `.dmg` 文件
2. 将 NapCat 拖到 **应用程序**
3. 打开 **NapCat** 应用

**ZIP 压缩包**：
1. 解压下载的 `.zip` 文件
2. 进入解压后的目录
3. 运行：`./NapCat`

---

## 第2步：登录 QQ 账号

### 2.1 配置 QQ 账号信息

#### 如果使用 Docker

```bash
# 编辑配置文件
nano ~/napcat/config/config.json
```

#### 如果使用本地版本

打开 NapCat 应用，找到配置文件位置，编辑 `config.json`

### 2.2 配置内容

```json
{
  "qq": "您的QQ号",
  "password": "",
  "loginType": 2,
  "ws_port": 3000,
  "http_port": 6099,
  "heartbeat": {
    "enable": true,
    "interval": 30000
  }
}
```

**配置说明**：

| 参数 | 说明 | 示例 |
|------|------|------|
| `qq` | 您的 QQ 号 | "123456789" |
| `password` | QQ 密码（留空扫码登录） | "" |
| `loginType` | 登录方式：2=扫码，3=密码 | 2 |
| `ws_port` | WebSocket 端口 | 3000 |
| `http_port` | HTTP API 端口 | 6099 |

**保存并退出**：
- Nano：`Ctrl+O` → `Enter` → `Ctrl+X`

### 2.3 重启 NapCat 并登录

```bash
# 如果使用 Docker
docker restart napcat

# 等待 5 秒
sleep 5

# 查看日志
docker logs -f napcat
```

**如果使用本地版本**：
1. 重启 NapCat 应用
2. 查看日志窗口

### 2.4 扫码登录 QQ

**日志中会显示二维码信息**：

```
[INFO] 请使用手机 QQ 扫码登录
[INFO] 二维码已保存到: /app/data/qrcode.png
```

**扫码步骤**：
1. 使用 Docker 的话，查看二维码：
   ```bash
   # 在 macOS 上查看二维码
   open ~/napcat/config/qrcode.png
   ```

2. 打开手机 QQ
3. 点击 **+** 号 → **扫一扫**
4. 扫描二维码
5. 在手机上确认登录

**登录成功后日志显示**：
```
[INFO] 登录成功！
[INFO] QQ 账号：123456789
[INFO] WebSocket 服务已启动：ws://localhost:3000
[INFO] HTTP API 已启动：http://localhost:6099
```

**按 `Ctrl+C` 退出日志查看**（容器继续运行）

---

## 第3步：配置 OpenClaw

### 3.1 创建 QQ 通道配置

```bash
# 创建配置目录
mkdir -p ~/.openclaw/channels/qq

# 创建配置文件
nano ~/.openclaw/channels/qq/config.json
```

### 3.2 配置内容

**复制以下内容**（替换您的 QQ 号）：

```json
{
  "enabled": true,
  "mode": "websocket",
  "endpoint": "ws://localhost:3000",
  "credentials": {
    "qq": "您的QQ号"
  },
  "features": {
    "privateChat": true,
    "groupChat": true,
    "messageType": ["text", "image", "face"]
  },
  "agent": "main"
}
```

**配置说明**：

| 参数 | 说明 | 值 |
|------|------|-----|
| `enabled` | 是否启用 | `true` |
| `mode` | 连接模式 | `websocket` |
| `endpoint` | WebSocket 地址 | `ws://localhost:3000` |
| `qq` | QQ 号 | "123456789" |
| `privateChat` | 私聊支持 | `true` |
| `groupChat` | 群聊支持 | `true` |
| `agent` | 使用的 Agent | `"main"` |

**保存并退出**

### 3.3 验证配置

```bash
# 检查 JSON 格式
python3 -m json.tool ~/.openclaw/channels/qq/config.json

# 应该显示格式化的 JSON，无错误
```

---

## 第4步：启用并重启 OpenClaw

### 4.1 重启 Gateway

```bash
# 重启 OpenClaw Gateway
openclaw gateway restart

# 等待启动
sleep 5

# 检查状态
openclaw gateway status
```

### 4.2 查看 Gateway 日志

```bash
# 查看日志，确认 QQ 通道已加载
openclaw gateway logs --follow | head -50
```

**应该看到类似日志**：
```
[INFO] Loading channel: qq
[INFO] QQ channel enabled
[INFO] Connecting to NapCat WebSocket: ws://localhost:3000
[INFO] QQ connected successfully: 123456789
[INFO] Waiting for messages...
```

**如果看到错误**：
- 检查 NapCat 是否运行：`docker ps | grep napcat`
- 检查端口是否正确：`lsof -i :3000`
- 查看完整日志：`openclaw gateway logs --follow`

---

## 第5步：测试双向交互

### 5.1 私聊测试

#### 方法 1：自己给自己发消息

**在 QQ 中**：
1. 打开 QQ
2. 点击 **我的** → **我的资料**
3. 点击 **发送消息**（或"我的电脑"）
4. 发送测试消息：**你好**

**应该收到 AI 回复**：
```
AI：您好！我是 OpenClaw AI 助手，有什么可以帮您的吗？
```

#### 方法 2：让朋友测试

1. 添加机器人 QQ 为好友
2. 让朋友发送消息：**你好**
3. 应该收到 AI 回复

### 5.2 群聊测试

**在 QQ 群中**：

1. 创建或选择一个 QQ 群
2. 确保机器人 QQ 在群里
3. 发送消息（不一定要 @）：
   ```
   测试消息
   ```
4. 机器人应该回复

**注意**：根据配置，机器人可能会回复所有消息，或只在被 @ 时回复。

### 5.3 查看日志验证

```bash
# 查看实时日志
openclaw gateway logs --follow
```

**应该看到**：
```
[INFO] Received message from QQ: 你好
[INFO] Processing message...
[INFO] Sending reply: 您好！我是 OpenClaw AI 助手...
[INFO] Message sent successfully
```

---

## 第6步：高级配置（可选）

### 6.1 配置自动回复规则

编辑 OpenClaw 的 QQ 配置：

```bash
nano ~/.openclaw/channels/qq/config.json
```

**添加回复规则**：

```json
{
  "enabled": true,
  "mode": "websocket",
  "endpoint": "ws://localhost:3000",
  "credentials": {
    "qq": "您的QQ号"
  },
  "features": {
    "privateChat": true,
    "groupChat": true,
    "autoReply": true,
    "replyWhenMentioned": false
  },
  "filters": {
    "blacklist": [],
    "whitelist": [],
    "keywords": {
      "帮助": "我可以帮您：\n1. 回答问题\n2. 执行任务\n3. 提供信息",
      "时间": "当前时间：$(date)"
    }
  },
  "agent": "main"
}
```

**保存并重启**：
```bash
openclaw gateway restart
```

### 6.2 配置群聊行为

**只在被 @ 时回复**：

```json
{
  "features": {
    "groupChat": true,
    "replyWhenMentioned": true,
    "ignoreOtherBots": true
  }
}
```

**回复所有消息**：

```json
{
  "features": {
    "groupChat": true,
    "replyWhenMentioned": false
  }
}
```

### 6.3 配置消息类型

**支持的消息类型**：

```json
{
  "features": {
    "messageType": ["text", "image", "face", "at", "record"]
  }
}
```

| 类型 | 说明 |
|------|------|
| `text` | 文本消息 |
| `image` | 图片消息 |
| `face` | 表情 |
| `at` | @ 提醒 |
| `record` | 语音 |

---

## 常见问题排查

### Q1: Docker 容器无法启动

**检查**：
```bash
# 查看 Docker 状态
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看容器日志
docker logs napcat
```

**解决**：
```bash
# 重启 Docker
# macOS：菜单栏 → Docker → Restart

# 重启容器
docker restart napcat
```

### Q2: 无法扫码登录

**原因**：二维码文件路径问题

**解决**：
```bash
# 查找二维码文件
find ~/napcat -name "qrcode.png"

# 查看二维码
open ~/napcat/config/qrcode.png

# 或使用手机 QQ 直接扫描 NapCat 界面的二维码
```

### Q3: OpenClaw 无法连接 NapCat

**检查**：
```bash
# 测试 WebSocket 连接
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  http://localhost:3000

# 检查端口是否开放
lsof -i :3000
```

**解决**：
```bash
# 确保 NapCat 正在运行
docker ps | grep napcat

# 重启 NapCat
docker restart napcat

# 重启 OpenClaw
openclaw gateway restart
```

### Q4: 机器人不回复消息

**排查步骤**：

1. **检查 NapCat 日志**：
   ```bash
   docker logs napcat | tail -50
   ```

2. **检查 OpenClaw 日志**：
   ```bash
   openclaw gateway logs --follow
   ```

3. **确认 QQ 配置**：
   ```bash
   cat ~/.openclaw/channels/qq/config.json
   ```

4. **测试 Gateway 状态**：
   ```bash
   openclaw gateway status
   ```

### Q5: QQ 账号被限制

**预防措施**：
- ⚠️ 不要短时间内大量添加好友
- ⚠️ 不要高频发送消息（建议每秒 < 5 条）
- ⚠️ 不要加入过多群聊
- ✅ 使用日常使用的 QQ 号
- ✅ 避免明显的机器人行为

**如果被限制**：
1. 等待 24 小时自动解除
2. 使用手机 QQ 验证
3. 更换 QQ 号

### Q6: NapCat 更新

```bash
# 停止并删除旧容器
docker stop napcat
docker rm napcat

# 拉取最新镜像
docker pull mlikiowa/napcat-docker:latest

# 重新运行
docker run -d \
  --name napcat \
  --restart=unless-stopped \
  -p 3000:3000 \
  -p 6099:6099 \
  -v ~/napcat/config:/app/config \
  mlikiowa/napcat-docker:latest
```

---

## 维护和监控

### 定期检查

**创建检查脚本**：

```bash
cat > ~/clawd/scripts/check-qq-bot.sh << 'EOF'
#!/bin/bash
# QQ 机器人状态检查脚本

echo "🤖 QQ 机器人状态检查"
echo "=================="
echo ""

# 检查 Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker 已安装"

    # 检查 NapCat 容器
    if docker ps | grep -q napcat; then
        echo "✅ NapCat 容器运行中"
    else
        echo "❌ NapCat 容器未运行"
        echo "   启动命令：docker start napcat"
    fi
else
    echo "❌ Docker 未安装"
fi

echo ""

# 检查 OpenClaw
if openclaw gateway status > /dev/null 2>&1; then
    echo "✅ OpenClaw Gateway 运行中"
else
    echo "❌ OpenClaw Gateway 未运行"
    echo "   启动命令：openclaw gateway start"
fi

echo ""

# 检查端口
if lsof -i :3000 > /dev/null 2>&1; then
    echo "✅ NapCat WebSocket 端口 3000 已开放"
else
    echo "❌ NapCat WebSocket 端口 3000 未开放"
fi

echo ""
echo "📋 查看日志："
echo "   NapCat:  docker logs -f napcat"
echo "   OpenClaw: openclaw gateway logs --follow"
EOF

chmod +x ~/clawd/scripts/check-qq-bot.sh
```

**定期运行**：
```bash
# 每天运行一次检查
~/clawd/scripts/check-qq-bot.sh

# 或添加到 crontab
crontab -e

# 添加：
0 9 * * * /Users/yourname/clawd/scripts/check-qq-bot.sh >> ~/clawd/logs/qq-bot-check.log 2>&1
```

---

## 完成检查清单

- [ ] ✅ Docker 已安装并运行
- [ ] ✅ NapCat 容器已启动
- [ ] ✅ QQ 账号已登录（扫码成功）
- [ ] ✅ QQ 配置文件已创建
- [ ] ✅ OpenClaw Gateway 已重启
- [ ] ✅ 日志显示连接成功
- [ ] ✅ 私聊测试成功
- [ ] ✅ 群聊测试成功（可选）
- [ ] ✅ 自动回复规则已配置（可选）

---

## 总结

**配置完成！** 🎉

**您现在拥有**：
- ✅ 一个随时可用的 QQ AI 助手
- ✅ 双向交互能力（私聊 + 群聊）
- ✅ 完全免费、合法、安全
- ✅ 无需企业认证

**后续优化**：
- 配置自动回复规则
- 添加关键词触发
- 集成更多 OpenClaw 技能
- 定期检查运行状态

---

## 需要帮助？

**资源链接**：
- NapCat GitHub：https://github.com/Mlikiowa/NapCat-qq
- OpenClaw 文档：https://docs.openclaw.ai/
- QQ 开放平台：https://qun.qq.com/

**常见问题**：
- 查看 NapCat 文档
- 查看 OpenClaw 日志
- 运行诊断：`openclaw doctor`

---

**配置状态**：✅ 完成
**下次维护**：建议每月检查一次更新

# QQ 机器人快速启动指南

**配置日期**：2026-02-08
**状态**：已配置完成，等待启动

---

## ✅ 已完成的配置

1. ✅ Go-CQHTTP 配置文件已创建：`~/gocqhttp/config.yml`
2. ✅ OpenClaw QQ 通道配置已创建：`~/.openclaw/channels/qq/config.json`
3. ✅ OpenClaw Gateway 已重启

---

## 🚀 现在只需 3 步即可完成

### 第1步：启动 Go-CQHTTP

**在终端中执行**：

```bash
cd ~/gocqhttp
./go-cqhttp
```

**会看到启动日志**：
```
Go-CQHTTP v1.2.0
[INFO] 正在加载配置...
[INFO] 配置加载完成
[INFO] 请使用手机 QQ 扫码登录
```

---

### 第2步：扫码登录 QQ

**在启动日志中会看到登录信息**：

```
请访问以下链接扫码登录:
https://login.q.qq.com/cgi-bin/login/qrcode/xxxxxxxx
```

**扫码步骤**：
1. 复制日志中的链接到浏览器
2. 使用手机 QQ 扫描浏览器中的二维码
3. 在手机上点击"确认登录"

**登录成功后日志显示**：
```
[INFO] 登录成功
[INFO] 欢迎使用 Go-CQHTTP
[INFO] WebSocket 服务已启动: ws://127.0.0.1:3001
[INFO] HTTP API 已启动: http://127.0.0.1:5700
```

---

### 第3步：测试双向交互

**在 QQ 中发送消息**：

```
你好
```

**应该收到 AI 回复**：

```
您好！我是 OpenClaw AI 助手，有什么可以帮您的吗？
```

**如果收到回复**，恭喜！配置成功！🎉

---

## 📋 后台运行（可选）

### 如果想关闭终端窗口但保持服务运行

**使用后台运行**：

```bash
cd ~/gocqhttp
nohup ./go-cqhttp > go-cqhttp.log 2>&1 &
```

**查看日志**：
```bash
tail -f ~/gocqhttp/go-cqhttp.log
```

**停止服务**：
```bash
pkill go-cqhttp
```

---

## 🧪 验证配置

### 检查 Go-CQHTTP 日志

```bash
tail -f ~/gocqhttp/go-cqhttp.log
```

**应该看到**：
- WebSocket 连接正常
- 收到消息的记录
- 发送消息的记录

### 检查 OpenClaw Gateway 日志

```bash
openclaw gateway logs --follow
```

**应该看到**：
```
[INFO] QQ connected successfully
[INFO] Received message from QQ: 你好
[INFO] Processing message...
[INFO] Reply sent successfully
```

---

## 🔧 常用命令

### 启动服务
```bash
cd ~/gocqhttp
./go-cqhttp
```

### 停止服务
```bash
pkill go-cqhttp
```

### 重启服务
```bash
pkill go-cqhttp
cd ~/gocqhttp
./go-cqhttp
```

### 查看日志
```bash
# Go-CQHTTP 日志
tail -f ~/gocqhttp/go-cqhttp.log

# OpenClaw Gateway 日志
openclaw gateway logs --follow
```

---

## ❓ 常见问题

### Q1: 启动时提示端口被占用

**原因**：3001 或 5700 端口已被占用

**解决**：
```bash
# 查看占用端口的进程
lsof -i :3001
lsof -i :5700

# 杀死占用端口的进程
pkill go-cqhttp

# 重新启动
./go-cqhttp
```

### Q2: 登录失败或二维码过期

**解决**：
1. 停止 go-cqhttp：`pkill go-cqhttp`
2. 删除登录缓存：`rm -rf data`
3. 重新启动：`./go-cqhttp`
4. 重新扫码登录

### Q3: 机器人不回复消息

**检查**：
1. Go-CQHTTP 是否运行：`ps aux | grep go-cqhttp`
2. OpenClaw Gateway 是否运行：`openclaw gateway status`
3. 查看日志排查问题

---

## 📊 配置文件位置

| 文件 | 位置 |
|------|------|
| Go-CQHTTP 配置 | `~/gocqhttp/config.yml` |
| OpenClaw QQ 配置 | `~/.openclaw/channels/qq/config.json` |
| Go-CQHTTP 日志 | `~/gocqhttp/go-cqhttp.log` |
| OpenClaw 日志 | `openclaw gateway logs --follow` |

---

## 🎉 完成后

**您将拥有**：
- ✅ 一个可用的 QQ AI 机器人
- ✅ 双向交互能力（私聊 + 群聊）
- ✅ 24/7 在线服务
- ✅ 完全免费、合法、安全

---

## 💡 提示

1. **首次运行**：需要扫码登录（只需一次）
2. **后续启动**：自动登录，无需再次扫码
3. **保持服务运行**：可以使用后台运行命令
4. **定期检查日志**：确保服务正常

---

**现在就开始第1步吧！在终端执行：**

```bash
cd ~/gocqhttp
./go-cqhttp
```

**执行后告诉我日志输出，我会协助您完成登录！** 🚀

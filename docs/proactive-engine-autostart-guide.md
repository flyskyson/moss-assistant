# 主动性引擎 - 自动启动配置指南

**日期**: 2026-02-09
**目标**: 让主动性引擎在系统启动时自动运行

---

## 🎯 什么是自动启动？

自动启动（Auto-Start）意味着：
- ✅ 系统启动后自动运行主动性引擎
- ✅ 引擎崩溃时自动重启
- ✅ 无需手动执行启动命令
- ✅ 7×24小时持续监控

---

## 🚀 快速开始

### 安装自动启动

```bash
cd ~/clawd
./scripts/proactive-engine-auto-install.sh install
```

**安装过程**：
```
╔════════════════════════════════════════════════════════════╗
║  主动性引擎自动启动安装                                     ║
║   Proactive Engine Auto-Start Installation                   ║
╚════════════════════════════════════════════════════════════╝

✅ 数据目录: /Users/lijian/clawd/proactive-data

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 安装 launchd 配置文件
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 已复制到: /Users/lijian/clawd/Library/LaunchAgents/com.clawd.proactive-engine.plist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 加载并启动服务
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ launchd agent 已加载

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 验证状态
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 主动性引擎自动启动已配置

╔════════════════════════════════════════════════════════════╗
║  🎉 主动性引擎现在会自动启动！                               ║
║  系统重启后会自动运行                                         ║
╚════════════════════════════════════════════════════════════╝
```

---

## 📋 管理命令

### 查看状态

```bash
./scripts/proactive-engine-auto-install.sh status
```

### 手动管理

```bash
# 停止服务
launchctl stop com.clawd.proactive-engine

# 启动服务
launchctl start com.clawd.proactive-engine

# 重启服务
launchctl unload ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
launchctl load ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
```

### 卸载自动启动

```bash
./scripts/proactive-engine-auto-install.sh uninstall
```

---

## 🔧 工作原理

### Launchd 机制

macOS 使用 **launchd** 系统来管理后台服务：

```
系统启动
    ↓
launchd 加载 ~/Library/LaunchAgents/*.plist
    ↓
根据配置启动服务
    ↓
KeepAlive: 如果进程崩溃，自动重启
```

### 配置文件

**位置**: `~/Library/LaunchAgents/com.clawd.proactive-engine.plist`

**关键配置**:
```xml
<key>Label</key>
<string>com.clawd.proactive-engine</string>

<key>ProgramArguments</key>
<array>
    <string>/Users/lijian/clawd/scripts/proactive-engine.py</string>
    <string>main</string>
    <string>daemon</string>
</array>

<key>RunAtLoad</key>
<true/>

<key>KeepAlive</key>
<dict>
    <key>Crashed</key>
    <true/>
</dict>
```

**说明**:
- `Label`: 唯一标识符
- `ProgramArguments`: 要执行的命令和参数
- `RunAtLoad`: 加载时立即运行
- `KeepAlive`: 进程崩溃时自动重启

---

## 📊 日志文件

### 日志位置

```
~/clawd/proactive-data/
├── launchd-stdout.log    # 标准输出日志
├── launchd-stderr.log    # 错误输出日志
└── proactive-engine.log  # 引擎运行日志
```

### 查看日志

```bash
# 查看引擎日志
tail -f ~/clawd/proactive-data/proactive-engine.log

# 查看错误日志
tail -f ~/clawd/proactive-data/launchd-stderr.log

# 查看最近50行
tail -50 ~/clawd/proactive-data/proactive-engine.log
```

---

## 🎯 使用场景

### 场景1: 日常使用

```
安装一次后:
├─ 系统启动 → 引擎自动运行
├─ 引擎崩溃 → 自动重启
└─ 持续监控 → 无需干预

你只需要:
├─ 定期查看报告
└─ 根据建议执行优化
```

### 场景2: 手动启动

如果你不想自动启动，可以：

```bash
# 停止自动启动
launchctl stop com.clawd.proactive-engine

# 手动启动
cd ~/clawd
./scripts/proactive-engine-control.sh main start
```

### 场景3: 临时禁用

```bash
# 卸载自动启动
./scripts/proactive-engine-auto-install.sh uninstall

# 需要时再安装
./scripts/proactive-engine-auto-install.sh install
```

---

## ⚠️ 故障排除

### 问题1: 服务未启动

**检查**:
```bash
launchctl list | grep proactive-engine
```

**解决**:
```bash
# 重新加载
launchctl unload ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
launchctl load ~/Library/LaunchAgents/com.clawd.proactive-engine.plist

# 启动服务
launchctl start com.clawd.proactive-engine
```

### 问题2: 启动失败

**检查日志**:
```bash
tail -50 ~/clawd/proactive-data/launchd-stderr.log
```

**常见原因**:
- Python3 未安装
- 脚本路径不正确
- 权限问题

### 问题3: 服务不断重启

**检查**:
```bash
# 查看日志中的错误
tail -50 ~/clawd/proactive-data/launchd-stderr.log

# 手动测试启动
cd ~/clawd
python3 scripts/proactive-engine.py main daemon
```

---

## 🔄 更新和维护

### 更新引擎代码

如果更新了 `proactive-engine.py`：

```bash
# 重启服务
launchctl stop com.clawd.proactive-engine
launchctl start com.clawd.proactive-engine

# 或者重新加载
launchctl unload ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
launchctl load ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
```

### 更新配置

如果更新了 `com.clawd.proactive-engine.plist`：

```bash
# 重新加载配置
launchctl unload ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
launchctl load ~/Library/LaunchAgents/com.clawd.proactive-engine.plist
```

---

## ✅ 验证清单

### 安装后验证

- [ ] `launchctl list | grep proactive-engine` 显示服务
- [ ] `~/clawd/proactive-data/proactive-engine.log` 有新内容
- [ ] `~/clawd/proactive-data/metrics.jsonl` 数据在增长
- [ ] 系统重启后服务自动运行

### 运行状态验证

```bash
# 1. 检查服务状态
launchctl list | grep proactive-engine

# 2. 查看日志
tail -20 ~/clawd/proactive-data/proactive-engine.log

# 3. 检查数据
ls -l ~/clawd/proactive-data/metrics.jsonl

# 4. 生成报告
cd ~/clawd
./scripts/proactive-engine-control.sh main report
```

---

## 🎯 核心价值

### 1. 自动化

```
手动启动 → 每次都要启动
自动启动 → 安装一次，永久运行
```

### 2. 可靠性

```
KeepAlive → 崩溃自动重启
持续监控 → 7×24小时运行
```

### 3. 透明性

```
完整日志 → 所有行为可追溯
标准接口 → 易于管理和调试
```

---

## 📚 相关文档

1. **[proactive-engine-complete.md](proactive-engine-complete.md)** - 完成报告
2. **[proactive-engine-user-guide.md](proactive-engine-user-guide.md)** - 用户指南
3. **[proactive-engine-architecture.md](proactive-engine-architecture.md)** - 架构设计

---

## 🚀 立即开始

```bash
# 安装自动启动
cd ~/clawd
./scripts/proactive-engine-auto-install.sh install

# 验证状态
./scripts/proactive-engine-auto-install.sh status

# 查看日志
tail -f ~/clawd/proactive-data/proactive-engine.log
```

---

**创建时间**: 2026-02-09
**状态**: ✅ 已完成并可用
**下一步**: 安装自动启动，享受7×24小时监控

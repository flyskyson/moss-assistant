# LaunchAgent 详解

**目标**: 理解 macOS 的 LaunchAgent 机制，用于自动执行脚本

---

## 🎯 什么是 LaunchAgent？

### 简单解释

**LaunchAgent** = macOS 的"定时任务管理器"

**作用**:
- 🕐 在指定时间自动运行脚本
- 🔄 开机自动启动服务
- 💤 进程崩溃后自动重启
- 📊 记录日志输出

**类比**:
- Linux 的 `cron`
- Windows 的"任务计划程序"
- 但更强大、更可靠

---

## 📚 macOS 的两种 Launch 机制

### LaunchAgent vs LaunchDaemon

| 特性 | LaunchAgent | LaunchDaemon |
|------|-------------|--------------|
| **运行身份** | 当前用户 | 系统级（root） |
| **需要登录** | ✅ 需要 | ❌ 不需要 |
| **GUI 访问** | ✅ 可以访问 | ❌ 不可以 |
| **权限要求** | 🟢 低（用户级） | 🔴 高（系统级） |
| **配置位置** | `~/Library/LaunchAgents/` | `/Library/LaunchDaemons/` |
| **适合用途** | 用户脚本、应用 | 系统服务、后台任务 |

**我们使用 LaunchAgent** ✅:
- 用户级脚本
- 不需要管理员权限
- 更安全、更简单

---

## 🔧 LaunchAgent 配置文件

### 文件格式：.plist（Property List）

**位置**: `~/Library/LaunchAgents/com.你的名字.任务名.plist`

**示例**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 任务名称 -->
    <key>Label</key>
    <string>com.example.weekly-task</string>

    <!-- 要执行的程序或脚本 -->
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/用户名/clawd/scripts/weekly-check.sh</string>
    </array>

    <!-- 定时执行 -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>5</integer>          <!-- 周五 -->
        <key>Hour</key>
        <integer>20</integer>          <!-- 20:00 -->
        <key>Minute</key>
        <integer>0</integer>           <!-- 0 分 -->
    </dict>

    <!-- 日志输出 -->
    <key>StandardOutPath</key>
    <string>/tmp/weekly-check.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/weekly-check.err</string>
</dict>
</plist>
```

---

## 🔑 关键配置参数详解

### 1. Label（任务名称）
```xml
<key>Label</key>
<string>com.你的名字.任务名</string>
```
- **作用**: 唯一标识这个任务
- **命名规范**: 反域名格式（倒序域名）
- **示例**: `com.openclaw.weekly-check`

### 2. ProgramArguments（要执行的命令）
```xml
<key>ProgramArguments</key>
<array>
    <string>/bin/bash</string>
    <string>/path/to/script.sh</string>
</array>
```
- **作用**: 定义要执行的程序和参数
- **格式**: 数组，第一个是程序，后面是参数
- **示例**:
  ```xml
  <!-- 直接执行脚本 -->
  <string>/Users/lijian/clawd/scripts/check.sh</string>

  <!-- 带参数的执行 -->
  <string>/bin/bash</string>
  <string>-c</string>
  <string>echo "Hello"</string>
  ```

### 3. RunAtLoad（加载时立即执行）
```xml
<key>RunAtLoad</key>
<true/>
```
- **作用**: LaunchAgent 加载后立即执行一次
- **用途**: 开机自动启动服务
- **示例**: Ollama、Gateway 的自动启动

### 4. KeepAlive（保持运行）
```xml
<key>KeepAlive</key>
<true/>
```
- **作用**: 进程崩溃后自动重启
- **用途**: 确保服务始终运行
- **示例**: Ollama 服务

### 5. StartCalendarInterval（定时执行）
```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>5</integer>      <!-- 周五 (0=周日, 1=周一, ..., 7=周日) -->
    <key>Hour</key>
    <integer>20</integer>      <!-- 20:00 -->
    <key>Minute</key>
    <integer>0</integer>       <!-- 0 分 -->
</dict>
```
- **作用**: 定时执行（类似 cron）
- **可选字段**:
  - `Weekday`: 星期几（0-7）
  - `Hour`: 小时（0-23）
  - `Minute`: 分钟（0-59）
  - `Day`: 天（1-31）
  - `Month`: 月（1-12）

### 6. StandardOutPath / StandardErrorPath（日志）
```xml
<key>StandardOutPath</key>
<string>/tmp/script.log</string>

<key>StandardErrorPath</key>
<string>/tmp/script.err</string>
```
- **作用**: 记录脚本输出和错误
- **用途**: 调试、问题诊断

---

## 📝 实际示例：我们已经创建的

### 示例 1: Ollama 自动启动

**文件**: `~/Library/LaunchAgents/com.ollama.server.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.server</string>

    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/ollama</string>
        <string>serve</string>
    </array>

    <key>RunAtLoad</key>
    <true/>        <!-- ✅ 开机自动启动 -->

    <key>KeepAlive</key>
    <true/>        <!-- ✅ 崩溃后自动重启 -->

    <key>StandardOutPath</key>
    <string>/tmp/ollama.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/ollama.err</string>
</dict>
</plist>
```

**效果**:
- ✅ 开机自动启动 Ollama
- ✅ 崩溃后自动重启
- ✅ 日志记录到 `/tmp/ollama.log`

---

### 示例 2: 每周知识库检查（待创建）

**文件**: `~/Library/LaunchAgents/com.openclaw.weekly.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.weekly</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/lijian/clawd/scripts/weekly-knowledge-check.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>5</integer>      <!-- 周五 -->
        <key>Hour</key>
        <integer>20</integer>      <!-- 20:00 -->
        <key>Minute</key>
        <integer>0</integer>       <!-- 0 分 -->
    </dict>

    <key>StandardOutPath</key>
    <string>/tmp/weekly-check.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/weekly-check.err</string>
</dict>
</plist>
```

**效果**:
- ✅ 每周五晚上 20:00 自动执行
- ✅ 运行知识库检查脚本
- ✅ 日志记录到 `/tmp/weekly-check.log`

---

## 🛠️ 管理命令

### 加载任务
```bash
launchctl load ~/Library/LaunchAgents/com.ollama.server.plist
```
**作用**: 加载 .plist 文件，启动任务

### 卸载任务
```bash
launchctl unload ~/Library/LaunchAgents/com.ollama.server.plist
```
**作用**: 停止任务，卸载配置

### 列出所有任务
```bash
launchctl list
```
**输出示例**:
```
PID     Status  Label
11827   0       com.ollama.server
12579   0       ai.openclaw.gateway
...
```

### 查看任务状态
```bash
launchctl list | grep ollama
```
**输出**:
```
11827   0       com.ollama.server
```
- `11827`: PID（进程 ID）
- `0`: 状态码（0 = 正常）

### 手动触发任务
```bash
launchctl start com.ollama.server
```
**作用**: 立即执行任务（不等待定时）

### 停止任务
```bash
launchctl stop com.ollama.server
```
**作用**: 停止正在运行的任务

---

## 📊 对比：LaunchAgent vs OpenClaw Cron

### 场景：每周知识库检查

| 维度 | LaunchAgent | OpenClaw Cron |
|------|-------------|--------------|
| **可靠性** | 🔴 高 - 系统级服务 | 🟡 中 - 依赖 Gateway |
| **精确性** | 🔴 高 - 精确到秒 | 🟡 中 - 可能延迟 |
| **日志** | 🔴 高 - 自动记录 | 🟡 中 - 需手动配置 |
| **成本** | 🟢 低 - 免费 | 🟡 中 - API 费用 |
| **智能化** | 🟢 低 - 脚本逻辑 | 🔴 高 - MOSS AI |
| **配置复杂度** | 🟡 中 - 写 .plist | 🟢 低 - JSON 配置 |
| **调试难度** | 🟡 中 - 查看日志 | 🔴 高 - 需检查 MOSS |

---

## 🎯 实战演示

### 创建一个简单的 LaunchAgent 任务

**步骤 1: 创建测试脚本**

```bash
# 创建脚本
cat > ~/clawd/scripts/hello-world.sh << 'EOF'
#!/bin/bash
echo "================================"
echo "  Hello from LaunchAgent!"
echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================"
EOF

# 添加执行权限
chmod +x ~/clawd/scripts/hello-world.sh
```

**步骤 2: 创建 .plist 文件**

```bash
cat > ~/Library/LaunchAgents/com.test.hello.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.test.hello</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/lijian/clawd/scripts/hello-world.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Minute</key>
        <integer>*/1</integer>      <!-- 每 1 分钟执行一次 -->
    </dict>

    <key>StandardOutPath</key>
    <string>/tmp/hello.log</string>
</dict>
</plist>
EOF
```

**步骤 3: 加载并运行**

```bash
# 加载任务
launchctl load ~/Library/LaunchAgents/com.test.hello.plist

# 等待 1 分钟
sleep 60

# 查看输出
cat /tmp/hello.log
```

**输出**:
```
================================
  Hello from LaunchAgent!
  时间: 2026-02-06 21:10:00
================================
```

**步骤 4: 清理**

```bash
# 卸载任务
launchctl unload ~/Library/LaunchAgents/com.test.hello.plist

# 删除文件
rm ~/Library/LaunchAgents/com.test.hello.plist
rm /tmp/hello.log
```

---

## 💡 最佳实践

### 1. 脚本必须健壮

**❌ 不好**:
```bash
#!/bin/bash
cd ~/clawd
./scripts/check.sh
```

**✅ 好**:
```bash
#!/bin/bash
set -euo pipefail  # 遇到错误立即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1

./scripts/check.sh || echo "检查失败" >&2
```

### 2. 日志必须记录

**✅ 总是设置日志路径**:
```xml
<key>StandardOutPath</key>
<string>/tmp/my-script.log</string>

<key>StandardErrorPath</key>
<string>/tmp/my-script.err</string>
```

### 3. 环境变量必须明确

**❌ 不好**:
```bash
#!/bin/bash
node server.js  # 可能找不到 node
```

**✅ 好**:
```bash
#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
/opt/homebrew/bin/node server.js
```

### 4. 测试后再加载

**✅ 先手动测试**:
```bash
./scripts/weekly-check.sh
```

**✅ 确认无误后再加载**:
```bash
launchctl load ~/Library/LaunchAgents/com.openclaw.weekly.plist
```

---

## 🔍 调试技巧

### 查看任务是否加载
```bash
launchctl list | grep openclaw
```

### 查看日志
```bash
# 标准输出
cat /tmp/weekly-check.log

# 错误输出
cat /tmp/weekly-check.err
```

### 手动触发测试
```bash
# 启动任务
launchctl start com.openclaw.weekly

# 立即查看日志
tail -f /tmp/weekly-check.log
```

### 查看系统日志
```bash
log show --predicate 'process == "launchd"' | grep openclaw
```

---

## 🎯 总结

### LaunchAgent 的优势

✅ **可靠**: 系统级服务，不依赖第三方
✅ **精确**: 精确到秒的定时执行
✅ **免费**: 无 API 费用
✅ **日志**: 自动记录输出
✅ **自动重启**: KeepAlive 机制

### LaunchAgent 的局限

❌ **不智能**: 纯脚本逻辑，没有 AI
❌ **配置复杂**: 需要写 .plist 文件
❌ **调试困难**: 需要查看日志

### 适用场景

✅ **适合**:
- 系统检查（状态、统计）
- 定时任务（备份、清理）
- 服务保持运行（Ollama、Gateway）

❌ **不适合**:
- 需要智能分析的任务
- 需要理解和推理的任务
- 需要生成建议的任务

---

## 🤔 下一步

**你想**:
1. 创建一个测试 LaunchAgent（体验一下）？
2. 直接创建周检任务的 LaunchAgent？
3. 还是先看看 OpenClaw Cron 的配置？

**告诉我你的选择，我来帮你实施！** 😊

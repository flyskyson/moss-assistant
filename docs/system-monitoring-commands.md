# 🔍 系统监控查询命令大全

**学习如何查询系统状态、配置和进程信息**

---

## 📊 1. 查看模型配置 (Reasoning 状态)

### 方法 1: 用 Python 解析 JSON (推荐)

```bash
python3 << 'EOF'
import json

# 读取配置文件
with open('/Users/lijian/.openclaw/openclaw.json', 'r') as f:
    config = json.load(f)

# 查看特定模型的配置
deepseek_model = config['models']['providers']['deepseek']['models'][0]
print(f"Reasoning: {deepseek_model.get('reasoning', False)}")
print(f"上下文: {deepseek_model['contextWindow']}")
print(f"模型名称: {deepseek_model['name']}")
EOF
```

**输出示例**:
```
Reasoning: True
上下文: 64000
模型名称: DeepSeek Chat (Official)
```

---

### 方法 2: 用 grep 快速查找

```bash
# 查找 DeepSeek 配置
grep -A 10 '"deepseek"' ~/.openclaw/openclaw.json | grep "reasoning"

# 查找所有 reasoning 配置
grep -i "reasoning" ~/.openclaw/openclaw.json
```

**输出示例**:
```
"reasoning": true,
```

---

### 方法 3: 用 jq (JSON 查询工具)

```bash
# 安装 jq (如果没有)
brew install jq

# 查询 DeepSeek 的 reasoning 配置
jq '.models.providers.deepseek.models[0].reasoning' ~/.openclaw/openclaw.json

# 格式化输出整个配置
jq '.models.providers.deepseek' ~/.openclaw/openclaw.json
```

---

## ⏱️ 2. 查看进程运行时长

### 方法 1: ps 命令 (推荐)

```bash
# 查看特定进程的运行时长
ps -p 11651 -o etime=

# 查看进程的详细信息
ps -p 11651 -o pid,etime,command

# 查看所有 openclaw 相关进程
ps aux | grep openclaw
```

**输出示例**:
```
   09:19     # 运行时长: 9分19秒
```

**etime 格式说明**:
- `09:19` = 9分19秒
- `1-02:30:45` = 1天2小时30分45秒
- `MM:SS` = 分:秒
- `HH:MM:SS` = 时:分:秒
- `D-HH:MM:SS` = 天-时:分:秒

---

### 方法 2: ps 人性化输出

```bash
# 查看进程的多种时间信息
ps -p 11651 -o pid,etime,%cpu,%mem,stat,command

# 输出:
#   PID     ELAPSED %CPU %MEM STAT COMMAND
#  11651       09:19  0.0  0.5 S    openclaw-gateway
```

**字段说明**:
- `PID`: 进程 ID
- `ELAPSED`: 运行时长
- `%CPU`: CPU 使用率
- `%MEM`: 内存使用率
- `STAT`: 进程状态 (S=睡眠, R=运行, Z=僵尸)

---

### 方法 3: 查看 Gateway 启动历史

```bash
# 查看 Gateway 日志中的启动记录
grep "listening on ws://127.0.0.1:18789" ~/.openclaw/logs/gateway.log | tail -5

# 输出:
# 2026-02-09T03:22:09.049Z [gateway] listening on ws://127.0.0.1:18789 (PID 50540)
# 2026-02-09T03:29:14.295Z [gateway] listening on ws://127.0.0.1:18789 (PID 52156)
# 2026-02-09T03:31:03.438Z [gateway] listening on ws://127.0.0.1:18789 (PID 52366)
# 2026-02-09T05:20:55.435Z [gateway] listening on ws://127.0.0.1:18789 (PID 11651)
```

---

## 🔍 3. 查看进程详细信息

### 查看进程所有信息

```bash
# 查看特定进程的完整信息
ps -p 11651 -o pid,ppid,user,%cpu,%mem,vsz,rss,etime,stat,start,time,command

# 字段说明:
# PID    - 进程 ID
# PPID   - 父进程 ID
# USER   - 运行用户
# %CPU   - CPU 使用率
# %MEM   - 内存使用率
# VSZ    - 虚拟内存大小 (KB)
# RSS    - 常驻内存大小 (KB)
# ELAPSED - 运行时长
# STAT   - 进程状态
# START  - 启动时间
# TIME   - 累计 CPU 时间
# COMMAND - 命令行
```

---

### 查看进程打开的文件

```bash
# 查看进程打开的文件和网络连接
lsof -p 11651 | head -20

# 查看进程监听的端口
lsof -p 11651 | grep LISTEN

# 查看特定端口被哪个进程占用
lsof -i :18789
```

---

## 📁 4. 查看配置文件

### 查看 OpenClaw 配置

```bash
# 查看完整配置
cat ~/.openclaw/openclaw.json

# 格式化输出 JSON
python3 -m json.tool ~/.openclaw/openclaw.json

# 用 jq 查询
jq '.' ~/.openclaw/openclaw.json

# 查看特定部分
jq '.agents.defaults.model' ~/.openclaw/openclaw.json
```

---

### 查看特定配置项

```bash
# 查看默认模型
jq '.agents.defaults.model.primary' ~/.openclaw/openclaw.json

# 查看所有提供商
jq '.models.providers | keys' ~/.openclaw/openclaw.json

# 查看某个提供商的所有模型
jq '.models.providers.deepseek.models[] | .id' ~/.openclaw/openclaw.json
```

---

## 📊 5. 实时监控命令

### 实时查看进程

```bash
# 持续监控进程 (每 2 秒刷新)
watch -n 2 'ps -p 11651 -o pid,etime,%cpu,%mem,command'

# 实时查看所有 openclaw 进程
watch -n 2 'ps aux | grep openclaw | grep -v grep'
```

---

### 实时查看日志

```bash
# 查看最新的 Gateway 日志
tail -f ~/.openclaw/logs/gateway.log

# 查看 Agent 日志
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 查看最近的错误
tail -f ~/.openclaw/logs/gateway.log | grep -i error

# 查看特定关键词
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep "provider="
```

---

## 🎯 6. 实用组合命令

### 查看 Gateway 完整状态

```bash
echo "=== Gateway 进程信息 ===" && \
ps -p $(pgrep openclaw-gateway) -o pid,etime,%cpu,%mem,command && \
echo "" && \
echo "=== Gateway 配置 ===" && \
jq '.agents.defaults.model.primary' ~/.openclaw/openclaw.json && \
echo "" && \
echo "=== 最新日志 ===" && \
tail -3 ~/.openclaw/logs/gateway.log
```

---

## 📚 7. 常用工具速查

| 命令 | 用途 | 示例 |
|------|------|------|
| `ps` | 查看进程 | `ps -p 11651 -o etime` |
| `pgrep` | 查找进程 PID | `pgrep openclaw-gateway` |
| `lsof` | 查看打开的文件 | `lsof -i :18789` |
| `jq` | JSON 查询 | `jq ".agents.defaults.model" config.json` |
| `grep` | 搜索文本 | `grep "reasoning" file.json` |
| `tail` | 查看文件末尾 | `tail -f logfile.log` |
| `watch` | 定期执行命令 | `watch -n 2 ps aux` |

---

## 💡 8. 我刚才使用的具体命令

### 查看配置

```bash
python3 << 'EOF'
import json

with open('/Users/lijian/.openclaw/openclaw.json', 'r') as f:
    config = json.load(f)

deepseek_model = config['models']['providers']['deepseek']['models'][0]

print("Reasoning:", deepseek_model.get('reasoning', False))
print("✅ 配置已是: Agent 模式" if deepseek_model.get('reasoning') else "❌ Chat 模式")
EOF
```

### 查看进程时长

```bash
# 方法 1: 直接用 ps
ps -p 11651 -o etime=

# 方法 2: 用 Python 调用 ps
python3 << 'EOF'
import subprocess
result = subprocess.run(['ps', '-p', '11651', '-o', 'etime='],
                      capture_output=True, text=True)
if result.returncode == 0:
    print(f"运行时长: {result.stdout.strip()}")
EOF
```

---

## 🎓 9. 学习路径

**初级**:
1. 学习 `ps` 命令查看进程
2. 学习 `cat` 查看配置文件
3. 学习 `grep` 搜索内容

**中级**:
1. 学习 `jq` 处理 JSON
2. 学习管道 `|` 组合命令
3. 学习重定向 `>` 保存输出

**高级**:
1. 用 Python 解析复杂配置
2. 编写 shell 脚本自动化
3. 创建自定义命令别名

---

## 🚀 10. 现在就试试！

复制这些命令到终端试试看：

```bash
# 1. 查看 Gateway 运行时长
ps -p $(pgrep openclaw-gateway) -o pid,etime

# 2. 查看 Reasoning 配置
python3 -c "import json; f=open('/Users/lijian/.openclaw/openclaw.json'); c=json.load(f); print(c['models']['providers']['deepseek']['models'][0]['reasoning'])"

# 3. 查看最新日志
tail -5 ~/.openclaw/logs/gateway.log

# 4. 查看 Session 数量
ls -1 ~/.openclaw/agents/main/sessions/ | wc -l
```

---

**文档版本**: v1.0
**最后更新**: 2026-02-09

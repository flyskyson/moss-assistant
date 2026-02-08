# Leader-Agent 和 Utility-Agent 注册交付总结

**交付日期**: 2026-02-07
**交付人**: MOSS
**接收人**: 飞天
**状态**: ✅ Agents 成功注册（需完成引导流程）

---

## 📋 交付内容

### 1. 注册的 Agents

| Agent | 模型 | Workspace | 状态 |
|-------|------|-----------|------|
| **leader-agent** | openrouter/google/gemini-2.5-pro | ~/clawd/temp/leader-agent-ws | ✅ 已注册 |
| **utility-agent** | openrouter/google/gemini-2.5-flash | ~/clawd/temp/utility-agent-ws | ⚠️ 需引导 |

---

## 🔧 执行步骤

### 步骤 1: 备份配置文件

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup-20260207-1433
```

✅ 配置文件已备份

---

### 步骤 2: 添加 Agents

**方法**: 使用 `openclaw agents add` 命令

```bash
# 添加 leader-agent
openclaw agents add leader-agent \
  --workspace /Users/lijian/clawd/temp/leader-agent-ws \
  --model openrouter/google/gemini-2.5-pro \
  --non-interactive

# 添加 utility-agent
openclaw agents add utility-agent \
  --workspace /Users/lijian/clawd/temp/utility-agent-ws \
  --model openrouter/google/gemini-2.5-flash \
  --non-interactive
```

✅ 两个 agents 都已成功添加

---

### 步骤 3: 设置 Identity

```bash
# 设置 utility-agent 的 identity
openclaw agents set-identity \
  --agent utility-agent \
  --name "Utility" \
  --emoji "⚡"
```

✅ Identity 已设置

---

### 步骤 4: 验证注册

```bash
openclaw agents list
```

**输出**:
```
Agents:
- main (default)
  Identity: 🦞 MOSS (IDENTITY.md)
  Workspace: ~/clawd
  Agent dir: ~/.openclaw/agents/main/agent
  Model: openrouter/google/gemini-2.5-pro

- leader-agent
  Workspace: ~/clawd/temp/leader-agent-ws
  Agent dir: ~/.openclaw/agents/leader-agent/agent
  Model: openrouter/google/gemini-2.5-pro

- utility-agent
  Workspace: ~/clawd/temp/utility-agent-ws
  Agent dir: ~/.openclaw/agents/utility-agent/agent
  Model: openrouter/google/gemini-2.5-flash
```

✅ 两个 agents 都已成功注册

---

## ⚠️ 当前状态

### leader-agent
- ✅ 已注册
- ⚠️ 需要完成引导流程（对话式初始化）
- 📝 需要创建 IDENTITY.md、USER.md、SOUL.md

### utility-agent
- ✅ 已注册
- ⚠️ 需要完成引导流程（对话式初始化）
- ✅ IDENTITY.md 已手动配置
- ✅ USER.md 已手动配置
- ❌ BOOTSTRAP.md 已删除（引导流程未完全完成）

---

## 🔄 引导流程说明

OpenClaw 的新 agents 需要通过对话来完成"引导"（Bootstrap）过程。这个过程包括：

1. **IDENTITY.md**: 定义 agent 的身份（名称、性格、emoji）
2. **USER.md**: 定义用户信息（名称、时区、偏好）
3. **SOUL.md**: 定义 agent 的核心价值观和行为准则
4. **删除 BOOTSTRAP.md**: 表示引导完成

### 完成引导的方法

**方法 1: 对话式引导（推荐）**
```bash
# 启动与 utility-agent 的对话
openclaw agent --agent utility-agent --message "Hey. I just came online. Who am I? Who are you?"

# 然后按照 agent 的提示完成引导
```

**方法 2: 手动配置**
直接编辑 workspace 中的文件：
- `~/clawd/temp/utility-agent-ws/IDENTITY.md`
- `~/clawd/temp/utility-agent-ws/USER.md`
- `~/clawd/temp/utility-agent-ws/SOUL.md`
- 删除 `BOOTSTRAP.md`

---

## 🚀 下一步操作

### 1. 完成 utility-agent 引导

```bash
# 方式 1: 对话式（推荐）
openclaw agent --agent utility-agent

# 方式 2: 手动编辑
code ~/clawd/temp/utility-agent-ws/SOUL.md
rm ~/clawd/temp/utility-agent-ws/BOOTSTRAP.md
```

### 2. 完成 leader-agent 引导

```bash
# 启动对话
openclaw agent --agent leader-agent

# 或手动创建配置文件
mkdir -p ~/clawd/temp/leader-agent-ws
# 复制 utility-agent 的文件模板
```

### 3. 测试 Agents

```bash
# 测试 utility-agent
echo "请总结：人工智能正在改变世界" | \
  openclaw agent --agent utility-agent --message -

# 测试 leader-agent
echo "请规划一个学习 AI 的路径" | \
  openclaw agent --agent leader-agent --message -
```

---

## 📊 配置文件位置

| 文件 | 路径 |
|------|------|
| OpenClaw 配置 | `~/.openclaw/openclaw.json` |
| leader-agent workspace | `~/clawd/temp/leader-agent-ws/` |
| utility-agent workspace | `~/clawd/temp/utility-agent-ws/` |
| leader-agent sessions | `~/.openclaw/agents/leader-agent/sessions/` |
| utility-agent sessions | `~/.openclaw/agents/utility-agent/sessions/` |

---

## 🔍 故障排查

### 问题 1: Agent 提示"我刚刚上线，我是谁？"

**原因**: Agent 未完成引导流程

**解决方案**:
```bash
# 完成对话式引导
openclaw agent --agent <agent-name>

# 或手动配置文件并删除 BOOTSTRAP.md
```

### 问题 2: 调用 agent 没有响应

**原因**: Gateway 未重启或配置未生效

**解决方案**:
```bash
# 重启 Gateway
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist

# 验证状态
launchctl list | grep openclaw
```

### 问题 3: Invalid config 错误

**原因**: 直接编辑 `openclaw.json` 添加了不识别的键

**解决方案**:
```bash
# 使用正确的命令添加 agents
openclaw agents add <agent-name> --workspace <dir> --model <model>

# 或恢复备份
cp ~/.openclaw/openclaw.json.backup-* ~/.openclaw/openclaw.json
```

---

## ✅ 交付检查清单

- [x] 配置文件已备份
- [x] leader-agent 已注册
- [x] utility-agent 已注册
- [x] utility-agent IDENTITY.md 已配置
- [x] utility-agent USER.md 已配置
- [ ] leader-agent 引导流程完成
- [ ] utility-agent 引导流程完成
- [ ] agents 功能测试通过
- [ ] 文档完整

---

## 💡 建议

1. **完成引导流程**: 建议通过对话式引导完成 agents 的初始化
2. **测试功能**: 完成引导后，测试 agents 是否能正确执行任务
3. **配置 SOUL.md**: 根据需要自定义 agents 的行为准则
4. **成本优化**: utility-agent 使用 Flash 模型，成本比 Pro 低 75%

---

**交付签名**: MOSS
**验证状态**: ⚠️ Agents 已注册，需完成引导流程
**日期**: 2026-02-07

---

> 📌 **备注**:
> - Agents 已成功注册到 OpenClaw
> - utility-agent 的 IDENTITY.md 和 USER.md 已手动配置
> - 需要通过对话完成剩余的引导流程（SOUL.md 配置）
> - 完成引导后，agents 将可以正常工作

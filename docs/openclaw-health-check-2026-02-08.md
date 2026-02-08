# OpenClaw 健康检查报告

**检查日期**: 2026-02-08
**检查人**: MOSS
**状态**: ⚠️ 发现配置问题

---

## 📊 检查结果总览

| 检查项 | 状态 | 说明 |
|--------|------|------|
| **OpenClaw 版本** | ✅ 正常 | 2026.2.6-3（最新） |
| **Gateway 状态** | ✅ 正常 | 运行中，端口 18789 |
| **配置文件** | ⚠️ 需要修复 | agents 模型配置不完整 |
| **Agents 响应** | ✅ 正常 | 所有 agents 能正常响应 |
| **响应速度** | ⚠️ 变慢 | main 响应变慢（12.4 秒） |

---

## 🔍 详细检查结果

### 1. OpenClaw 版本 ✅

**当前版本**: 2026.2.6-3
**发布日期**: 2026-02-07
**状态**: ✅ 最新版本

**升级历史**:
- 2026.2.3-1 → 2026.2.6-3（2026-02-08 升级）

---

### 2. Gateway 状态 ✅

**运行状态**: ✅ 正常
**端口**: 18789
**绑定**: 127.0.0.1 (loopback)
**PID**: 23245

**警告**:
- ⚠️ Gateway service PATH 缺少必需目录: /opt/homebrew/bin, /usr/local/bin
- ⚠️ 检测到多个 gateway 服务（建议只运行一个）

---

### 3. Agents 配置 ⚠️ **需要修复**

#### 当前配置

| Agent | 配置的模型 | 实际使用的模型 | 状态 |
|-------|-----------|---------------|------|
| **main** | 默认 | Gemini 2.5 Flash | ✅ 正常 |
| **leader-agent-v2** | 默认 | Gemini 2.5 Flash | ❌ **应该是 MiniMax M2.1** |
| **utility-agent-v2** | 默认 | Gemini 2.5 Flash | ✅ 正常 |

#### 问题说明

**问题**: `leader-agent-v2` 没有指定专用模型，使用了默认的 Gemini 2.5 Flash

**应该的配置**（根据优化方案）:
- `leader-agent-v2` 应该使用 `openrouter/minimax/minimax-m2.1`

**原因**:
1. 之前将 `defaults.model.primary` 改为 `openrouter/google/gemini-2.5-flash`
2. `leader-agent-v2` 没有明确指定 `model` 字段
3. 导致它继承了默认模型

**影响**:
- ✅ 所有 agents 都能正常工作
- ⚠️ 失去了"三级模型架构"的优势
- ⚠️ `leader-agent-v2` 失去了 MiniMax 的 agent 优化能力

---

### 4. Agents 响应测试 ✅

#### 响应时间

| Agent | 当前响应时间 | 之前响应时间 | 变化 |
|-------|-------------|-------------|------|
| **main** | 12.373 秒 | 7.812 秒 | ⚠️ **慢 58%** |
| **leader-agent-v2** | 9.850 秒 | 10.236 秒 | ✅ 快 4% |
| **utility-agent-v2** | 7.121 秒 | 7.864 秒 | ✅ 快 9% |

#### 说明

**main 响应变慢的原因**:
- 可能是网络波动
- 可能是 API 负载变化
- 可能是测试任务不同

**建议**: 重新测试 main 响应时间

---

## 🔧 修复建议

### 方案 A: 恢复 leader-agent-v2 的 MiniMax M2.1 配置（推荐）⭐⭐⭐⭐⭐

**操作**:

1. 编辑 `~/.openclaw/openclaw.json`，为 `leader-agent-v2` 添加模型配置：

```json
{
  "id": "leader-agent-v2",
  "model": "openrouter/minimax/minimax-m2.1"
}
```

2. 重启 Gateway：

```bash
openclaw gateway restart
```

**好处**:
- ✅ 恢复三级模型架构
- ✅ `leader-agent-v2` 使用专为 agents 优化的模型
- ✅ 保持性能优势（72.5% SWE-bench）

**配置后的架构**:
```
main (Gemini 2.5 Flash) → 7-8 秒，全能助手
leader-agent-v2 (MiniMax M2.1) → 10 秒，任务规划
utility-agent-v2 (Gemini Flash) → 7 秒，简单任务
```

---

### 方案 B: 全部使用 Gemini 2.5 Flash（不推荐）⭐⭐

**操作**: 无需操作，保持现状

**好处**:
- ✅ 所有 agents 速度一致（~8 秒）
- ✅ 配置简单

**代价**:
- ❌ 失去 MiniMax 的 agent 优化
- ❌ 失去三级架构的优势

---

### 方案 C: 为 leader-agent-v2 创建专门配置（高级）⭐⭐⭐⭐

**操作**:

1. 为 `leader-agent-v2` 添加完整配置：

```json
{
  "id": "leader-agent-v2",
  "model": "openrouter/minimax/minimax-m2.1",
  "description": "任务规划和协调专家，使用 MiniMax M2.1",
  "workspace": "~/.openclaw/workspace-leader-agent-v2"
}
```

2. 重启 Gateway

**好处**:
- ✅ 明确的职责定义
- ✅ 专门的模型优化
- ✅ 更好的可维护性

---

## 📋 其他发现

### Gateway PATH 警告

**警告**: Gateway service PATH 缺少必需目录

**影响**: 可能导致某些命令无法找到

**修复**:

```bash
openclaw doctor --repair
```

### 多个 Gateway 服务

**发现**: 检测到多个 gateway 服务：
- `ai.openclaw.gateway`
- `com.openclaw.daily-health`
- `com.openclaw.weekly`

**建议**: 只保留一个主 gateway，其他可以停止

---

## ✅ 推荐操作

### 立即执行

1. **修复 leader-agent-v2 配置** ⚠️ **高优先级**
   ```bash
   # 编辑配置
   vim ~/.openclaw/openclaw.json

   # 在 agents.list 中为 leader-agent-v2 添加：
   # "model": "openrouter/minimax/minimax-m2.1"

   # 重启 Gateway
   openclaw gateway restart
   ```

2. **修复 Gateway PATH**
   ```bash
   openclaw doctor --repair
   ```

### 可选执行

3. **重新测试 main 响应速度**
   ```bash
   time (echo "2+2=?" | openclaw agent --agent main --message -)
   ```

4. **停止不需要的 gateway 服务**
   ```bash
   launchctl bootout gui/$UID/com.openclaw.daily-health
   launchctl bootout gui/$UID/com.openclaw.weekly
   ```

---

## 🎯 总结

### 核心问题

⚠️ **leader-agent-v2 的模型配置丢失**，使用了默认的 Gemini 2.5 Flash，而不是专为 agents 优化的 MiniMax M2.1

### 建议方案

**推荐**: 方案 A - 恢复 leader-agent-v2 的 MiniMax M2.1 配置

**理由**:
1. 恢复三级模型架构
2. 保持 agent 优化优势
3. 只需简单配置修改

### 预期效果

**修复后**:
- main: Gemini 2.5 Flash（7-8 秒）
- leader-agent-v2: MiniMax M2.1（~10 秒）✅ 恢复
- utility-agent-v2: Gemini Flash（~7 秒）

**月成本**: $7.17
**架构**: 三级清晰，各司其职

---

**检查完成签名**: MOSS
**检查日期**: 2026-02-08
**优先级**: ⚠️ 高（建议立即修复）

---

> 🎯 **关键发现**:
>
> **问题**: leader-agent-v2 失去了 MiniMax M2.1 的 agent 优化配置
> **原因**: 配置文件中没有明确指定模型，继承了默认值
> **影响**: 失去三级架构优势，性能可能下降
> **解决**: 为 leader-agent-v2 添加 `model: "openrouter/minimax/minimax-m2.1"`
>
> **建议**: 立即修复以恢复最优配置

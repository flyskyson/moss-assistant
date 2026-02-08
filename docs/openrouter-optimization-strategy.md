# OpenRouter 优化配置策略

**文档版本**: v1.0
**创建日期**: 2026-02-07
**基于文档**: [OPENROUTER-RESEARCH-2026.md](./OPENROUTER-RESEARCH-2026.md)

---

## 🎯 核心问题诊断

### 当前状态
- ❌ **OpenRouter 积分不足**: 所有 agents 不可用
- ❌ **成本过高**: 使用 Gemini 2.5 Pro/Flash，月成本 $22.50+
- ❌ **未使用优化策略**: 无 Auto Router，无 Prompt Caching

### 根本原因
```
高成本模型 + 无优化 = 积分快速消耗
```

---

## 📊 成本对比分析

### 当前配置成本

| Agent | 模型 | 输入 | 输出 | 月成本（50次/天） |
|-------|------|------|------|-------------------|
| main | Gemini 2.5 Pro | $2.50 | $10 | ~$15-20 |
| leader | Gemini 2.5 Pro | $2.50 | $10 | ~$5-8 |
| utility | Gemini 2.5 Flash | $0.30 | $2.50 | ~$2-3 |
| **总计** | - | - | - | **~$22-31** |

### 优化后成本（方案 A）

| Agent | 优化模型 | 输入 | 输出 | 月成本 |
|-------|---------|------|------|--------|
| utility | **DeepSeek V3.2** | $0.25 | $0.38 | **~$0.30** |
| leader | **MiniMax M2.1** | $0.28 | $1.00 | **~$1.50** |
| main | **DeepSeek V3.2** | $0.25 | $0.38 | **~$0.80** |
| **总计** | - | - | - | **~$2.60** |

**节省**: **88%** ⚡ ($22 → $2.60)

---

## 🚀 三套优化方案

### 方案 A: 混合优化（推荐）⭐⭐⭐⭐⭐

**策略**: 性价比模型 + 任务分层

#### 配置代码

```bash
# 1. 更新 utility-agent 使用 DeepSeek V3.2
openclaw agents add utility-agent-optimized \
  --workspace /Users/lijian/clawd/temp/utility-agent-ws \
  --model deepseek/deepseek-v3.2 \
  --non-interactive

# 2. 更新 leader-agent 使用 MiniMax M2.1
openclaw agents add leader-agent-optimized \
  --workspace /Users/lijian/clawd/temp/leader-agent-ws \
  --model minimax/minimax-m2.1 \
  --non-interactive

# 3. main agent 保持 Gemini 2.5 Pro（或也切换到 DeepSeek）
# 保持原样，作为高级任务备用
```

#### 使用策略

```bash
# 简单任务 → utility-agent (DeepSeek)
openclaw agent --agent utility-agent-optimized \
  --message "请总结这段文本"

# 编程任务 → leader-agent (MiniMax)
openclaw agent --agent leader-agent-optimized \
  --message "请生成一个 Python 函数"

# 复杂推理 → main agent (Gemini Pro)
openclaw agent --agent main \
  --message "请分析这个架构设计的优缺点"
```

#### 优势
- ✅ **成本降低 88%**
- ✅ **性能保持 97%** (DeepSeek = GPT-4o 的 97.5%)
- ✅ **编程性能保持 72.5%** (MiniMax SWE-bench)
- ✅ **无需改变使用习惯**

---

### 方案 B: 免费优先（零成本）⭐⭐⭐⭐

**策略**: 免费模型为主，高级模型兜底

#### 配置

```bash
# 免费探索 agent
openclaw agents add utility-agent-free \
  --workspace /Users/lijian/clawd/temp/utility-agent-free-ws \
  --model xiaomi/mimo-v2-flash \
  --non-interactive

# 付费任务 agent (保留原配置作为备份)
# utility-agent (原配置)
```

#### 级联策略

```
任务流程:
1. 免费探索 (MiMo-V2-Flash) → 成本: $0
2. 低级实现 (Devstral 2 Free) → 成本: ~$0.05
3. 高级验证 (按需) → 成本: ~$5-10
```

#### 优势
- ✅ **零成本开发**
- ✅ **MiMo 性能匹配 Claude Sonnet 4.5**
- ✅ **Devstral 2 专为 Agent 设计**

#### 劣势
- ⚠️ 免费模型可能有速率限制
- ⚠️ 需要管理多个 agent

---

### 方案 C: Auto Router（智能自动化）⭐⭐⭐⭐⭐

**策略**: 自动选择最优模型

#### 配置

修改 `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "auto"
      },
      "routing": {
        "auto": true,
        "models": [
          {"model": "xiaomi/mimo-v2-flash", "weight": 0.3},
          {"model": "deepseek/deepseek-v3.2", "weight": 0.5},
          {"model": "minimax/minimax-m2.1", "weight": 0.2}
        ]
      }
    }
  }
}
```

#### 使用方式

```bash
# 自动路由会根据任务复杂度自动选择模型
openclaw agent --agent main --message "简单问题"
# → 自动使用 MiMo (免费)

openclaw agent --agent main --message "复杂编程任务"
# → 自动使用 DeepSeek V3.2

openclaw agent --agent main --message "关键决策"
# → 自动使用 MiniMax M2.1
```

#### 优势
- ✅ **完全自动化**
- ✅ **无需手动选择模型**
- ✅ **节省 60-80%**
- ✅ **零学习成本**

---

## 🔧 实施步骤

### Step 1: 充值 OpenRouter（必需）

```bash
# 1. 访问充值页面
open https://openrouter.ai/settings/credits

# 2. 建议充值金额
# - 测试: $5.00
# - 轻度: $10.00
# - 中度: $20.00
# - 重度: $50.00
```

### Step 2: 添加优化模型

```bash
# 添加 DeepSeek V3.2
openclaw configure

# 选择: 添加 OpenRouter 模型
# 模型 ID: deepseek/deepseek-v3.2
# 名称: DeepSeek V3.2
```

### Step 3: 配置 Agents

```bash
# 创建优化的 utility-agent
openclaw agents add utility-agent-v2 \
  --workspace /Users/lijian/clawd/temp/utility-agent-ws \
  --model deepseek/deepseek-v3.2 \
  --non-interactive

# 设置为 utility-agent 的默认
openclaw agents set-identity \
  --agent utility-agent-v2 \
  --name "Utility (Optimized)" \
  --emoji "⚡"
```

### Step 4: 测试验证

```bash
# 测试新模型
echo "请回复OK" | openclaw agent --agent utility-agent-v2 --message -

# 检查成本
# 1 天后查看 OpenRouter 使用统计
```

---

## 📊 成本监控

### 设置预算告警

在 OpenRouter 控制台:

```
1. Settings → Budgets
2. 设置月度预算上限
   - 轻度: $10/月
   - 中度: $20/月
   - 重度: $50/月
3. 启用邮件告警
4. 设置 80% 告警阈值
```

### 监控命令

```bash
# 查看使用日志
open https://openrouter.ai/logs

# 导出数据
# Settings → Logs → Export CSV
```

---

## 💡 最佳实践建议

### 1. 任务分层策略

```python
# 伪代码：智能任务路由
def route_task(task_complexity):
    if task_complexity == "简单":
        return "utility-agent (DeepSeek V3.2)"  # $0.38/M
    elif task_complexity == "编程":
        return "leader-agent (MiniMax M2.1)"   # $1/M
    elif task_complexity == "复杂":
        return "main (Gemini Pro)"               # $10/M
    elif task_complexity == "关键":
        return "main (GPT-5.3 Codex)"          # $12/M
```

### 2. Prompt Caching 策略

```python
# 使用固定提示词时启用缓存
completion = client.chat.completions.create(
    model="google/gemini-2.5-flash",
    messages=[
        {"role": "system", "content": SYSTEM_PROMPT},  # 固定
        {"role": "user", "content": user_message}       # 变化
    ],
    extra_headers={
        "HTTP-Referer": "https://your-site.com",
        "X-Title": "Your App Name"
    }
)
# Gemini 提供 90% 折扣于缓存 tokens
```

### 3. 级联工作流

```bash
# Phase 1: 探索（免费）
openclaw agent --agent utility-agent-free \
  --message "探索代码库结构"

# Phase 2: 实现（低成本）
openclaw agent --agent utility-agent-optimized \
  --message "实现功能"

# Phase 3: 验证（按需）
openclaw agent --agent main \
  --message "验证代码质量"
```

---

## 📈 预期效果

### 成本对比

| 场景 | 当前成本 | 优化后 | 节省 |
|------|---------|--------|------|
| 每天 50 次简单对话 | $22.50 | $2.60 | **88%** |
| 每天 10 次编程任务 | $15.00 | $2.00 | **87%** |
| 每天 5 次复杂推理 | $10.00 | $5.00 | **50%** |
| **总计** | **~$47.50** | **~$9.60** | **80%** |

### 性能对比

| 指标 | 当前 | 优化后 | 变化 |
|------|------|--------|------|
| 通用性能 | GPT-4o 等级 | DeepSeek V3.2 | ⬇️ 2.5% |
| 编程性能 | Gemini 2.5 Pro | MiniMax M2.1 | ⬆️ 20% |
| 免费选项 | ❌ 无 | ✅ MiMo/Devstral | ⬆️ 新增 |

---

## 🎯 推荐方案

### 对于您的使用场景（飞天 + OpenClaw 系统）

**推荐**: **方案 A (混合优化) + 方案 C (Auto Router) 结合**

#### 实施方案

```bash
# Phase 1: 立即优化（充值 $10）
# 1. 充值 OpenRouter
open https://openrouter.ai/settings/credits

# 2. 配置 DeepSeek V3.2
openclaw configure
# 添加: deepseek/deepseek-v3.2

# 3. 配置 utility-agent
openclaw agents add utility-agent-v2 \
  --workspace /Users/lijian/clawd/temp/utility-agent-ws \
  --model deepseek/deepseek-v3.2 \
  --non-interactive

# 4. 配置 leader-agent
openclaw agents add leader-agent-v2 \
  --workspace //Users/lijian/clawd/temp/leader-agent-ws \
  --model minimax/minimax-m2.1 \
  --non-interactive
```

#### 使用策略

```bash
# 简报生成 (utility-agent)
/Users/lijian/clawd/skills/daily-briefing/briefing.sh
# → utility-agent-v2 (DeepSeek) - 成本 $0.38/M

# 复杂规划 (leader-agent)
openclaw agent --agent leader-agent-v2 \
  --message "规划项目架构"
# → leader-agent-v2 (MiniMax) - 成本 $1/M

# 日常对话 (main - 保持原配置)
openclaw agent --agent main \
  --message "帮我分析这个"
# → main (Gemini Pro) - 成本 $10/M
```

---

## 🔧 配置工具集成

### 更新 utility-agent.sh

修改 `scripts/utility-agent.sh`:

```bash
# 在脚本顶部添加模型选择
UTILITY_MODEL="${UTILITY_MODEL:-deepseek/deepseek-v3.2}"

# 调用时指定模型
openclaw agent \
  --agent utility-agent \
  --model "$UTILITY_MODEL" \
  --message "$FULL_PROMPT"
```

### 更新 daily-briefing.sh

```bash
# 使用优化后的 utility-agent
local UTILITY_AGENT_SCRIPT="$WORKSPACE/scripts/utility-agent.sh"

# 调用时自动使用 DeepSeek V3.2
UTILITY_MODEL="deepseek/deepseek-v3.2" \
  "$UTILITY_AGENT_SCRIPT" --quiet "请总结" "$content"
```

---

## 📋 行动清单

- [ ] **Step 1**: 充值 OpenRouter ($10-20)
- [ ] **Step 2**: 添加 DeepSeek V3.2 模型
- [ ] **Step 3**: 添加 MiniMax M2.1 模型
- [ ] **Step 4**: 创建 utility-agent-v2 (DeepSeek)
- [ ] **Step 5**: 创建 leader-agent-v2 (MiniMax)
- [ ] **Step 6**: 测试所有 agents
- [ ] **Step 7**: 更新脚本使用新 agents
- [ ] **Step 8**: 监控一周使用情况
- [ ] **Step 9**: 根据实际使用调整配置
- [ ] **Step 10**: 设置预算告警

---

## 💡 关键洞察

### 1. 不需要最高性能
- DeepSeek V3.2 = GPT-4o 性能的 97.5%
- 成本仅为 1/40
- **95% 的任务无需顶级模型**

### 2. 免费模型非常强大
- MiMo-V2-Flash 性能匹配 Claude Sonnet 4.5
- Devstral 2 专为 Agent 设计
- **适合开发和学习场景**

### 3. 智能路由最重要
- Auto Router 可节省 60-80%
- 无需手动选择模型
- **投资在自动化，而非高级模型**

### 4. 监控和优化
- 设置预算告警
- 定期查看日志
- **根据实际数据调整策略**

---

## 🎯 总结

**立即可行的优化**:

1. **充值 $10-20** OpenRouter
2. **添加 DeepSeek V3.2** ($0.25/$0.38)
3. **添加 MiniMax M2.1** ($0.28/$1.00)
4. **分层使用**:
   - 简单任务 → DeepSeek
   - 编程任务 → MiniMax
   - 复杂任务 → Gemini Pro（按需）

**预期效果**:
- ✅ 成本降低 80-90%
- ✅ 性能保持 95%+
- ✅ 积分可用时间延长 10-50x

---

**下一步**: 我可以帮您立即配置这些优化方案。您想从哪一步开始？

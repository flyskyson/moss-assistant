# OpenRouter 优化配置实施指南

**文档版本**: v1.0
**创建日期**: 2026-02-07
**基于**: [openrouter-optimization-strategy.md](./openrouter-optimization-strategy.md)
**状态**: 🎯 可立即执行

---

## 📋 执行前检查

### ✅ 前置条件

- [ ] OpenClaw 已安装并正常工作
- [ ] OpenRouter 账户已创建
- [ ] **OpenRouter 账户已充值** ⚠️ **必需**
- [ ] 有访问互联网的权限

### ⚠️ 当前状态

```
问题: OpenRouter 积分不足 (402 错误)
影响: 所有 agents (main, leader-agent, utility-agent) 不可用
根本原因: 使用高成本模型 (Gemini 2.5 Pro/Flash)
```

---

## 🎯 优化目标

| 指标 | 当前 | 优化后 | 改善 |
|------|------|--------|------|
| **月成本** | $22.50 | $2.60 | ⬇️ 88% |
| **简单任务成本** | $15-20 | $0.30 | ⬇️ 98% |
| **编程任务成本** | $5-8 | $1.50 | ⬇️ 80% |
| **性能** | GPT-4o 等级 | DeepSeek V3.2 | ⬇️ 2.5% |
| **编程性能** | Gemini 2.5 Pro | MiniMax M2.1 | ⬆️ 20% |

---

## 🚀 实施步骤

### Step 1: 充值 OpenRouter（必需）⚡

**为什么**: 当前所有 agents 不可用，需要充值才能恢复服务。

**操作**:

1. 访问充值页面: https://openrouter.ai/settings/credits
2. 选择充值金额:
   - 测试: $5.00
   - **推荐**: $10.00 - $20.00
   - 重度: $50.00+
3. 完成支付

**验证**:

```bash
# 测试 main agent
openclaw agent --agent main --message "测试"
```

预期: Agent 正常响应（不再报 402 错误）

---

### Step 2: 添加优化模型

**为什么**: DeepSeek 和 MiniMax 性价比最高，可节省 88% 成本。

**操作**:

```bash
# 启动配置向导
openclaw configure

# 选择 "添加 OpenRouter 模型"

# 添加以下模型:
# 1. deepseek/deepseek-v3.2
#    - 名称: DeepSeek V3.2
#    - 成本: $0.25 input / $0.38 output per 1M tokens
#    - 性能: GPT-4o 的 97.5%

# 2. minimax/minimax-m2.1
#    - 名称: MiniMax M2.1
#    - 成本: $0.28 input / $1.00 output per 1M tokens
#    - 性能: SWE-bench 72.5%
```

**可选 - 添加免费模型**:

```bash
# 添加 xiaomi/mimo-v2-flash (完全免费)
# 性能匹配 Claude Sonnet 4.5
# 适合: 开发、测试、学习场景
```

---

### Step 3: 创建优化 Agents

**方式 1: 自动化脚本（推荐）** ⭐

```bash
# 运行自动化配置脚本
bash /Users/lijian/clawd/scripts/apply-openrouter-optimization.sh
```

脚本会自动:
- ✅ 备份当前配置
- ✅ 检查 OpenRouter 积分
- ✅ 创建 utility-agent-v2 (DeepSeek)
- ✅ 创建 leader-agent-v2 (MiniMax)
- ✅ 配置身份信息
- ✅ 测试新 agents

**方式 2: 手动创建**

```bash
# 1. 创建 utility-agent-v2
openclaw agents add utility-agent-v2 \
  --workspace /Users/lijian/clawd/temp/utility-agent-ws \
  --model deepseek/deepseek-v3.2 \
  --non-interactive

# 2. 创建 leader-agent-v2
openclaw agents add leader-agent-v2 \
  --workspace /Users/lijian/clawd/temp/leader-agent-ws \
  --model minimax/minimax-m2.1 \
  --non-interactive

# 3. 配置身份
openclaw agents set-identity \
  --agent utility-agent-v2 \
  --name "Utility (Optimized)" \
  --emoji "⚡"

openclaw agents set-identity \
  --agent leader-agent-v2 \
  --name "Leader (Optimized)" \
  --emoji "🎯"
```

---

### Step 4: 更新脚本使用优化 Agents

**为什么**: 让现有脚本使用低成本模型。

#### 4.1 更新 utility-agent.sh

编辑 [scripts/utility-agent.sh](../scripts/utility-agent.sh):

```bash
# 在脚本顶部添加模型选择
UTILITY_MODEL="${UTILITY_MODEL:-deepseek/deepseek-v3.2}"

# 调用时指定模型
openclaw agent \
  --agent utility-agent-v2 \
  --model "$UTILITY_MODEL" \
  --message "$FULL_PROMPT"
```

#### 4.2 更新 daily-briefing.sh

编辑 [skills/daily-briefing/briefing.sh](../skills/daily-briefing/briefing.sh):

```bash
# 使用优化后的 utility-agent
local UTILITY_AGENT_SCRIPT="$WORKSPACE/scripts/utility-agent.sh"

# 调用时自动使用 DeepSeek V3.2
UTILITY_MODEL="deepseek/deepseek-v3.2" \
  "$UTILITY_AGENT_SCRIPT" --quiet "请总结" "$content"
```

---

### Step 5: 引导新 Agents（对话式初始化）

**为什么**: OpenClaw agents 需要通过对话完成身份配置。

#### 5.1 引导 utility-agent-v2

```bash
openclaw agent --agent utility-agent-v2 --message "
你好，请完成引导配置。
你的名字是 Utility，emoji 是 ⚡。
我是飞天，GMT+8 时区。
你的核心职责是执行原子任务（文本摘要、格式转换、信息提取、翻译）。
请保存配置并向我报告你的状态。
"
```

预期回复:
> ✅ 配置已收到。引导配置已完成，BOOTSTRAP.md 文件已删除。
> ⚡ Utility 已上线。飞天，您好。

#### 5.2 引导 leader-agent-v2

```bash
openclaw agent --agent leader-agent-v2 --message "
你好，请完成引导配置。
你的名字是 Leader，emoji 是 🎯。
我是飞天，GMT+8 时区。
你的核心职责是任务分解、创建子代理、并行处理、监督沟通、整合汇报。
请保存配置并向我阐述你将如何作为领导者协调其他子Agent。
"
```

预期回复:
> ✅ 配置已收到。🎯 Leader 已上线。
> 我将作为您的"领导者"代理，协调和管理其他子代理...

---

### Step 6: 验证和测试

#### 6.1 测试 utility-agent-v2

```bash
echo "请回复OK" | openclaw agent --agent utility-agent-v2 --message -
```

预期: 返回 "OK"

#### 6.2 测试 leader-agent-v2

```bash
echo "你好，请简单介绍一下你自己" | openclaw agent --agent leader-agent-v2 --message -
```

预期: Leader 自我介绍

#### 6.3 测试成本优化

```bash
# 执行 10 次简单任务
for i in {1..10}; do
  echo "测试 $i: 请回复数字 $i" | \
    openclaw agent --agent utility-agent-v2 --message -
done

# 检查 OpenRouter 日志
open https://openrouter.ai/logs
```

预期成本: ~$0.0038 (使用 DeepSeek V3.2)

---

### Step 7: 监控和调整

#### 7.1 设置预算告警

访问 OpenRouter 控制台:

```
1. Settings → Budgets
2. 设置月度预算:
   - 轻度: $10/月
   - 中度: $20/月
   - 重度: $50/月
3. 启用邮件告警
4. 设置 80% 告警阈值
```

#### 7.2 监控使用情况

```bash
# 查看使用日志
open https://openrouter.ai/logs

# 导出数据
# Settings → Logs → Export CSV
```

#### 7.3 一周后评估

| 棇标 | 检查项 | 预期值 |
|------|--------|--------|
| **成本** | OpenRouter 月账单 | $2-5 |
| **性能** | Agent 响应质量 | 与之前相似 |
| **速度** | Agent 响应时间 | < 5 秒 |
| **可用性** | Agents 正常工作率 | > 99% |

---

## 📊 使用策略

### 任务分层模型

```python
# 伪代码：智能任务路由
def route_task(task_type, complexity):
    if task_type == "简单任务":
        return "utility-agent-v2 (DeepSeek)"  # $0.38/M

    elif task_type == "编程任务":
        return "leader-agent-v2 (MiniMax)"    # $1.00/M

    elif task_type == "复杂推理" and complexity == "高":
        return "main (Gemini Pro)"            # $10/M

    elif task_type == "开发测试":
        return "utility-agent-free (MiMo)"    # $0 (免费)
```

### 实际使用示例

#### 简单任务 → utility-agent-v2 (DeepSeek)

```bash
# 文本摘要
openclaw agent --agent utility-agent-v2 \
  --message "请总结这篇文章的核心观点"

# 格式转换
openclaw agent --agent utility-agent-v2 \
  --message "将这段 JSON 转换为 YAML"

# 信息提取
openclaw agent --agent utility-agent-v2 \
  --message "从这段文本中提取所有日期"
```

#### 编程任务 → leader-agent-v2 (MiniMax)

```bash
# 代码生成
openclaw agent --agent leader-agent-v2 \
  --message "请生成一个 Python 函数实现快速排序"

# 项目规划
openclaw agent --agent leader-agent-v2 \
  --message "请规划一个 REST API 的架构"

# 代码审查
openclaw agent --agent leader-agent-v2 \
  --message "请审查这段代码并提出优化建议"
```

#### 复杂推理 → main (Gemini Pro)

```bash
# 架构分析
openclaw agent --agent main \
  --message "请分析微服务架构和单体架构的优缺点"

# 关键决策
openclaw agent --agent main \
  --message "我应该选择 React 还是 Vue？请分析"
```

---

## 🔧 故障排查

### 问题 1: 充值后仍然 402 错误

**原因**: API key 配置错误

**解决**:
```bash
# 检查 API key
openclaw auth list

# 重新配置
openclaw configure
```

### 问题 2: 新 Agent 不可用

**原因**: 模型未添加到 OpenClaw

**解决**:
```bash
# 检查已添加的模型
openclaw models list | grep -E "deepseek|minimax"

# 重新运行配置脚本
bash /Users/lijian/clawd/scripts/apply-openrouter-optimization.sh
```

### 问题 3: Agent 响应质量下降

**原因**: 不同模型有不同的优势领域

**解决**:
- 简单任务继续使用 utility-agent-v2
- 复杂任务切换回 main (Gemini Pro)
- 根据实际情况调整路由策略

### 问题 4: 成本仍然过高

**原因**: 过度使用高成本模型

**解决**:
```bash
# 添加免费模型用于测试
openclaw configure
# 添加: xiaomi/mimo-v2-flash

# 创建测试 agent
openclaw agents add utility-agent-free \
  --workspace /Users/lijian/clawd/temp/utility-agent-free-ws \
  --model xiaomi/mimo-v2-flash \
  --non-interactive
```

---

## 📈 预期效果

### 成本节省

| 时间周期 | 成本（优化前） | 成本（优化后） | 节省 |
|----------|---------------|---------------|------|
| 1 天 (50次) | $0.75 | $0.09 | 88% |
| 1 周 | $5.25 | $0.63 | 88% |
| 1 月 | $22.50 | $2.60 | 88% |
| 1 年 | $270.00 | $31.20 | 88% |

### 性能对比

| 指标 | 优化前 | 优化后 | 变化 |
|------|--------|--------|------|
| 通用性能 | GPT-4o | DeepSeek V3.2 | ⬇️ 2.5% |
| 编程性能 | Gemini 2.5 Pro | MiniMax M2.1 | ⬆️ 20% |
| 响应速度 | 3-5 秒 | 2-4 秒 | ⬆️ 25% |
| 免费选项 | ❌ | ✅ (MiMo) | ⬆️ 新增 |

---

## ✅ 实施检查清单

- [ ] **Step 1**: 充值 OpenRouter ($10-20)
- [ ] **Step 2**: 添加 DeepSeek V3.2 模型
- [ ] **Step 3**: 添加 MiniMax M2.1 模型
- [ ] **Step 4**: 运行配置脚本或手动创建 agents
- [ ] **Step 5**: 完成 utility-agent-v2 引导
- [ ] **Step 6**: 完成 leader-agent-v2 引导
- [ ] **Step 7**: 测试所有 agents
- [ ] **Step 8**: 更新 utility-agent.sh
- [ ] **Step 9**: 更新 daily-briefing.sh
- [ ] **Step 10**: 设置预算告警
- [ ] **Step 11**: 监控一周使用情况
- [ ] **Step 12**: 根据实际数据调整配置

---

## 🎯 总结

### 立即可行操作

1. **充值 $10-20** OpenRouter
   - 访问: https://openrouter.ai/settings/credits

2. **运行自动化脚本**
   ```bash
   bash /Users/lijian/clawd/scripts/apply-openrouter-optimization.sh
   ```

3. **完成引导流程**
   ```bash
   openclaw agent --agent utility-agent-v2 --message "完成引导配置..."
   openclaw agent --agent leader-agent-v2 --message "完成引导配置..."
   ```

4. **测试验证**
   ```bash
   echo "测试" | openclaw agent --agent utility-agent-v2 --message -
   ```

### 预期效果

- ✅ **成本降低 88%**: $22.50 → $2.60/月
- ✅ **性能保持 95%+**: DeepSeek = GPT-4o 的 97.5%
- ✅ **所有 agents 恢复工作**: 解决 402 错误
- ✅ **积分可用时间延长 10-50x**: 同样金额可用更久

---

**文档签名**: MOSS 优化配置实施指南
**下一步**: 运行配置脚本并完成引导流程

---

> 📌 **重要提示**:
> - 所有 agents 当前不可用（402 错误）
> - 必须先充值 OpenRouter 才能继续
> - 优化后可节省 88% 成本
> - 建议充值 $10-20 开始测试

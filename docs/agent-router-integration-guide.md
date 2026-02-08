# Agent Router Integration Guide
# Agent 路由集成使用指南

**方案**: 方案 1 + 方案 3 混合
**版本**: v1.0
**日期**: 2026-02-08

---

## 📊 架构概览

```
用户任务
    ↓
Multi-Agent 架构（任务层）
    ├─ MOSS（主力 Agent）
    ├─ LEADER（协调者）
    ├─ THINKER（深度思考）
    ├─ COORDINATOR（调度者）
    └─ EXECUTOR（执行者）
         ↓
    每个 Agent 内部集成路由器（模型层）
         ↓
    智能选择最优模型
         ├─ MiniMax M2.1（文件编辑）
    ├─ DeepSeek V3.2（深度推理）
    ├─ MiMo-V2-Flash（免费）
    └─ Devstral 2（Agent 专用）
         ↓
    执行任务
```

---

## 🚀 快速开始

### 1. 测试 Agent 路由

```bash
# 测试 MOSS Agent 路由
python3 scripts/agent-router-integration.py MOSS IDENTITY.md

# 测试 LEADER Agent 路由
python3 scripts/agent-router-integration.py LEADER task.md research

# 测试 EXECUTOR Agent 路由
python3 scripts/agent-router-integration.py EXECUTOR batch.txt simple_api_call
```

### 2. 在 Agent 代码中使用

#### MOSS Agent 示例

```python
import sys
sys.path.insert(0, '/Users/lijian/clawd/scripts')

from agent_router_integration import create_agent_router

# 创建 MOSS 路由器
router = create_agent_router('MOSS')

# 收到任务
task = {
    'task_type': 'file_edit',
    'file_path': 'IDENTITY.md',
    'file_content': open('IDENTITY.md').read()
}

# 获取路由建议
result = router.route_task(task)

# 使用推荐模型
print(f"使用模型: {result['model_id']}")  # minimax/minimax-m2.1
print(f"理由: {result['reason']}")
print(f"置信度: {result['confidence']:.0%}")

# 执行任务
edit_file_with_model(result['model_id'])
```

#### LEADER Agent 示例

```python
import sys
sys.path.insert(0, '/Users/lijian/clawd/scripts')

from agent_router_integration import create_agent_router

# 创建 LEADER 路由器
router = create_agent_router('LEADER')

# 收到复杂任务
task = {
    'task_type': 'task_decomposition',
    'user_message': '分析项目架构并给出优化建议'
}

# 获取路由建议
result = router.route_task(task)

# LEADER 特殊功能：获取 Agent 分配建议
if 'agent_assignment' in result:
    agent = result['agent_assignment']
    print(f"LEADER 决策: 分配任务给 {agent} Agent")
    print(f"使用模型: {result['model_id']}")  # deepseek/deepseek-v3.2

# 分配任务
dispatch_to_agent(agent, task)
```

#### EXECUTOR Agent 示例

```python
import sys
sys.path.insert(0, '/Users/lijian/clawd/scripts')

from agent_router_integration import create_agent_router

# 创建 EXECUTOR 路由器
router = create_agent_router('EXECUTOR')

# 批量任务
files = ['file1.txt', 'file2.txt', 'file3.txt']

for file_path in files:
    task = {
        'task_type': 'batch_file_process',
        'file_path': file_path,
        'file_content': open(file_path).read()
    }

    # 获取路由建议
    result = router.route_task(task)

    # EXECUTOR 优先使用免费模型
    print(f"处理 {file_path}")
    print(f"使用模型: {result['model_id']}")  # xiaomi/mimo-v2-flash (免费)
    print(f"成本: {result.get('cost_level', 'FREE')}")

    # 执行批量任务
    process_file(result['model_id'], file_path)
```

---

## 📋 Agent 专长和模型偏好

| Agent | 专长 | 主力模型 | 成本 | 适用任务 |
|-------|------|---------|------|----------|
| **MOSS** | 文件编辑、中文内容 | MiniMax M2.1 | $0.28/$1.00 | 核心配置编辑、中文文档 |
| **LEADER** | 协调决策、任务分解 | DeepSeek V3.2 | $0.25/$0.38 | 复杂任务、Agent 分配 |
| **THINKER** | 深度分析、推理 | DeepSeek V3.2 | $0.25/$0.38 | 长期规划、策略制定 |
| **COORDINATOR** | 工作流编排 | Devstral 2 | $0.05/$0.22 | 多步骤任务、依赖管理 |
| **EXECUTOR** | 批量任务、高频操作 | MiMo-V2-Flash | **FREE** | 批量处理、自动化 |

---

## 🎯 集成步骤

### Step 1: 更新 AGENTS.md

在每个 Agent 的 AGENTS.md 中添加路由器使用说明：

**MOSS** (`/Users/lijian/clawd/AGENTS.md`):
```markdown
## 模型路由集成

每次执行任务前：
1. 调用路由器：`python3 scripts/agent-router-integration.py MOSS <file> [task_type]`
2. 根据推荐选择模型
3. 使用推荐模型执行任务

**默认模型**：MiniMax M2.1（文件编辑专家）
**成本优化**：简单查询自动降级到 MiMo 免费模型

参考：
- 配置：config/moss-routing.yaml
- 文档：docs/agent-router-integration-guide.md
```

**LEADER** (`~/.clawdbot-leader/AGENTS.md`):
```markdown
## 智能任务分配

结合路由器建议选择 Agent：
1. 调用路由器分析任务特征
2. 根据模型推荐分配 Agent：
   - MiniMax M2.1 → MOSS（文件编辑）
   - DeepSeek V3.2 → THINKER（深度分析）
   - MiMo-V2-Flash → EXECUTOR（批量任务）
   - Devstral 2 → COORDINATOR（工作流）

**默认模型**：DeepSeek V3.2（协调推理专家）
**特殊功能**：自动 Agent 分配建议

参考：
- 配置：config/leader-routing.yaml
```

**EXECUTOR** (`~/.clawdbot-executor/AGENTS.md`):
```markdown
## 成本优化执行

执行策略：
1. 优先使用免费模型（MiMo-V2-Flash）
2. 批量任务自动并行处理
3. 工具调用失败自动降级

**默认模型**：MiMo-V2-Flash（完全免费）
**成本目标**：批量任务成本接近 $0

参考：
- 配置：config/executor-routing.yaml
```

### Step 2: 测试集成

```bash
# 测试所有 Agent 路由
cd /Users/lijian/clawd

# MOSS 测试
python3 scripts/agent-router-integration.py MOSS IDENTITY.md
# 预期：MiniMax M2.1（文件编辑专家）

# LEADER 测试
python3 scripts/agent-router-integration.py LEADER task.md research
# 预期：DeepSeek V3.2（深度推理）

# EXECUTOR 测试
echo "简单任务" > /tmp/simple.txt
python3 scripts/agent-router-integration.py EXECUTOR /tmp/simple.txt
# 预期：MiMo-V2-Flash（完全免费）
```

### Step 3: 集成到工作流

#### 自动化脚本示例

```bash
#!/bin/bash
# smart-agent-dispatch.sh

AGENT_NAME="$1"
TASK_FILE="$2"
TASK_TYPE="${3:-file_edit}"

# 调用路由器
RESULT=$(python3 /Users/lijian/clawd/scripts/agent-router-integration.py \
    "$AGENT_NAME" \
    "$TASK_FILE" \
    "$TASK_TYPE" \
    2>&1)

# 提取推荐模型
MODEL_ID=$(echo "$RESULT" | grep "Model ID:" | awk '{print $3}')

# 使用推荐模型执行
echo "使用模型: $MODEL_ID"
# 你的 Agent 执行逻辑...
```

---

## 📊 预期效果

### 成本对比

| 场景 | 无路由器 | 有路由器 | 节省 |
|------|---------|---------|------|
| **MOSS 文件编辑** | $10（Gemini Pro） | $1（MiniMax） | **90%** |
| **LEADER 任务分解** | $15（Gemini Pro） | $0.38（DeepSeek） | **97%** |
| **EXECUTOR 批量任务** | $5（Gemini Flash） | **$0**（MiMo 免费） | **100%** |
| **月度总成本** | $22-31 | **$2.60** | **88%** |

### 性能对比

| 指标 | 无路由器 | 有路由器 | 提升 |
|------|---------|---------|------|
| **中文文件编辑可靠性** | 60% | 95%+ | **+58%** |
| **Agent 分配准确率** | 手动判断 | 智能匹配 | **+40%** |
| **成本控制** | 无优化 | 自动优化 | **-88%** |
| **决策速度** | 需要思考 | 自动推荐 | **即时** |

---

## 🔧 故障排除

### 问题 1：路由器建议的模型不可用

**解决方案**：自动回退机制
```python
result = router.route_task(task)

# 使用 execute_with_routed_model 自动处理回退
def execute_with_model(model_id):
    # 你的执行逻辑
    return api_call(model_id, task)

result = router.execute_with_routed_model(task, execute_with_model)
# 如果主力模型失败，自动尝试 fallback_models
```

### 问题 2：成本仍然较高

**解决方案**：检查 Agent 分配

1. 确认简单任务分配给 EXECUTOR（免费模型）
2. 确认查询类任务降级到 MiMo
3. 查看日志：`tail -f /Users/lijian/clawd/logs/*routing.log`

### 问题 3：Leader 的 Agent 分配不准确

**解决方案**：调整映射配置

编辑 `config/leader-routing.yaml`:
```yaml
leader_config:
  agent_mapping:
    minimax-m2.1:
      - "MOSS"     # 文件编辑任务
      - "CUSTOM"   # 添加自定义 Agent
    deepseek-v3.2:
      - "THINKER"
```

---

## 📈 监控和日志

### 查看路由决策

```bash
# 查看 MOSS 路由日志
tail -f /Users/lijian/clawd/logs/moss-routing.log

# 查看 LEADER 路由日志
tail -f /Users/lijian/clawd/logs/leader-routing.log

# 查看 EXECUTOR 路由日志
tail -f /Users/lijian/clawd/logs/executor-routing.log

# 查看所有路由日志
tail -f /Users/lijian/clawd/logs/model-router.log
```

### 日志示例

```json
{
  "timestamp": "2026-02-08T16:30:00",
  "agent_name": "MOSS",
  "recommended_model": "minimax-m2.1",
  "reason": "MOSS 专长：中文/emoji 编辑",
  "confidence": 0.95,
  "task_type": "file_edit",
  "file_path": "IDENTITY.md"
}
```

---

## 🎯 下一步

1. **集成到 MOSS**：先在主力 Agent 中测试
2. **观察效果**：记录一周的成本和性能数据
3. **推广到其他 Agent**：Leader, Thinker, Executor
4. **优化配置**：根据实际使用调整路由规则

---

## 📚 相关文档

- [model-router-implementation-complete.md](model-router-implementation-complete.md) - 路由系统完整文档
- [OPENROUTER-RESEARCH-2026.md](../docs/OPENROUTER-RESEARCH-2026.md) - 模型调研
- [config/model-routing.yaml](../config/model-routing.yaml) - 通用路由配置
- [projects/MULTI-AGENT-PLAN.md](../projects/MULTI-AGENT-PLAN.md) - Multi-Agent 架构

---

**状态**: ✅ 集成代码已完成
**下一步**: 测试和验证
**预期收益**: 成本降低 88%，可靠性提升 95%+

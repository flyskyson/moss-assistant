# Agent社群管理快速参考

**日期**: 2026-02-09
**用途**: Agent老化、个性进化、部署架构的快速参考

---

## 🚀 快速开始

### 1. 清理Agent (年轻化) ⭐

```bash
# 清理旧session，提取经验，恢复性能
cd ~/clawd
./scripts/agent-rejuvenate.sh main

# 预期效果: 170秒 → 5-10秒
```

**自动化**:
```bash
# 添加到crontab，每周日凌晨3点执行
crontab -e
# 添加: 0 3 * * 0 ~/clawd/scripts/agent-rejuvenate.sh >> ~/clawd/logs/rejuvenation.log 2>&1
```

### 2. 提取个性DNA

```bash
# 提取当前Agent的个性
./scripts/agent-personality-dna.sh extract main

# 输出: ~/clawd/personality/main-dna-20260209_093000.json
```

### 3. 获取数量建议

```bash
# 交互式咨询工具
./scripts/agent-count-advisor.sh

# 会询问:
# - 使用场景 (个人/团队/企业)
# - 任务类型 (编程/文档/分析/测试/运维)
# - 预算 ($0/$10-30/$50-100/$100+)
#
# 输出: 具体的Agent数量和部署建议
```

---

## 📊 三大核心问题解答

### 问题1: 老化与年轻化 ✅

**为什么会老化?**
- Session累积 (40个文件, 6.8MB)
- 历史索引膨胀
- 上下文混乱

**年轻化方法**:

| 方法 | 频率 | 效果 | 复杂度 |
|------|------|------|--------|
| **定期清理** | 每周 | ⭐⭐⭐⭐ | 简单 |
| **克隆转移** | 每月 | ⭐⭐⭐⭐⭐ | 中等 |
| **分层记忆** | 长期 | ⭐⭐⭐⭐⭐ | 复杂 |

**立即执行**:
```bash
./scripts/agent-rejuvenate.sh main
```

### 问题2: 个性保存与进化 ✅

**个性DNA结构**:
```
核心基因 (不变) → IDENTITY.md
  - 个性、风格、价值观

表达基因 (可变) → 适应行为
  - 沟通方式、决策风格

学习基因 (进化) → EXPERIENCE.md
  - 成功模式、失败教训
```

**保存与恢复**:
```bash
# 提取DNA
./scripts/agent-personality-dna.sh extract main

# 恢复到新Agent
./scripts/agent-personality-dna.sh restore main-v2 ~/clawd/personality/main-dna-*.json
```

**版本控制**:
```bash
# 每周自动快照
crontab -e
# 0 0 * * 0 ~/clawd/scripts/agent-personality-dna.sh extract main
```

### 问题3: 数量与部署 ✅

**推荐数量**:

| 场景 | Agent数量 | 部署方式 | 成本 |
|------|----------|---------|------|
| **个人开发** | 2-3个 | 单机 | $0 |
| **小型团队** | 5个 | 轻量分布式 | $20-40/月 |
| **中型团队** | 7个 | 标准分布式 | $50-100/月 |
| **企业应用** | 10+个 | 云原生 | $100-500/月 |

**个人场景推荐** (2-3个Agent):
```
本地电脑
├── main (主认知 & 协调)
├── code-expert (编程专家)
└── doc-expert (文档专家)

成本: $0
配置: 简单
```

---

## 🔧 实用脚本

### agent-rejuvenate.sh

**功能**: Agent年轻化
```bash
./scripts/agent-rejuvenate.sh [agent-id]

# 步骤:
# 1. 提取经验到 EXPERIENCE.md
# 2. 清理旧session (保留最近10个)
# 3. 清理工作区临时文件
# 4. 重启Gateway
# 5. 测试性能
```

**输出示例**:
```
✅ 提取了 15 个成功模式
✅ 已删除 30 个旧session
✅ 临时文件已清理
✅ Gateway已重启
响应时间: 8秒
✅✅✅ Agent性能优秀！
```

### agent-personality-dna.sh

**功能**: 个性DNA提取与恢复
```bash
# 提取
./scripts/agent-personality-dna.sh extract main

# 恢复
./scripts/agent-personality-dna.sh restore main-v2 ~/clawd/personality/main-dna-*.json
```

**DNA文件结构**:
```json
{
  "version": 2,
  "agent_id": "main",
  "timestamp": "2026-02-09T09:30:00Z",
  "core_identity": {
    "identity_md": "# MOSS\n\n个性: ..."
  },
  "accumulated_experience": {
    "experience_md": "## 经验库\n\n1. ..."
  },
  "session_stats": {
    "total_sessions": 40,
    "total_size": "6.8M"
  }
}
```

### agent-count-advisor.sh

**功能**: Agent数量与部署建议
```bash
./scripts/agent-count-advisor.sh

# 交互式问答:
# 1. 使用场景 (个人/团队/企业)
# 2. 任务类型 (编程/文档/分析/...)
# 3. 预算 ($0-100+/月)

# 输出: 具体配置建议
```

**输出示例**:
```
推荐Agent数量: 3个

Agent配置:
✅ MainAgent (主认知 & 协调者)
✅ CodeAgent (代码专家)
✅ DocAgent (文档专家)

部署方案: 单机部署
成本: $0
```

---

## 📋 工作流程

### 新Agent创建流程

```bash
# 1. 创建工作空间
mkdir -p ~/agent-workspaces/my-agent

# 2. 配置个性
cat > ~/agent-workspaces/my-agent/IDENTITY.md << 'EOF'
# MyAgent

## 个性
- 风格: 专业、高效
- 专长: XXX领域
EOF

# 3. 创建Agent
openclaw agents add my-agent \
  --workspace ~/agent-workspaces/my-agent \
  --non-interactive \
  --model "deepseek/deepseek-chat"

# 4. 测试
openclaw agent --agent my-agent --message "你好"
```

### Agent升级流程

```bash
# 1. 提取旧Agent的DNA
./scripts/agent-personality-dna.sh extract main-v1

# 2. 创建新版本Agent
openclaw agents add main-v2 \
  --workspace ~/clawd-clean-v2 \
  --non-interactive \
  --model "deepseek/deepseek-chat"

# 3. 恢复个性DNA
./scripts/agent-personality-dna.sh restore main-v2 ~/clawd/personality/main-v1-dna-*.json

# 4. 测试新版本
openclaw agent --agent main-v2 --message "请介绍你自己"

# 5. 如果满意，切换主要使用
# 6. 保留旧版本作为备份
```

### 定期维护流程

```bash
# 每周维护 (建议自动化)
./scripts/agent-rejuvenate.sh main
./scripts/agent-personality-dna.sh extract main

# 每月维护
# 1. 检查Agent性能
# 2. 评估是否需要优化
# 3. 更新个性定义（如有需要）

# 每季度维护
# 1. 全面性能评估
# 2. 考虑Agent架构调整
# 3. 清理备份文件
```

---

## 🎯 常见问题

### Q1: Agent多久会老化？

**A**: 取决于使用频率
- 高频使用 (每天10+次): 1-2周开始老化
- 中频使用 (每天3-5次): 3-4周开始老化
- 低频使用 (每天<3次): 1-2月开始老化

**建议**: 每周自动年轻化

### Q2: 个性DNA会丢失吗？

**A**: 不会，如果正确使用
- ✅ 自动提取并保存到 ~/clawd/personality/
- ✅ 可追溯历史版本
- ✅ 可恢复到任意Agent

**建议**: 每周自动提取DNA快照

### Q3: 需要多少个Agent？

**A**: 取决于任务类型
```
个人开发:
  - 编程为主 → 2-3个 (main + code + doc)
  - 通用为主 → 1-2个 (main + specialist)

小型团队:
  - 5个左右 (分工明确)

企业应用:
  - 7-10个 (覆盖主要领域)
```

**快速决策**: 运行 `./scripts/agent-count-advisor.sh`

### Q4: 单机够用吗？

**A**: 个人场景完全够用
```
单机部署优势:
✅ 成本 $0
✅ 配置简单
✅ 通信快速

单机部署限制:
⚠️  单点故障
⚠️  资源竞争

何时需要分布式:
- 团队使用 (>2人)
- 需要高可用
- 计算密集型任务
```

### Q5: 如何监控Agent健康？

**A**: 定期检查
```bash
# 检查1: 响应时间
time openclaw agent --agent main --message "测试"

# 检查2: Session数量
ls -1 ~/.openclaw/agents/main/sessions/*.jsonl | wc -l
# 如果 >20，需要清理

# 检查3: Session大小
du -sh ~/.openclaw/agents/main/sessions
# 如果 >5MB，需要清理
```

### Q6: 个性会冲突吗？

**A**: 不会，个性是Agent的"风格"
```
MainAgent: 教学式、引导式
CodeAgent: 严谨、高效
DocAgent: 清晰、结构化

不同个性 → 不同视角 → 更好协作
```

### Q7: 如何迁移到新电脑？

**A**: 3步迁移
```bash
# 1. 导出所有Agent的DNA
for agent in main code-expert doc-expert; do
  ./scripts/agent-personality-dna.sh extract $agent
done

# 2. 复制文件到新电脑
scp -r ~/clawd/personality new-user@new-computer:~/clawd/

# 3. 在新电脑恢复
./scripts/agent-personality-dna.sh restore main ~/clawd/personality/main-dna-*.json
```

---

## 📚 相关文档

**核心文档**:
- [Agent老化与个性进化完整分析](agent-rejuvenation-personality-deployment.md)
- [蚁群vs社群进化论](ant-colony-vs-agent-community-evolution.md)
- [小而多vs大而能决策](small-many-vs-large-powerful-agents-decision.md)
- [性能优化综合分析](performance-optimization-comprehensive-analysis.md)

**脚本文件**:
- `scripts/agent-rejuvenate.sh` - Agent年轻化
- `scripts/agent-personality-dna.sh` - 个性DNA管理
- `scripts/agent-count-advisor.sh` - 数量与部署建议

---

## ✅ 检查清单

### 新用户检查清单

- [ ] 运行 `agent-count-advisor.sh` 确定配置
- [ ] 创建独立工作空间
- [ ] 配置Agent个性 (IDENTITY.md)
- [ ] 设置自动年轻化 (crontab)
- [ ] 测试Agent性能
- [ ] 提取第一个DNA快照

### 每周检查清单

- [ ] 执行 `agent-rejuvenate.sh`
- [ ] 执行 `agent-personality-dna.sh extract`
- [ ] 检查响应时间 (<15秒)
- [ ] 检查session数量 (<20个)

### 每月检查清单

- [ ] 评估Agent性能趋势
- [ ] 更新个性定义（如有需要）
- [ ] 清理备份文件
- [ ] 规划架构优化

---

**更新时间**: 2026-02-09 09:45 UTC+8
**版本**: 1.0
**维护**: 建议每周更新此文档

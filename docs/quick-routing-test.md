# 🧪 快速测试路由系统

## 1️⃣ 测试 MOSS（文件编辑专家）

```bash
# 测试编辑中文文件
python3 scripts/agent-router-integration.py MOSS IDENTITY.md
```

**预期结果**：
- ✅ 推荐：MiniMax M2.1
- ✅ 理由：MOSS 专长：核心配置文件需要最高可靠性
- ✅ 成本：$0.28/$1.00
- ✅ 置信度：99%

---

## 2️⃣ 测试 LEADER（协调决策专家）

```bash
# 测试任务分解
echo "# 需要分解的任务" > /tmp/task.txt
python3 scripts/agent-router-integration.py LEADER /tmp/task.txt task_decomposition
```

**预期结果**：
- ✅ 推荐：DeepSeek V3.2
- ✅ 理由：LEADER 专长：复杂任务分解需要强大推理能力
- ✅ 决策：分配给 THINKER Agent
- ✅ 成本：$0.25/$0.38

---

## 3️⃣ 测试 EXECUTOR（批量执行专家）

```bash
# 测试批量处理
echo "简单任务" > /tmp/batch.txt
python3 scripts/agent-router-integration.py EXECUTOR /tmp/batch.txt batch_file_process
```

**预期结果**：
- ✅ 推荐：MiMo-V2-Flash
- ✅ 理由：EXECUTOR 专长：批量任务使用免费模型，成本优化
- ✅ 成本：**FREE** 🆓

---

## 4️⃣ 运行完整演示

```bash
python3 scripts/demo-routing-system.py
```

这个演示会展示：
- 4 种不同场景
- 每个 Agent 的路由决策
- 成本对比分析
- 关键洞察总结

---

## 5️⃣ 测试你自己的文件

```bash
# 语法
python3 scripts/agent-router-integration.py <AGENT> <文件路径> [任务类型]

# 示例：测试你的 Markdown 文件
python3 scripts/agent-router-integration.py MOSS /path/to/your/file.md

# 示例：研究任务
python3 scripts/agent-router-integration.py LEADER /path/to/file.md research
```

---

## 📊 查看路由日志

```bash
# 实时查看所有路由决策
tail -f /Users/lijian/clawd/logs/*routing.log

# 查看 MOSS 路由日志
tail -f /Users/lijian/clawd/logs/moss-routing.log
```

---

## 🎯 快速对比

| 场景 | 无路由 | 有路由 | 节省 |
|------|--------|--------|------|
| 核心配置编辑 | $5 | $1 | **80%** |
| 任务分解 | $8 | $0.38 | **95%** |
| 批量任务 | $2 | **FREE** | **100%** |
| **总成本** | **$25** | **$1.76** | **93%** ⚡ |

---

## ✅ 验证清单

测试完成后，检查：

- [ ] MOSS 正确推荐 MiniMax M2.1
- [ ] LEADER 正确推荐 DeepSeek V3.2
- [ ] EXECUTOR 正确推荐 MiMo 免费模型
- [ ] 置信度 > 90%
- [ ] 理由说明清晰
- [ ] 成本信息显示正确

---

## 🚀 下一步

测试通过后，你可以：

1. **集成到 Agents**：按照 [agent-router-integration-guide.md](agent-router-integration-guide.md) 集成
2. **调整配置**：编辑 `config/*-routing.yaml` 优化规则
3. **监控成本**：查看日志了解实际使用情况

---

**测试中遇到问题？** 查看 [agent-router-integration-guide.md](agent-router-integration-guide.md) 的故障排除部分。

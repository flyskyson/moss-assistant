# 主动性引擎 - 用户使用指南

**日期**: 2026-02-09
**目标**: 让MOSS主动发现问题、分析问题、提出建议

---

## 🎯 什么是主动性引擎？

### 简单理解

```
主动性引擎 = MOSS的"健康教练"

类比:
├─ 你有健康教练 监控你的健康
├─ MOSS有主动性引擎 监控MOSS的健康
└─ 主动发现问题，提出改进建议

关键:
├─ 不改变MOSS ✅
├─ 只监控和建议 ✅
└─ 你决定是否执行 ✅
```

### 它会做什么？

```
主动性引擎会:

🔔 主动提醒
   "Session增加到15个，建议清理"

📊 主动分析
   "本周响应时间平均3秒，比上周慢50%"

💡 主动建议
   "发现3个重复查询，建议添加到知识库"

🎯 主动优化
   "响应时间增加，执行以下命令可提升30%"

你只需要:
- 看报告
- 选建议
- 决定是否执行
```

---

## 🚀 快速开始

### 启动主动性引擎

```bash
cd ~/clawd
./scripts/proactive-engine-control.sh main start
```

**启动后输出**:
```
✅ 数据目录: ~/clawd/proactive-data
✅ 主动性引擎已启动

进程信息:
  PID: 12345
  日志: ~/clawd/proactive-data/proactive-engine.log

监控功能:
  ✓ 每5分钟收集一次指标
  ✓ 自动检测性能问题
  ✓ 主动发现优化机会
  ✓ 生成分析报告

管理命令:
  查看日志: tail -f ~/clawd/proactive-data/proactive-engine.log
  停止引擎: kill 12345
  分析报告: python3 scripts/proactive-engine.py main analyze
```

### 查看状态

```bash
./scripts/proactive-engine-control.sh main status
```

### 生成报告

```bash
./scripts/proactive-engine-control.sh main report
```

### 停止引擎

```bash
./scripts/proactive-engine-control.sh main stop
```

---

## 📊 功能详解

### 1. 自动监控

```yaml
监控指标:
  session_metrics:
    - 数量 (每5分钟)
    - 总大小
    - 最大文件大小

  performance_metrics:
    - 响应时间
    - 错误率
    - 使用频率

  resource_metrics:
    - 工作区大小
    - node_modules大小
    - 磁盘使用
```

### 2. 主动发现

```yaml
触发条件:
  session_count > 15:
    触发: "建议清理session"
    理由: "保持高性能"

  response_time > 10s:
    触发: "建议优化"
    理由: "响应慢影响体验"

  workspace_size > 100MB:
    触发: "建议清理"
    理由: "工作区过大"
```

### 3. 主动分析

```yaml
分析内容:
  趋势分析:
    - Session数量趋势
    - 性能变化趋势
    - 使用模式变化

  瓶颈分析:
    - 性能瓶颈
    - 资源瓶颈
    - 流程瓶颈

  模式识别:
    - 重复查询
    - 高频任务
    - 优化机会
```

### 4. 主动建议

```yaml
建议类型:
  性能优化:
    - 清理session
    - 压缩上下文
    - 调整配置

  成本优化:
    - 使用缓存
    - 添加知识库
    - 优化查询

  效率提升:
    - 自动化任务
    - 创建快捷方式
    - 优化工作流
```

---

## 💡 使用场景

### 场景1: 日常监控

```
主动性引擎在后台运行 (每5分钟检查一次)

发现: Session增加到18个
触发: 主动提醒
建议: "清理session以保持性能"

你:
├─ 收到提醒
├─ 查看详情
├─ 决定执行
└─ 性能恢复
```

### 场景2: 周期性分析

```
每周自动生成分析报告

报告内容:
├─ 本周性能趋势
├─ 发现的问题
├─ 优化建议
└─ 执行方案

你:
├─ 查看报告
├─ 选择建议
├─ 执行优化
└─ Agent持续优化
```

### 场景3: 异常检测

```
监控到异常: 响应时间突然增加

主动性引擎:
├─ 立即检测
├─ 分析原因
├─ 通知你
└─ 提出解决方案

你:
├─ 立即发现问题
├─ 快速修复
└─ 减少影响
```

---

## 📈 预期效果

### 短期 (1周)

```
✅ 主动监控: 每5分钟检查
✅ 主动发现: 自动识别问题
✅ 主动提醒: 及时通知
```

### 中期 (1月)

```
✅ 主动分析: 每周生成报告
✅ 主动建议: 优化建议
✅ 持续监控: 7×24运行
```

### 长期 (3月+)

```
✅ 自我进化: 持续优化
✅ 主动性增强: 越用越智能
✅ 性能提升: 显著改善
```

---

## 🎯 核心价值

### 1. 主动性

```
不是: 你问，它答
而是: 它主动发现问题

例如:
🔔 "检测到性能下降，已分析原因"
🔔 "发现优化机会，可提升30%"
🔔 "建议执行以下优化..."
```

### 2. 智能化

```
不是: 简单告警
而是: 深度分析

例如:
📊 "本周session增加50%，但查询量只增加20%"
📊 "说明session积累快于使用，建议清理"
📊 "预计清理后性能提升40%"
```

### 3. 实用性

```
不是: 空泛建议
而是: 可执行方案

例如:
🎯 "执行这3个命令可提升30%:"
    1. ~/clawd/scripts/agent-rejuvenate.sh main
    2. rm -rf ~/clawd/node_modules
    3. openclaw gateway restart
```

---

## 🔧 工作原理

### 架构图

```
┌─────────────────────────────────────────┐
│         主动性引擎                       │
│  (Proactive Engine)                      │
│                                         │
│  ┌────────┐    ┌────────┐    ┌──────┐│
│  │监控    │ → │分析    │ → │建议  ││
│  │        │    │        │    │      ││
│  └────────┘    └────────┘    └──────┘│
│      ↓            ↓            ↓      │
└─────────────────────────────────────────┘
         │            │            │
         ↓            ↓            ↓
    ┌────────────────────────────────┐
    │  MOSS Agent (main)             │
    │  - 监控对象                   │
    │  - 不被修改                   │
    └────────────────────────────────┘
```

### 执行流程

```
1. 监控 (只读)
   └─ 读取session数量
   └─ 记录性能指标

2. 分析 (只读)
   └─ 分析数据
   └─ 发现模式

3. 建议 (只建议)
   └─ 生成建议
   └─ 等待决定

4. 执行 (你决定)
   └─ 你同意后才执行
   └─ 不自动修改Agent
```

---

## ⚙️ 高级功能

### 自定义监控阈值

```yaml
配置文件: ~/clawd/config/proactive-engine.yaml

alerts:
  session_count:
    warning: 15
    critical: 20
    action: "suggest_cleanup"

  response_time:
    warning: 10s
    critical: 30s
    action: "suggest_optimization"
```

### 自定义分析周期

```yaml
monitoring:
  interval: 300  # 5分钟
  analysis: daily  # 每天分析
  report: weekly  # 每周报告
```

### 自定义通知方式

```yaml
notifications:
  terminal:
    enabled: true
    show_alerts: true

  log_file:
    enabled: true
    path: ~/clawd/proactive-data/alerts.log
```

---

## 🎓 使用技巧

### 技巧1: 定期查看报告

```bash
# 每周查看一次
./scripts/proactive-engine-control.sh main report
```

### 技巧2: 根据建议执行优化

```bash
# 报告建议清理session
./scripts/agent-rejuvenate.sh main

# 再次查看报告
./scripts/proactive-engine-control.sh main report
```

### 技巧3: 长期运行观察

```bash
# 启动后持续运行
./scripts/proactive-engine-control.sh main start

# 忘要时查看状态
./scripts/proactive-engine-control.sh main status

# 不需要时停止
./scripts/proactive-engine-control.sh main stop
```

---

## 🛠️ 故障排除

### 问题1: 引擎未运行

**检查**:
```bash
./scripts/proactive-engine-control.sh main status
```

**解决**:
```bash
./scripts/proactive-engine-control.sh main start
```

### 问题2: 未生成报告

**检查**:
```bash
# 查看是否有数据
ls -l ~/clawd/proactive-data/metrics.jsonl

# 应该看到一些数据点
```

**解决**:
```bash
# 手动收集一次数据
cd ~/clawd
python3 -c "
import json
from pathlib import Path
from datetime import datetime
sessions = list(Path('.openclaw/agents/main/sessions/*.jsonl'))
metrics = {
    'timestamp': datetime.now().isoformat(),
    'agent_id': 'main',
    'session_count': len(sessions)
}
(Path('proactive-data/metrics.jsonl').write_text(json.dumps(metrics))
"
```

### 问题3: 建议不准确

**可能原因**:
- 数据点太少
- 运行时间太短

**解决**:
- 让引擎运行更长时间
- 收集更多数据点

---

## 📚 相关文档

1. **proactive-engine-architecture.md** - 架构设计文档
2. **proactive-engine.py** - 核心实现
3. **proactive-engine-control.sh** - 控制脚本

---

## ✅ 总结

### 核心要点

1. ✅ **MOSS不变**
   - 身份不变
   - 配置不变
   - 工作方式不变

2. ✅ **只监控和建议**
   - 不修改MOSS
   - 只提供建议
   - 你决定执行

3. ✅ **主动性**
   - 主动发现问题
   - 主动分析
   - 主动建议

4. ✅ **持续进化**
   - 监控→分析→建议→执行
   - 持续循环
   - 越用越智能

### 立即开始

```bash
# 启动主动性引擎
cd ~/clawd
./scripts/proactive-engine-control.sh main start

# 查看状态
./scripts/proactive-engine-control.sh main status

# 生成报告
./scripts/proactive-engine-control.sh main report
```

---

**创建时间**: 2026-02-09
**状态**: ✅ 已完成并可用
**下一步**: 启动主动性引擎，体验主动监控

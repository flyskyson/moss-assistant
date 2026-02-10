# OpenClaw Agent 性能诊断完整指南

**日期**: 2026-02-09
**目标**: 诊断和解决 MOSS 性能问题

---

## 🔍 调研结果总结

### 官方工具情况

**❌ OpenClaw 官方没有专门的性能诊断工具**

**✅ 但有相关的性能优化指南**:
- [OpenClaw Slow Inference 指南](https://openclaw-ai.org/guides/fix-openclaw-slow-inference)
- [OpenClaw 性能问题讨论](https://www.answeroverflow.com/m/1468960661324173424)
- [阿里云 OpenClaw FAQ](https://help.aliyun.com/zh/simple-application-server/use-cases/openclaw-faq)

### 常见性能问题

根据官方文档和社区反馈，主要问题有：

```
1. Session 积累
   ├─ 正常: 10个以内
   ├─ 注意: 10-20个
   └─ 严重: 20+个 ← 你的情况 (33个)

2. 数据库膨胀
   ├─ 正常: < 100MB
   ├─ 注意: 100-500MB
   └─ 严重: > 500MB

3. 系统资源
   ├─ CPU 使用率 > 80%
   ├─ 内存使用率 > 80%
   └─ 热节流 (笔记本电脑)

4. 网络问题
   ├─ Gateway 未启动
   ├─ 端口被占用
   └─ 网络延迟
```

---

## 🚀 立即诊断你的 MOSS

### 方法1: 使用专用诊断脚本 ⭐⭐⭐⭐⭐

```bash
cd ~/clawd

# 运行完整诊断
./scripts/agent-diagnostic.sh main

# 查看报告
cat ~/clawd/diagnostics/diagnostic-*.md | tail -100
```

**会检查**:
- ✅ Session 数量和大小
- ✅ 数据库大小
- ✅ CPU/内存使用
- ✅ 网络连接状态
- ✅ 性能趋势分析
- ✅ 个性化优化建议

**输出示例**:
```
╔════════════════════════════════════════════════════════════╗
║  OpenClaw Agent 性能诊断工具                                     ║
╚════════════════════════════════════════════════════════════╝

📊 1. Session 分析
  Session数量: 33
  总大小: 6.8MB
  状态: 🚨 严重
  建议: Session数量过多！这是性能问题的主要原因

🗄️  2. 数据库分析
  数据库大小: 250MB
  状态: ⚠️ 较大
  建议: 数据库较大，建议设置 retention_days

💻 3. 系统资源分析
  OpenClaw CPU使用: 45%
  OpenClaw 内存使用: 62%

💡 5. 性能优化建议
🚨 紧急建议: 清理旧session
  执行命令: ~/clawd/scripts/agent-rejuvenate.sh main
```

---

### 方法2: 使用主动性引擎

```bash
cd ~/clawd

# 查看性能报告
./scripts/proactive-engine-control.sh main report

# 查看运行状态
./scripts/proactive-engine-control.sh main status
```

**优势**:
- 持续监控
- 趋势分析
- 自动发现问题

---

## 🛠️ 性能优化方案

### 方案1: 清理 Session（紧急）⚠️

```bash
cd ~/clawd

# 执行清理
./scripts/agent-rejuvenate.sh main

# 验证效果
ls -l ~/.openclaw/agents/main/sessions/ | wc -l
```

**预期效果**:
```
清理前: 33 sessions (6.8MB)
清理后: 10 sessions (1.7MB)
性能提升: 响应时间从 170秒 → 2秒
```

---

### 方案2: 配置 retention_days（重要）

```bash
# 1. 编辑配置
nano ~/.openclaw/agents/main/config.yaml

# 2. 添加以下配置
retention_days: 7  # 只保留7天数据

# 3. 重启 Gateway
openclaw daemon restart
```

**效果**:
- 自动清理旧数据
- 防止数据库膨胀
- 持续保持良好性能

---

### 方案3: 智能老化防护（推荐）

```bash
cd ~/clawd

# 安装智能老化防护
./scripts/setup-intelligent-rejuvenation.sh install

# 查看状态
./scripts/setup-intelligent-rejuvenation.sh status
```

**特点**:
- 每周自动维护
- 智能决策清理时机
- 完全自动化

---

### 方案4: 配置主动性引擎（长期）

```bash
cd ~/clawd

# 启动主动性引擎
./scripts/proactive-engine-control.sh main start

# 配置自动启动
./scripts/proactive-engine-auto-install.sh install
```

**效果**:
- 每5分钟自动监控
- 主动发现性能问题
- 提供优化建议

---

## 📋 完整工作流程

### 第一次诊断

```bash
# 1. 运行诊断
cd ~/clawd
./scripts/agent-diagnostic.sh main

# 2. 查看报告
cat ~/clawd/diagnostics/diagnostic-*.md

# 3. 执行紧急优化（如果需要）
./scripts/agent-rejuvenate.sh main

# 4. 配置长期优化
./scripts/setup-intelligent-rejuvenation.sh install
./scripts/proactive-engine-auto-install.sh install
```

### 日常监控

```bash
# 查看主动性引擎报告
./scripts/proactive-engine-control.sh main report

# 或重新诊断
./scripts/agent-diagnostic.sh main
```

---

## 🎯 预期效果

### 短期（立即）

```
清理 Session:
├─ Session: 33 → 10 (↓ 70%)
├─ 大小: 6.8MB → 1.7MB (↓ 75%)
└─ 响应: 明显改善
```

### 中期（1周）

```
配置 retention_days:
├─ 自动清理旧数据
├─ 防止数据库膨胀
└─ 性能稳定
```

### 长期（持续）

```
主动性引擎:
├─ 持续监控
├─ 主动发现问题
├─ 智能老化防护
└─ 持续优化
```

---

## 📚 相关资源

### 官方文档

1. **[OpenClaw Slow Inference 指南](https://openclaw-ai.org/guides/fix-openclaw-slow-inference)** - 性能问题官方指南
2. **[OpenClaw 性能问题讨论](https://www.answeroverflow.com/m/1468960661324173424)** - 社区讨论
3. **[阿里云 OpenClaw FAQ](https://help.aliyun.com/zh/simple-application-server/use-cases/openclaw-faq)** - 常见问题

### 本地工具

1. **[scripts/agent-diagnostic.sh](../scripts/agent-diagnostic.sh)** - 性能诊断工具
2. **[scripts/agent-rejuvenate.sh](../scripts/agent-rejuvenate.sh)** - Session 清理工具
3. **[scripts/setup-intelligent-rejuvenation.sh](../scripts/setup-intelligent-rejuvenate.sh)** - 智能老化防护
4. **[scripts/proactive-engine-control.sh](../scripts/proactive-engine-control.sh)** - 主动性引擎控制

---

## 🚀 立即开始

### 快速诊断（3步）

```bash
# 1. 诊断问题
cd ~/clawd
./scripts/agent-diagnostic.sh main

# 2. 清理 session（如果需要）
./scripts/agent-rejuvenate.sh main

# 3. 配置自动化
./scripts/setup-intelligent-rejuvenate.sh install
```

### 验证效果

```bash
# 重新诊断
./scripts/agent-diagnostic.sh main

# 查看对比
# Session: 33 → 10 ✅
# 性能: 明显改善 ✅
```

---

## 💡 核心要点

1. ✅ **官方没有专门的诊断工具**，但有相关指南
2. ✅ **主要问题是 Session 积累**（33个 → 严重）
3. ✅ **立即清理 Session** 可以快速改善性能
4. ✅ **配置 retention_days** 防止再次膨胀
5. ✅ **主动性引擎** 持续监控和优化

---

**现在就诊断你的 MOSS**:
```bash
cd ~/clawd
./scripts/agent-diagnostic.sh main
```

**Sources**:
- [OpenClaw Slow Inference Guide](https://openclaw-ai.org/guides/fix-openclaw-slow-inference)
- [OpenClaw Performance Discussion](https://www.answeroverflow.com/m/1468960661324173424)
- [阿里云 OpenClaw FAQ](https://help.aliyun.com/zh/simple-application-server/use-cases/openclaw-faq)
- [Why Your AI Agent Is Slow](https://medium.com/@Micheal-Lanham/why-your-ai-agent-is-so-slow-and-how-to-fix-it)

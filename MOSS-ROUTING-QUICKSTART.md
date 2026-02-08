# 🚀 MOSS 智能路由系统 - 快速入门

**更新日期**：2026-02-08
**版本**：v1.0

---

## ⚡ 5 分钟了解路由系统

### 什么是智能路由？

**简单说**：MOSS 现在会自动根据任务选择最合适的模型，不需要手动判断。

**举个例子**：
- **之前**：编辑 IDENTITY.md → 用 Gemini Flash → 卡住 30 分钟
- **现在**：路由器推荐 MiniMax M2.1 → 1 分钟完成

---

## 📋 MOSS 可用的 3 个模型

### 1. MiniMax M2.1（主力）⭐
- **成本**：$0.28/$1.00
- **适合**：文件编辑、中文内容
- **性能**：72.5% SWE-Bench

### 2. MiMo-V2-Flash（免费）🆓
- **成本**：FREE
- **适合**：简单查询
- **性能**：匹配 Claude Sonnet 4.5

### 3. DeepSeek V3.2（备用）
- **成本**：$0.25/$0.38
- **适合**：通用任务、回退
- **性能**：GPT-4o 的 97.5%

---

## 🎯 如何使用

### 方式 1：获取路由建议（推荐）

```bash
python3 scripts/agent-router-integration.py MOSS <file_path>
```

**示例**：
```bash
# 分析 IDENTITY.md
python3 scripts/agent-router-integration.py MOSS IDENTITY.md

# 输出：
# ✓ Recommended Model: minimax-m2.1
#   Confidence: 99%
#   Reason: MOSS 专长：核心配置文件需要最高可靠性
```

### 方式 2：使用智能脚本

```bash
./scripts/moss-smart-route.sh edit <file>
```

---

## 💡 关键规则

### ✅ 必须用 MiniMax M2.1
- 核心配置文件（IDENTITY.md, USER.md, SOUL.md）
- 包含中文的文件
- 包含 emoji 的文件
- 超过 50 行的文件

### ✅ 可以用免费模型
- 简单英文查询
- 纯信息查询
- 测试和实验

### ❌ 不要用 Gemini Flash
- 中文文件编辑（会卡死 30+ 分钟）
- 大文件编辑
- 复杂格式文件

---

## 📊 成本对比

| 场景 | 之前 | 现在 | 节省 |
|------|------|------|------|
| 月成本 | $22-31 | $2 | **91%** ⚡ |

---

## 🔧 常用命令

```bash
# 测试路由
python3 scripts/agent-router-integration.py MOSS IDENTITY.md

# 运行演示
python3 scripts/demo-routing-system.py

# 查看日志
tail -f /Users/lijian/clawd/logs/moss-routing.log
```

---

## 📚 详细文档

- [完整集成指南](docs/agent-router-integration-guide.md)
- [快速测试指南](docs/quick-routing-test.md)
- [完成报告](docs/integration-complete-final.md)
- [今日工作记录](memory/2026-02-08.md)

---

## ✅ 快速验证

运行这个命令验证路由系统工作：

```bash
python3 scripts/agent-router-integration.py MOSS IDENTITY.md
```

**预期输出**：
```
✓ Recommended Model: minimax-m2.1
  Confidence: 99%
  Reason: MOSS 专长：核心配置文件需要最高可靠性
```

看到这个 = 路由系统正常工作！🎉

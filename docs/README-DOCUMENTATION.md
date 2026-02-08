# MOSS 文档使用指南

## 📚 文档分类说明

### 🟢 核心配置文档（MOSS 必读）

这些文档 **MOSS 每次会话都会读取**，是 MOSS 的"大脑"：

| 文件 | MOSS 读取时机 | 重要性 | 说明 |
|------|-------------|--------|------|
| **SOUL.md** | 每次会话开始 | ⭐⭐⭐ | MOSS 的性格、原则 |
| **USER.md** | 每次会话开始 | ⭐⭐⭐ | 你的信息、偏好 |
| **AGENTS.md** | 每次会话开始 | ⭐⭐⭐ | 工具、规则、行为 |
| **MEMORY.md** | 主会话 | ⭐⭐ | 长期记忆 |
| **memory/YYYY-MM-DD.md** | 每次会话 | ⭐⭐ | 最近的上下文 |

**位置**：`/Users/lijian/clawd/` 根目录

**不要移动**这些文件！

---

### 🔵 辅助文档（可选，MOSS 不自动读）

这些是操作指南、总结、记录文档：

| 文件 | 用途 | MOSS 是否读 |
|------|------|-----------|
| **IDENTITY.md** | 身份定义 | ⚠️ 可选 |
| **TOOLS.md** | 工具配置 | ✅ 可能参考 |
| **HEARTBEAT.md** | 心跳检查清单 | ✅ 定期检查 |
| **BOOTSTRAP.md** | 初始化指南 | ❌ 已删除 |

---

### 🟡 总结文档（给你看的）

这些是我创建的**操作记录和总结**，**MOSS 不会自动读**：

| 文件 | 说明 | 建议 |
|------|------|------|
| **SUCCESS-TAVILY-WORKING.md** | Tavily 配置成功总结 | 移到 `docs/` |
| **FINAL-MOSS-TAVILY-FIX.md** | 最终修复方案 | 移到 `docs/` |
| **SESSION-CACHE-ISSUE.md** | 会话问题诊断 | 移到 `docs/` |
| **MOSS-CAPABILITIES-SUMMARY.md** | 能力总结 | 移到 `docs/` |
| **WEB-SEARCH-FIX-SUMMARY.md** | 搜索修复记录 | 移到 `docs/` |
| **OPENCLAW-AGENT-TRAINING-GUIDE.md** | 训练指南 | 移到 `docs/` 或保留 |

---

### 🔧 工具脚本（给你用的）

| 脚本 | 用途 | 运行方式 |
|------|------|---------|
| **fix-moss-cache.sh** | 修复缓存 | `./fix-moss-cache.sh` |
| **force-moss-read-config.sh** | 强制刷新配置 | `./force-moss-read-config.sh` |
| **test-search-moss.sh** | 测试搜索 | `./test-search-moss.sh` |

---

## 🎯 推荐的文件组织

### 方案 1：创建 docs 目录（推荐）

```bash
# 创建文档目录
mkdir -p /Users/lijian/clawd/docs

# 移动总结文档
mv SUCCESS-TAVILY-WORKING.md docs/
mv FINAL-MOSS-TAVILY-FIX.md docs/
mv SESSION-CACHE-ISSUE.md docs/
mv MOSS-CAPABILITIES-SUMMARY.md docs/
mv WEB-SEARCH-FIX-SUMMARY.md docs/
mv OPENCLAW-AGENT-TRAINING-GUIDE.md docs/  # 可选

# 移动脚本
mkdir -p /Users/lijian/clawd/scripts
mv *.sh scripts/

# 结果
/Users/lijian/clawd/
├── SOUL.md          # MOSS 必读
├── USER.md          # MOSS 必读
├── AGENTS.md        # MOSS 必读
├── MEMORY.md        # MOSS 必读
├── TOOLS.md         # MOSS 参考
├── docs/            # 总结文档
└── scripts/         # 工具脚本
```

### 方案 2：保持现状（简单）

如果不介意文件多，保持现状也可以：
- ✅ MOSS 知道哪些该读（AGENTS.md 定义）
- ✅ 其他文档不影响功能
- ⚠️ 但根目录会比较乱

---

## 📖 如何让 MOSS 读取其他文档

### 方法 1：在 AGENTS.md 中添加

如果你想 MOSS 读取某个文档，**在 AGENTS.md 中添加**：

```markdown
## Every Session

Before doing anything else:
1. Read `SOUL.md`
2. Read `USER.md`
3. Read `IMPORTANT-NOTES.md`  # 添加这一行
4. Read `memory/YYYY-MM-DD.md`
```

### 方法 2：直接告诉 MOSS

在对话中说：

```
"请读取 docs/PROJECT-PLAN.md 文件，
然后告诉我里面的内容。"
```

### 方法 3：添加到 MEMORY.md

如果文档很重要，摘录到 MEMORY.md：

```markdown
## 重要文档

- Tavily 配置成功（2026-02-06）
- 使用方法：./skills/tavily-search/search.js
```

---

## 🎯 我的建议

### 立即行动

**保持简洁**：

```bash
# 1. 创建 docs 目录
mkdir -p docs scripts

# 2. 移动总结文档
mv *-SUMMARY.md docs/ 2>/dev/null
mv *-FIX.md docs/ 2>/dev/null
mv SUCCESS-*.md docs/ 2>/dev/null
mv FINAL-*.md docs/ 2>/dev/null

# 3. 移动脚本
mv *.sh scripts/ 2>/dev/null

# 4. 创建 README
echo "文档已整理到 docs/ 目录" > README-DOCS.md
```

### 保留在根目录

**这些文件**（MOSS 真正用的）：

```
/Users/lijian/clawd/
├── SOUL.md                      # ✅ 保留
├── USER.md                      # ✅ 保留
├── AGENTS.md                    # ✅ 保留
├── MEMORY.md                    # ✅ 保留
├── TOOLS.md                     # ✅ 保留
├── HEARTBEAT.md                 # ✅ 保留
├── memory/                      # ✅ 保留目录
├── skills/                      # ✅ 保留目录
├── docs/                        # 📁 新建
└── scripts/                     # 📁 新建
```

---

## 💡 关键理解

### MOSS 读取文档的规则

**只在 AGENTS.md 中列出的文档会被自动读取**：

```markdown
## Every Session
Before doing anything else:
1. Read `SOUL.md`        # ✅ 自动读
2. Read `USER.md`        # ✅ 自动读
3. Read `AGENTS.md`      # ✅ 自动读（自己）
4. Read `memory/...`     # ✅ 自动读
```

**其他文档需要**：
- 直接告诉 MOSS："读取 XXX.md"
- 或者添加到上面的列表

### 文档优先级

1. **核心配置**（5 个）：MOSS 的"大脑"
   - SOUL.md, USER.md, AGENTS.md, MEMORY.md, memory/

2. **辅助文档**：参考信息
   - TOOLS.md, HEARTBEAT.md, IDENTITY.md

3. **总结文档**：给你的记录
   - SUCCESS-*.md, FINAL-*.md, *-SUMMARY.md

---

## ✅ 快速整理脚本

我帮你创建一个整理脚本：

```bash
#!/bin/bash
echo "整理 MOSS 文档..."

# 创建目录
mkdir -p docs scripts

# 移动总结文档
mv *-SUMMARY.md docs/ 2>/dev/null
mv *-FIX.md docs/ 2>/dev/null
mv SUCCESS-*.md docs/ 2>/dev/null
mv FINAL-*.md docs/ 2>/dev/null
mv *-GUIDE.md docs/ 2>/dev/null
mv *-PLAN.md docs/ 2>/dev/null
mv *-REPORT.md docs/ 2>/dev/null

# 移动脚本
mv *.sh scripts/ 2>/dev/null

echo "✅ 整理完成！"
echo ""
echo "根目录保留："
echo "  - SOUL.md, USER.md, AGENTS.md（MOSS 必读）"
echo "  - MEMORY.md, TOOLS.md（重要）"
echo ""
echo "总结文档：docs/"
echo "工具脚本：scripts/"
```

---

## 📊 总结

| 文档类型 | MOSS 读？ | 位置 | 建议 |
|---------|----------|------|------|
| **核心配置（5 个）** | ✅ 每次会话 | 根目录 | **绝对保留** |
| **辅助文档** | ⚠️ 可能 | 根目录 | 按需保留 |
| **总结文档** | ❌ 不读 | 移到 docs/ | 归档保存 |
| **脚本** | ❌ 不读 | 移到 scripts/ | 工具使用 |

---

**需要我帮你执行整理吗？** 🚀

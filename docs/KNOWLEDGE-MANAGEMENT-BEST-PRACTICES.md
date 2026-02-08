# OpenClaw 知识管理最佳实践

根据 OpenClaw 官方文档和社区经验，总结以下最佳实践。

---

## 📚 参考来源

- [Memory - OpenClaw 官方文档](https://docs.openclaw.ai/concepts/memory)
- [Deep Dive: How OpenClaw's Memory System Works](https://snowan.gitbook.io/study-notes/ai-blogs/openclaw-memory-system-deep-dive)
- [How OpenClaw memory works and how to control it](https://lumadock.com/tutorials/openclaw-memory-explained)
- [Agentic AI: OpenClaw's Memory Architecture Explained](https://medium.com/@shivam.agarwal.in/agentic-ai-openclaw-moltbot-clawdbots-memory-architecture-explained-61c3b9697488)
- [Clawdbot's Memory Architecture & Pre-Compaction](https://medium.com/aimonks/clawdbots-memory-architecture-pre-compaction-flush-the-engineering-reality-behind-never-c8ff84a4a11a)

---

## 🎯 核心原则

### 1. File-First（文件优先）
**"Files are the source of truth"**
- 使用纯 Markdown 文件
- 人类可读、可编辑
- Git 友好

### 2. Search-First（搜索优先）
- 不加载所有内容
- 只检索相关片段
- 节省 Token

### 3. 分层管理
- 核心配置（5 个文件）
- 项目知识
- 归档

---

## 🗂️ 推荐的文件组织

### 方案 A：PARA 方法（社区推荐）

```
~/clawd/
├── Projects/          # 活跃项目
│   ├── OPENCLAW-UPGRADE/
│   └── ENTERPRISE-WECHAT/
├── Areas/             # 持续领域
│   ├── AI学习/
│   ├── 技术文档/
│   └── 健康管理/
├── Resources/          # 参考资料
│   ├── API文档/
│   └── 工具手册/
├── Archives/           # 已完成
│   └── 旧项目/
├── docs/              # 总结文档
├── scripts/           # 工具脚本
└── index.md          # 导航
```

### 方案 B：三层结构（官方风格）

```
~/clawd/
├── 🎯 核心三文件
│   ├── SOUL.md
│   ├── USER.md
│   └── AGENTS.md
│
├── 🧠 记忆系统
│   ├── MEMORY.md
│   └── memory/YYYY-MM-DD.md
│
├── 📁 知识库
│   ├── projects/     # 活跃项目
│   ├── areas/        # 持续领域
│   └── references/   # 参考资料
│
└── 📋 维护文档
    ├── docs/         # 归档总结
    └── scripts/      # 工具脚本
```

---

## 📝 每日/每周维护流程

### 每日（自动）

MOSS 自动写入 `memory/YYYY-MM-DD.md`：
- 对话摘要
- 重要决策
- 随手笔记

### 每周（手动或通过心跳）

**从每日笔记提炼到 MEMORY.md**：

1. 打开 `memory/本周最后一个文件`
2. 识别重要内容
3. 更新 `MEMORY.md`
4. 删除过时信息

**命令**（让 MOSS 执行）：

```markdown
## 心跳任务

每周五晚上：
1. 读取 memory/本周所有文件
2. 提取重要内容到 MEMORY.md
3. 删除 memory/7天前的旧文件
4. 更新本周学习进度
```

---

## 🎯 处理文档增长的方法

### 方法 1：归档（推荐）

**何时归档**：
- ✅ 项目已完成
- ✅ 文档超过 30 天未访问
- ✅ 信息已过时

**归档到**：
```bash
~/clawd/archives/2026-02/
├── completed-projects/
├── old-docs/
└── deprecated/
```

### 方法 2：定期清理

**每季度做一次**：

1. 删除重复文档
2. 合并相似内容
3. 压缩旧聊天记录
4. 更新索引（index.md）

### 方法 3：索引优先

**创建 index.md**：

```markdown
# 知识库索引

## 🎯 快速导航

- [核心配置](#核心配置)
- [项目知识](#项目知识)
- [归档文档](#归档)

## 核心配置

- [SOUL.md](SOUL.md) - MOSS 性格
- [USER.md](USER.md) - 用户信息
- [AGENTS.md](AGENTS.md) - 行为规则

## 项目知识

### 活跃项目
- [OPENCLAW-UPGRADE](projects/OPENCLAW-UPGRADE/)
- [ENTERPRISE-WECHAT](projects/ENTERPRISE-WECHAT/)

### 技术领域
- [AI学习](areas/AI学习/)
- [工具文档](areas/工具文档/)

## 归档

查看 [archives/](archives/) 目录
```

---

## 💡 关键建议

### DO ✅

1. **保持根目录简洁**
   - 只保留核心 5 个文件
   - 其他内容移到子目录

2. **使用 PARA 系统组织**
   - Projects（项目）
   - Areas（领域）
   - Resources（资源）
   - Archives（归档）

3. **定期维护**
   - 每周提炼 MEMORY.md
   - 每月归档旧项目
   - 每季度清理

4. **创建索引**
   - index.md 作为导航
   - 每个项目有 README.md

### DON'T ❌

1. **不要创建太多顶层文件**
   - 根目录文件 > 15 个会混乱

2. **不要重复内容**
   - 同一信息只存一个地方

3. **不要忽视每日笔记**
   - memory/YYYY-MM-DD.md 很重要

4. **不要让 MEMORY.md 过大**
   - 只保留精华
   - 详情在每日笔记中

---

## 🔧 实施步骤

### 第 1 步：整理现有文档

```bash
# 创建目录结构
mkdir -p projects areas resources archives docs scripts

# 移动项目文档
mv *-PLAN.md projects/ 2>/dev/null
mv *-MIGRATION.md projects/ 2>/dev/null

# 移动技术文档
mv OPENCLAW-*.md areas/技术文档/ 2>/dev/null

# 移动总结文档
mv *-SUMMARY.md docs/ 2>/dev/null
mv *-FIX.md docs/ 2>/dev/null
mv SUCCESS-*.md docs/ 2>/dev/null
mv FINAL-*.md docs/ 2>/dev/null

# 移动脚本
mv *.sh scripts/ 2>/dev/null

echo "✅ 整理完成"
```

### 第 2 步：创建索引

创建 `index.md`（上面有示例）

### 第 3 步：更新 AGENTS.md

在 AGENTS.md 中添加索引说明：

```markdown
## Every Session

Before doing anything else:
1. Read `SOUL.md`
2. Read `USER.md`
3. Read `index.md`  # 添加这一行
4. Read `memory/YYYY-MM-DD.md`
```

---

## 📊 效果对比

### 整理前
```
~/clawd/ (20+ 文件)
├── SOUL.md
├── USER.md
├── AGENTS.md
├── SUCCESS-TAVILY-WORKING.md
├── FINAL-MOSS-TAVILY-FIX.md
├── SESSION-CACHE-ISSUE.md
├── ... (混乱)
```

### 整理后
```
~/clawd/ (清晰)
├── SOUL.md              # 核心配置
├── USER.md              # 核心配置
├── AGENTS.md            # 核心配置
├── MEMORY.md            # 长期记忆
├── index.md             # 导航
├── projects/           # 项目知识
├── areas/              # 领域知识
├── resources/          # 参考资料
├── docs/               # 归档
├── scripts/            # 工具
└── memory/             # 每日笔记
```

---

## 🎯 总结

**OpenClaw 官方和社区的最佳实践**：

1. ✅ **File-First**：纯 Markdown 文件
2. ✅ **PARA 系统**：Projects/Areas/Resources/Archives
3. ✅ **分层管理**：核心配置 / 项目知识 / 归档
4. ✅ **定期维护**：每周提炼 MEMORY.md
5. ✅ **索引优先**：index.md 导航
6. ✅ **Search-First**：按需检索，不全部加载

**你的下一步**：

1. 执行上面的整理脚本
2. 创建 index.md
3. 建立每周维护习惯

---

**更新时间**：2026-02-06
**参考**：OpenClaw 官方文档 + 社区最佳实践

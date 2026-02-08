# OpenClaw 心跳任务设计方案

**日期**: 2026-02-06
**目的**: 定期维护 PARA 知识库结构
**频率**: 每周自动执行

---

## 🎯 设计目标

### 主要功能
1. **自动检查知识库结构** - 确保文件在正确的 PARA 位置
2. **定期维护提醒** - 提示清理和整理任务
3. **索引自动更新** - 保持 index.md 准确
4. **记忆提取** - 提醒提取重要内容到 MEMORY.md

### 为什么需要心跳任务

**当前问题**:
- ❌ 文件可能放错位置（根目录 vs projects/areas/）
- ❌ 旧文档没有及时归档
- ❌ index.md 可能过时
- ❌ MEMORY.md 长期不更新

**心跳任务解决**:
- ✅ 每周自动检查和提醒
- ✅ MOSS 主动提示维护任务
- ✅ 自动化重复性工作

---

## 📋 任务设计

### 任务 1: 知识库结构检查（每周五晚上）

**执行时间**: 每周五 20:00
**执行者**: MOSS

**检查项目**:

```markdown
1. 检查根目录是否有应该分类的文件
   - 列出 ~/clawd/*.md 文件
   - 识别哪些应该移到 projects/areas/docs/scripts/

2. 检查 projects/ 中的项目状态
   - 读取每个项目文件
   - 识别已完成的项目（状态标记）
   - 提示是否移到 archives/

3. 检查 docs/ 目录
   - 列出 30 天未更新的文件
   - 提示是否删除或归档

4. 验证 index.md 准确性
   - 对比 index.md 和实际文件
   - 标记缺失的文件
   - 标记已删除的文件
```

**输出格式**:
```markdown
## 📊 知识库周报 - 2026-02-06

### 🔍 结构检查
✅ PARA 结构正常
⚠️  发现 2 个文件需要整理

### 📁 文件整理建议
1. `README-DOCUMENTATION.md` → 建议移到 `docs/`
2. `fix-moss-file-confusion.md` → 建议移到 `docs/` 或删除

### 🎯 项目状态更新
- ✅ 无已完成项目

### 📝 索引更新
- ✅ index.md 与实际文件一致

### ✅ 行动建议
1. 整理 2 个根目录文件
2. 继续保持当前结构
```

---

### 任务 2: 记忆提取（每周五晚上）

**执行时间**: 每周五 20:30（任务 1 之后）
**执行者**: MOSS

**执行步骤**:

```markdown
1. 读取本周的每日笔记
   - memory/2026-02-03.md 到 memory/2026-02-06.md

2. 提取重要内容
   - 重要决策和结论
   - 技术问题和解决方案
   - 配置更改
   - 工作流程改进

3. 更新 MEMORY.md
   - 添加新内容
   - 删除过时信息
   - 整理和分类

4. 清理旧笔记
   - 提取完成后，删除或压缩旧笔记
```

**输出格式**:
```markdown
## 🧠 记忆提取周报 - 2026-02-06

### ✅ 已提取内容
- Tavily 配置成功
- PARA 结构实施
- Ollama 自动启动

### 📝 MEMORY.md 更新
- 新增: 网络搜索配置章节
- 更新: 知识管理最佳实践

### 🗑️ 旧笔记清理
- 已提取: 7 天的每日笔记
- 建议: 删除 memory/2026-02-03.md 到 2026-02-05.md
```

---

### 任务 3: 系统健康检查（每天早上）

**执行时间**: 每天早上 6:00
**执行者**: MOSS

**检查项目**:

```markdown
1. 服务状态
   - Ollama 是否运行
   - Gateway 是否运行

2. 磁盘空间
   - 检查 ~/clawd/ 大小
   - 警告如果 > 1GB

3. 错误日志
   - 检查 /tmp/ollama.err
   - 检查 /tmp/openclaw/*.log
```

**输出格式**:
```markdown
## 🏥 系统健康检查 - 2026-02-06 06:00

✅ 所有服务正常
✅ 磁盘空间充足 (256MB)
✅ 无错误日志
```

---

## 🔧 实现方案

### 方案 A: 使用 OpenClaw Cron（推荐）

**配置文件**: `/Users/lijian/.openclaw/cron/jobs.json`

```json
{
  "jobs": [
    {
      "id": "weekly-knowledge-check",
      "name": "知识库周检",
      "schedule": "0 20 * * 5",
      "enabled": true,
      "agent": "main",
      "message": "请执行知识库周检任务。检查 ~/clawd/ 根目录文件、projects/ 项目状态、docs/ 旧文件，并生成周报。"
    },
    {
      "id": "weekly-memory-extraction",
      "name": "记忆提取",
      "schedule": "30 20 * * 5",
      "enabled": true,
      "agent": "main",
      "message": "请执行记忆提取任务。读取本周每日笔记，提取重要内容到 MEMORY.md，并生成报告。"
    },
    {
      "id": "daily-health-check",
      "name": "系统健康检查",
      "schedule": "0 6 * * *",
      "enabled": true,
      "agent": "main",
      "message": "请检查系统状态。运行 check-system-status.sh，并报告任何问题。"
    }
  ]
}
```

**优点**:
- ✅ OpenClaw 原生支持
- ✅ MOSS 自动执行
- ✅ 可以输出到会话或文件

**缺点**:
- ⚠️ 需要 OpenClaw Gateway 始终运行
- ⚠️ 时间可能不准确（依赖 Gateway 运行）

---

### 方案 B: 使用 macOS LaunchAgent + 脚本

**创建脚本**: `/Users/lijian/clawd/scripts/weekly-knowledge-check.sh`

```bash
#!/bin/bash
# 知识库周检脚本

DATE=$(date +%Y-%m-%d)
REPORT="$WORKSPACE/docs/kb-weekly-$DATE.md"

# 运行系统状态检查
./scripts/check-system-status.sh

# 生成报告
cat > "$REPORT" << EOF
## 📊 知识库周报 - $DATE

### 🔍 结构检查
...

### ✅ 行动建议
...
EOF

echo "周报已生成: $REPORT"
```

**配置 LaunchAgent**: `~/Library/LaunchAgents/com.openclaw.weekly.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.weekly</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/lijian/clawd/scripts/weekly-knowledge-check.sh</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>5</integer>
        <key>Hour</key>
        <integer>20</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>/tmp/weekly-check.log</string>
</dict>
</plist>
```

**优点**:
- ✅ 系统级定时任务，可靠
- ✅ 不依赖 Gateway 运行
- ✅ 可以记录日志

**缺点**:
- ⚠️ MOSS 不直接参与
- ⚠️ 需要手动整合到 MOSS 工作流

---

### 方案 C: 混合方案（最佳）

**周检任务**: LaunchAgent + 脚本
**记忆提取**: OpenClaw Cron + MOSS
**健康检查**: LaunchAgent + 脚本

**理由**:
- 系统检查用脚本（快速、可靠）
- 知识提取用 MOSS（需要理解和总结）
- 最佳性能和智能平衡

---

## 🎯 推荐实施步骤

### 第一步: 创建周检脚本（1 小时）

```bash
# 创建脚本
vi ~/clawd/scripts/weekly-knowledge-check.sh

# 添加执行权限
chmod +x ~/clawd/scripts/weekly-knowledge-check.sh

# 测试运行
./scripts/weekly-knowledge-check.sh
```

### 第二步: 配置 LaunchAgent（30 分钟）

```bash
# 创建 plist 文件
vi ~/Library/LaunchAgents/com.openclaw.weekly.plist

# 加载任务
launchctl load ~/Library/LaunchAgents/com.openclaw.weekly.plist

# 验证
launchctl list | grep openclaw
```

### 第三步: 测试和调整（1 小时）

```bash
# 手动触发测试
launchctl start com.openclaw.weekly

# 检查日志
cat /tmp/weekly-check.log

# 调整脚本
vi ~/clawd/scripts/weekly-knowledge-check.sh
```

### 第四步: 创建 MOSS 记忆提取任务（1 小时）

```bash
# 编辑 OpenClaw cron 配置
vi ~/.openclaw/cron/jobs.json

# 重启 Gateway
openclaw gateway restart
```

---

## 📊 预期效果

### 自动化维护

**每周五晚上 20:00**:
```
[系统] 自动运行周检脚本
[输出] docs/kb-weekly-2026-02-06.md
[内容] 文件整理建议、项目状态、索引更新
```

**每周五晚上 20:30**:
```
[MOSS] 自动执行记忆提取
[输出] MEMORY.md 更新
[报告] docs/memory-extract-2026-02-06.md
```

**每天早上 6:00**:
```
[系统] 健康检查
[输出] 简短状态报告
[异常] 如果有问题，立即通知
```

### 人工审核

**每周六早上**:
```
1. 查看周报: docs/kb-weekly-YYYY-MM-DD.md
2. 执行建议的整理操作
3. 验证 MEMORY.md 更新
4. 检查系统状态
```

---

## 🤔 待讨论问题

1. **你希望心跳任务多智能？**
   - A. 完全自动，MOSS 自主决定
   - B. 半自动，生成建议让你决定
   - C. 纯提醒，手动执行

2. **频率偏好？**
   - A. 每周一次（推荐）
   - B. 每月一次
   - C. 按需执行

3. **你更喜欢哪个方案？**
   - A. OpenClaw Cron（MOSS 执行）
   - B. LaunchAgent（系统执行）
   - C. 混合方案（推荐）

---

## 📝 下一步行动

**需要你决定**:
1. 是否实施心跳任务？
2. 选择哪个实施方案（A/B/C）？
3. 是否需要调整任务内容？

**准备就绪后**:
- 创建必要的脚本
- 配置定时任务
- 测试和验证

---

*设计方案版本: v1.0*
*预计实施时间: 2-3 小时*
*维护成本: 每周 10 分钟审核*

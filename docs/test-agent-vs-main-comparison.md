# test-agent vs main Agent 对比分析

**对比日期**: 2026-02-09
**目的**: 明确差异、影响、替代方案

---

## 📊 核心差异对比

| 维度 | main Agent | test-agent | 差异说明 |
|------|-----------|-----------|----------|
| **响应速度** | 137-304秒 | **8秒** | test-agent快17-38倍 ⚡ |
| **工作区** | ~/clawd | ~/clawd-test | 不同目录 |
| **MD文件数量** | 14个 | 6个 | main多8个文件 |
| **模型** | DeepSeek V3.2 | DeepSeek V3.2 | 相同 ✅ |
| **Agent状态** | 历史积累 | 全新干净 | test-agent无历史包袱 |
| **Session数量** | 40个 | 1个 | main有大量历史会话 |

---

## 📁 工作区文件差异

### main有但test-agent没有的文件（8个）

| 文件 | 大小 | 作用 | 缺失影响 |
|------|------|------|----------|
| **MEMORY.md** | 10KB | 记忆系统 | ⚠️  **无法访问长期记忆** |
| **TASKS.md** | 9.1KB | 任务管理 | ⚠️  **无法查看任务列表** |
| **index.md** | 11KB | 项目索引 | ⚠️  **无法快速查找内容** |
| **README.md** | 5.9KB | 项目说明 | ⚠️  **无法了解项目背景** |
| **EXPERIENCE.md** | - | 经验记录 | ⚠️  **无法学习历史经验** |
| **MOSS-ROUTING-QUICKSTART.md** | 2.6KB | 路由快速指南 | ⚠️  **不常用** |
| **OpenClaw-DeepSeek配置方案(1).md** | 6.3KB | 配置方案 | ⚠️  **历史文档** |
| **test-multi-agent-doc.md** | 1.5KB | 测试文档 | ⚠️  **无关紧要** |

### 两个Agent都有的文件（6个）

| 文件 | 作用 | 状态 |
|------|------|------|
| IDENTITY.md | Agent身份定义 | ✅ 都有 |
| SOUL.md | 灵魂/性格 | ✅ 都有 |
| USER.md | 用户信息 | ✅ 都有 |
| AGENTS.md | Agent说明 | ✅ 都有 |
| TOOLS.md | 工具列表 | ✅ 都有 |
| HEARTBEAT.md | 状态记录 | ✅ 都有 |

---

## ⚡ 使用test-agent的效果

### 正面效果 ✅

1. **响应速度大幅提升**
   - 从2-5分钟 → 8秒
   - 用户体验从"无法忍受" → "流畅"

2. **稳定性提升**
   - 无历史会话累积
   - 无配置冲突
   - 无性能退化

3. **简洁高效**
   - 工作区干净
   - 加载更快
   - 维护简单

### 负面影响 ⚠️

1. **无法访问长期记忆**
   - MEMORY.md不在工作区
   - 无法回忆历史对话
   - 每次对话都是"新的开始"

2. **无法查看任务列表**
   - TASKS.md不在工作区
   - 不知道待办事项
   - 无法跟进项目进度

3. **无法使用项目知识**
   - 缺少项目背景文档
   - 无法参考历史经验
   - 无法快速查找信息

---

## 🔄 替代方案

### 方案A: 完全切换到test-agent（简单但不推荐）

**操作**:
```bash
# 日常使用test-agent
openclaw agent --agent test-agent --message "你的问题"

# 设置为默认（修改配置）
openclaw config set agents.defaults.workspace "/Users/lijian/clawd-test"
```

**效果**:
- ✅ 快速响应（8秒）
- ❌ 失去长期记忆
- ❌ 无法访问任务列表
- ❌ 无法访问项目知识

**适用场景**: 简单问答、技术问题、不需要上下文的任务

---

### 方案B: 同步核心文件到test-agent（推荐）

**操作**:
```bash
# 复制关键文件到test-agent工作区
cp ~/clawd/MEMORY.md ~/clawd-test/
cp ~/clawd/TASKS.md ~/clawd-test/
cp ~/clawd/index.md ~/clawd-test/

# 或者创建符号链接（更优）
ln -s ~/clawd/MEMORY.md ~/clawd-test/MEMORY.md
ln -s ~/clawd/TASKS.md ~/clawd-test/TASKS.md
ln -s ~/clawd/index.md ~/clawd-test/index.md
```

**效果**:
- ✅ 快速响应（8秒）
- ✅ 保留长期记忆
- ✅ 保留任务列表
- ✅ 保留项目知识
- ⚠️  需要手动同步更新

**适用场景**: **推荐日常使用**

---

### 方案C: 优化main Agent（长期方案）

**操作**:
1. 清理main的工作区
2. 移除不必要的文件
3. 清理历史session
4. 定期维护

**效果**:
- ✅ 保留所有功能
- ✅ 逐步优化性能
- ⚠️  需要时间
- ⚠️  可能仍比test-agent慢

**适用场景**: 长期优化目标

---

### 方案D: 混合使用（灵活但复杂）

**操作**:
- 日常快速任务 → test-agent
- 需要上下文的任务 → main
- 创建别名简化使用

```bash
# 在 ~/.zshrc 中添加别名
alias moss-fast="openclaw agent --agent test-agent --message"
alias moss-full="openclaw agent --agent main --message"
```

**效果**:
- ✅ 根据需求选择
- ✅ 灵活性高
- ❌ 需要记住何时用哪个
- ❌ 增加复杂度

---

## 📋 功能影响评估

| 功能类别 | main | test-agent | 影响 |
|---------|------|-----------|------|
| **基础对话** | ✅ 慢 | ✅ 快 | 无影响，test-agent更好 |
| **技术问题** | ✅ 慢 | ✅ 快 | 无影响，test-agent更好 |
| **访问记忆** | ✅ 慢 | ❌ 无 | ⚠️  需要同步MEMORY.md |
| **查看任务** | ✅ 慢 | ❌ 无 | ⚠️  需要同步TASKS.md |
| **项目知识** | ✅ 慢 | ❌ 无 | ⚠️  需要同步相关文档 |
| **文件操作** | ✅ 慢 | ✅ 快 | 无影响，test-agent更好 |
| **代码执行** | ✅ 慢 | ✅ 快 | 无影响，test-agent更好 |
| **多Agent协作** | ✅ 慢 | ✅ 快 | 无影响，test-agent更好 |

---

## 🎯 推荐方案

### 短期（今天）：方案B - 同步核心文件

**步骤**:
1. 复制MEMORY.md、TASKS.md、index.md到test-agent
2. 测试test-agent是否正常工作
3. 日常使用test-agent
4. 必要时使用main查看完整项目

**预期效果**:
- ⚡ 响应速度提升17-38倍
- ✅ 保留核心功能
- ✅ 可以访问记忆和任务

### 中期（本周）：清理main Agent

**步骤**:
1. 清理main的历史session
2. 移除不必要的文档
3. 观察性能改善

### 长期（本月）：建立双Agent系统

**方案**:
- **test-agent (快速模式)**: 日常使用
- **main (完整模式)**: 需要完整上下文时使用
- 自动化同步机制确保数据一致

---

## ⚠️ 重要提醒

### test-agent的限制

1. **无法自动更新**
   - 如果修改MEMORY.md（在main），test-agent看不到
   - 需要手动同步

2. **无历史会话**
   - 每次都是"新对话"
   - 无法延续之前的上下文

3. **工作区隔离**
   - 无法访问~/clawd中的文件
   - 除非显式复制或链接

### 建议的使用策略

```bash
# 1. 日常快速对话（90%的情况）
openclaw agent --agent test-agent --message "问题"

# 2. 需要访问记忆或任务（10%的情况）
openclaw agent --agent main --message "问题"

# 3. 定期同步（每天一次）
cp ~/clawd/MEMORY.md ~/clawd-test/
cp ~/clawd/TASKS.md ~/clawd-test/
```

---

## 📝 实施检查清单

- [ ] 备份test-agent当前状态
- [ ] 复制MEMORY.md到test-agent
- [ ] 复制TASKS.md到test-agent
- [ ] 复制index.md到test-agent
- [ ] 测试test-agent功能
- [ ] 创建使用别名
- [ ] 建立同步机制
- [ ] 监控使用效果

---

## 🔗 相关文档

- [Agent性能测试总结](final-test-summary.md)
- [根本原因分析](root-cause-analysis-final.md)
- [安全审计报告](../reports/security-audit-2026-02-09-final.md)

---

**结论**: **推荐方案B** - 同步核心文件到test-agent，既获得快速响应，又保留核心功能。

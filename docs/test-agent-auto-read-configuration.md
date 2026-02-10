# test-agent 自动读取配置记录

**配置日期**: 2026-02-09
**配置方案**: 方案2 - 修改IDENTITY.md添加自动读取
**状态**: ✅ 已完成

---

## 📋 配置内容

### 1. 创建的符号链接

```bash
~/clawd-test/MEMORY.md -> ~/clawd/MEMORY.md
~/clawd-test/TASKS.md -> ~/clawd/TASKS.md
```

**优点**:
- 不占用额外空间
- 主工作区更新时test-agent自动看到
- 两个Agent共享同一文件

### 2. 修改的IDENTITY.md

**位置**: ~/clawd-test/IDENTITY.md
**新增内容**: 自动读取指令章节

**关键指令**:
```
每次对话开始时，你必须执行以下步骤：
1. 读取MEMORY.md - 获取飞天的长期记忆和我们的历史
2. 读取TASKS.md - 查看当前的待办任务和项目进度
3. 基于这些信息回答问题 - 结合记忆和任务来回应
```

---

## 🎯 预期效果

### 使用test-agent时

**场景1: 普通对话**
```bash
openclaw agent --agent test-agent --message "你好"
```
- **响应时间**: ~8秒
- **是否读取MEMORY/TASKS**: 否（不需要）

**场景2: 查询记忆**
```bash
openclaw agent --agent test-agent --message "我们的核心约定是什么？"
```
- **响应时间**: ~10-15秒
- **是否读取MEMORY**: 是（Agent根据IDENTITY.md指令自动读取）

**场景3: 查看任务**
```bash
openclaw agent --agent test-agent --message "当前有哪些待办任务？"
```
- **响应时间**: ~10-15秒
- **是否读取TASKS**: 是（Agent根据IDENTITY.md指令自动读取）

---

## 📊 性能对比

| 场景 | main Agent | test-agent（方案2） | 改善 |
|------|-----------|---------------------|------|
| 普通对话 | 137-304秒 | 8秒 | ⚡ 17-38倍 |
| 查询记忆 | 137-304秒 | 10-15秒 | ⚡ 10-20倍 |
| 查看任务 | 137-304秒 | 10-15秒 | ⚡ 10-20倍 |

---

## 🔧 使用方法

### 日常使用

```bash
# 大多数情况，直接使用即可
openclaw agent --agent test-agent --message "你的问题"

# Agent会根据IDENTITY.md的指令判断是否需要读取MEMORY/TASKS
```

### 明确提示读取（如果Agent没有自动读取）

```bash
# 如果Agent没有自动读取，可以明确提示
openclaw agent --agent test-agent --message "请先读取MEMORY.md，然后..."

# 或者
openclaw agent --agent test-agent --message "根据MEMORY.md和TASKS.md，告诉我..."
```

---

## ⚠️ 注意事项

### 1. 响应时间变化

- **不读取MEMORY/TASKS**: 8秒（快速）
- **读取MEMORY/TASKS**: 10-15秒（稍慢但可接受）

**原因**: 每次读取需要额外时间加载文件内容

### 2. 内存同步

- **符号链接**: 主工作区更新时test-agent自动看到
- **实时性**: 总是最新内容
- **无冗余**: 不占用额外空间

### 3. IDENTITY.md修改

**备份位置**: ~/clawd-test/IDENTITY.md.backup
**如需回滚**:
```bash
cp ~/clawd-test/IDENTITY.md.backup ~/clawd-test/IDENTITY.md
```

---

## 🧪 测试脚本

**位置**: ~/clawd/scripts/test-auto-read.sh

**运行测试**:
```bash
~/clawd/scripts/test-auto-read.sh
```

**测试内容**:
1. 普通问题（8秒响应）
2. 查询记忆（10-15秒响应）
3. 查看任务（10-15秒响应）

---

## 📝 配置检查清单

- [x] 创建符号链接（MEMORY.md, TASKS.md）
- [x] 备份原IDENTITY.md
- [x] 修改IDENTITY.md添加自动读取指令
- [x] 创建测试脚本
- [x] 文档化配置

---

## 🔄 后续维护

### 定期检查

**每周**:
- 验证符号链接是否正常
- 运行测试脚本确认功能
- 检查响应时间是否正常

**如果符号链接损坏**:
```bash
# 重新创建符号链接
ln -sf ~/clawd/MEMORY.md ~/clawd-test/MEMORY.md
ln -sf ~/clawd/TASKS.md ~/clawd-test/TASKS.md
```

### 优化建议

**如果觉得每次都慢**:
- 移除IDENTITY.md中的自动读取指令
- 改为按需明确提示

**如果希望总是自动读取**:
- 保持当前配置
- 接受额外的2-3秒延迟

---

## 📚 相关文档

- [test-agent vs main对比](test-agent-vs-main-comparison.md)
- [Agent加载机制说明](openclaw-identity-loading-mechanism.md)
- [性能测试总结](final-test-summary.md)

---

**配置完成时间**: 2026-02-09 15:05
**下次检查建议**: 2026-02-16（一周后）
**状态**: ✅ 生产就绪

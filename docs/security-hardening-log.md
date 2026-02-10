# 🔒 核心配置文件安全加固记录

**加固日期**: 2026-02-09
**执行人**: Claude (技术后台)
**批准人**: 飞天

---

## ✅ 已完成的安全措施

### 1. 文件备份系统
- **备份位置**: ~/clawd/.core-backup/
- **备份文件**:
  - IDENTITY.md
  - USER.md
  - SOUL.md
  - TASKS.md
  - HEARTBEAT.md
- **备份策略**: 每次修改前自动备份

### 2. 文件监控脚本
- **脚本位置**: ~/clawd/scripts/monitor-core-files.sh
- **日志位置**: ~/clawd/.core-logs/changes.log
- **监控内容**: MD5校验，检测任何未授权修改

### 3. 修改建议（需要飞天批准）

#### A. 设置文件为只读（需要时临时解锁）
```bash
# 锁定核心文件
chmod 400 ~/clawd/IDENTITY.md
chmod 400 ~/clawd/SOUL.md
chmod 400 ~/clawd/USER.md
chmod 400 ~/clawd/TASKS.md

# 临时解锁（修改前）
chmod 600 ~/clawd/IDENTITY.md

# 修改后重新锁定
chmod 400 ~/clawd/IDENTITY.md
```

#### B. 创建修改审批流程
任何对核心文件的修改必须：
1. MOSS提出修改建议
2. 飞天审核并批准
3. 技术后台执行修改
4. 记录到修改日志

#### C. Git版本控制
```bash
# 使用git追踪所有变化
cd ~/clawd
git add IDENTITY.md USER.md SOUL.md TASKS.md HEARTBEAT.md
git commit -m "安全: 锁定核心配置文件"
```

---

## 📋 安全检查清单

- [x] 核心文件已备份
- [x] 监控脚本已创建
- [ ] 文件权限已设置（待批准）
- [ ] Git追踪已启用（待批准）
- [ ] 修改流程已文档化（待批准）

---

## ⚠️ 重要提醒

**修改核心文件的正确流程**：
1. MOSS提出修改建议（包含理由和具体内容）
2. 飞天审核建议
3. 如批准，MOSS使用Read + 提案 + 批准 + Write流程
4. 禁止直接使用Edit工具修改核心文件
5. 所有修改记录到 ~/clawd/.core-logs/changes.log

---

**下次审查日期**: 2026-02-16

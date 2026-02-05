# Memory 系统升级影响分析

## 📊 当前 Memory 状态

### 数据存储位置
```
数据库: ~/.clawdbot/memory/main.sqlite (3.2 MB)
配置:   ~/.clawdbot/clawdbot.json (memorySearch 部分)
源文件: ~/clawd/MEMORY.md
       ~/clawd/memory/*.md
```

### 当前 Memory 统计
- **已索引文件**: 4 个文件
- **数据块**: 4 chunks
- **模型**: nomic-embed-text (本地 Ollama)
- **向量维度**: 768
- **Embedding 缓存**: 4 条记录
- **状态**: ✅ 运行正常

### 已索引的文件
```
/Users/lijian/clawd/MEMORY.md
/Users/lijian/clawd/memory/2024-06-14.md
/Users/lijian/clawd/memory/2026-02-05.md
/Users/lijian/clawd/memory/MEMORY_RESTORE.md
```

### 数据库结构
```
主要表:
- chunks: 存储文本块和嵌入向量
- files: 跟踪已索引文件
- embedding_cache: 嵌入向量缓存
- chunks_vec: 向量搜索表（768 维）
- chunks_fts: 全文搜索索引
```

---

## ⚠️ 升级影响分析

### ❌ 自动迁移：不完整

**重要发现**: OpenClaw 的 `openclaw upgrade` 或 `onboard` 命令**会迁移配置文件**，但**不会自动迁移 Memory 数据库**。

这意味着：

1. ✅ **配置会迁移**: `clawdbot.json` → `openclaw.json`
2. ✅ **源文件保留**: `~/clawd/MEMORY.md` 等文件不会丢失
3. ❌ **数据库需重建**: `memory/main.sqlite` 不会自动迁移
4. ❌ **索引需重新生成**: 升级后需要重新索引

---

## 🔧 升级步骤（Memory 保护方案）

### 方案 1: 完整备份 + 手动迁移（推荐）

#### 步骤 1: 备份当前 Memory 数据

```bash
# 创建备份目录
mkdir -p ~/clawd/backups/memory-pre-upgrade

# 备份 Memory 数据库
cp ~/.clawdbot/memory/main.sqlite ~/clawd/backups/memory-pre-upgrade/

# 备份配置文件
cp ~/.clawdbot/clawdbot.json ~/clawd/backups/memory-pre-upgrade/

# 备份源文件
cp -r ~/clawd/memory ~/clawd/backups/memory-pre-upgrade/

# 验证备份
ls -lah ~/clawd/backups/memory-pre-upgrade/
```

#### 步骤 2: 安装 OpenClaw

```bash
# 安装最新版本
npm install -g openclaw@latest

# 验证安装
openclaw --version
```

#### 步骤 3: 运行升级向导

```bash
# 运行升级（会迁移配置）
openclaw upgrade
```

此命令会：
- 创建 `~/.openclaw/` 目录
- 迁移 `clawdbot.json` → `openclaw.json`
- **保留 `~/.clawdbot/` 目录**

#### 步骤 4: 验证 Memory 配置

检查配置是否正确迁移：

```bash
# 查看新配置
cat ~/.openclaw/openclaw.json | grep -A 10 memorySearch
```

确认包含以下内容：

```json
"memorySearch": {
  "provider": "openai",
  "model": "nomic-embed-text",
  "remote": {
    "baseUrl": "http://localhost:11434/v1",
    "apiKey": "ollama"
  }
}
```

#### 步骤 5: 重新索引 Memory（重要！）

```bash
# 确保网关运行
openclaw gateway start

# 重新索引 Memory 文件
openclaw memory index --verbose --force

# 验证索引状态
openclaw memory status --deep
```

#### 步骤 6: 测试 Memory 功能

发送测试消息验证 Memory 是否正常工作：

```bash
# 通过命令行测试
openclaw message send \
  --target YOUR_TELEGRAM_ID \
  --message "测试：我之前记录了什么？"
```

或通过 Telegram/WhatsApp 发送消息测试记忆检索。

---

### 方案 2: 手动复制数据库（可选，不推荐）

如果你想保留原始的 embedding 向量，可以手动复制数据库：

```bash
# 停止所有服务
clawdbot gateway stop

# 安装 OpenClaw
npm install -g openclaw@latest

# 创建新目录结构
mkdir -p ~/.openclaw/memory

# 复制数据库（实验性）
cp ~/.clawdbot/memory/main.sqlite ~/.openclaw/memory/

# 复制配置
cp ~/.clawdbot/clawdbot.json ~/.openclaw/openclaw.json

# 运行向导更新配置
openclaw onboard

# 验证
openclaw memory status --deep
```

⚠️ **警告**: 手动复制数据库可能因版本不兼容导致问题。建议使用方案 1（重新索引）。

---

## 🔄 Memory 配置验证

### 升级后检查清单

```bash
# 1. 检查配置文件
cat ~/.openclaw/openclaw.json | jq .agents.defaults.memorySearch

# 2. 检查数据库是否存在
ls -lah ~/.openclaw/memory/main.sqlite

# 3. 检查 Memory 状态
openclaw memory status --deep

# 4. 检查索引文件数量
openclaw memory index --verbose

# 5. 测试 Ollama 连接
curl http://localhost:11434/api/tags
```

### 预期输出

```
Memory Search (main)
Provider: openai
Model: nomic-embed-text
Sources: memory
Indexed: 4/4 files · 4 chunks
Store: ~/.openclaw/memory/main.sqlite
Embeddings: ready
Vector dims: 768
```

---

## 🛡️ 安全预防措施

### 升级前必做

1. **完整备份 Memory 数据库**
   ```bash
   cp ~/.clawdbot/memory/main.sqlite ~/clawd/backups/memory-pre-upgrade/
   ```

2. **备份配置文件**
   ```bash
   cp ~/.clawdbot/clawdbot.json ~/clawd/backups/
   ```

3. **记录当前 Memory 文件**
   ```bash
   sqlite3 ~/.clawdbot/memory/main.sqlite "SELECT path FROM files;" > ~/clawd/backups/memory-files.txt
   ```

4. **停止运行的服务**
   ```bash
   clawdbot gateway stop
   ```

### 升级后验证

1. ✅ 确认 Memory 配置存在
2. ✅ 确认 Ollama 服务运行
3. ✅ 重新索引所有 Memory 文件
4. ✅ 测试 Memory 检索功能
5. ✅ 验证向量维度正确（768）

---

## 🐛 故障排除

### 问题 1: Memory 配置丢失

**症状**: `openclaw memory status` 显示配置未找到

**解决**:
```bash
# 手动添加配置到 ~/.openclaw/openclaw.json
openclaw configure

# 或编辑文件添加 memorySearch 配置
vim ~/.openclaw/openclaw.json
```

### 问题 2: 重新索引失败

**症状**: `openclaw memory index` 报错

**解决**:
```bash
# 检查 Ollama 服务
ollama list

# 确认模型已下载
ollama pull nomic-embed-text

# 重试索引
openclaw memory index --verbose --force
```

### 问题 3: 向量维度不匹配

**症状**: 错误提示维度不匹配

**解决**:
```bash
# 删除旧数据库重新索引
rm ~/.openclaw/memory/main.sqlite
openclaw memory index --force
```

### 问题 4: 备份恢复

如果升级失败需要恢复：

```bash
# 停止 OpenClaw
openclaw gateway stop

# 卸载 OpenClaw
npm uninstall -g openclaw

# 恢复旧版本（如果需要）
npm install -g clawdbot@2026.1.24-3

# 恢复数据库
cp ~/clawd/backups/memory-pre-upgrade/main.sqlite ~/.clawdbot/memory/

# 重启服务
clawdbot gateway start
```

---

## 📊 数据对比

### 升级前 vs 升级后

| 项目 | 升级前 | 升级后 | 说明 |
|------|--------|--------|------|
| 配置目录 | `~/.clawdbot/` | `~/.openclaw/` | 新目录 |
| 配置文件 | `clawdbot.json` | `openclaw.json` | 自动迁移 |
| 数据库 | `~/.clawdbot/memory/` | `~/.openclaw/memory/` | 需重建 |
| 源文件 | `~/clawd/MEMORY.md` | `~/clawd/MEMORY.md` | 不变 |
| 模型配置 | Ollama | Ollama | 保持不变 |
| 向量维度 | 768 | 768 | 保持不变 |

---

## ✅ 最终建议

### 推荐：方案 1（完整备份 + 重新索引）

**原因**:
1. ✅ **最安全**: 有完整备份可恢复
2. ✅ **最可靠**: 重新索引避免兼容性问题
3. ✅ **最简单**: 步骤清晰，易于执行
4. ✅ **官方支持**: 符合 OpenClaw 官方升级流程

### 时间估算
- 备份: < 1 分钟
- 安装: 2-3 分钟
- 重新索引: 1-2 分钟（仅 4 个文件）
- **总计**: 约 5-10 分钟

### 风险等级
- 🟢 **低风险**: 源文件不会丢失
- 🟡 **中风险**: 需要重新索引（约 5 分钟）
- 🔴 **无数据丢失**: 所有 Memory 文件都保存在 `~/clawd/memory/`

---

## 🎯 快速升级命令（复制粘贴）

```bash
# === 步骤 1: 备份 ===
mkdir -p ~/clawd/backups/memory-pre-upgrade
cp ~/.clawdbot/memory/main.sqlite ~/clawd/backups/memory-pre-upgrade/
cp ~/.clawdbot/clawdbot.json ~/clawd/backups/memory-pre-upgrade/
echo "✅ 备份完成"

# === 步骤 2: 安装 OpenClaw ===
npm install -g openclaw@latest
echo "✅ 安装完成"

# === 步骤 3: 升级配置 ===
openclaw upgrade
echo "✅ 配置迁移完成"

# === 步骤 4: 验证配置 ===
cat ~/.openclaw/openclaw.json | grep -A 5 memorySearch
echo "✅ 请确认上述输出包含 memorySearch 配置"

# === 步骤 5: 启动网关 ===
openclaw gateway start
sleep 5
echo "✅ 网关已启动"

# === 步骤 6: 重新索引 Memory ===
openclaw memory index --verbose --force
echo "✅ Memory 索引完成"

# === 步骤 7: 验证状态 ===
openclaw memory status --deep
echo "✅ 请确认上述输出显示 'Embeddings: ready'"
```

---

## 📝 总结

### 关键要点

1. **Memory 源文件不会丢失**
   - `~/clawd/MEMORY.md` 和 `~/clawd/memory/*.md` 完全保留

2. **需要重新索引**
   - 数据库不会自动迁移
   - 重新索引仅需 1-2 分钟

3. **配置会自动迁移**
   - `memorySearch` 配置会保留
   - Ollama 连接配置不变

4. **建议先备份**
   - 备份数据库以策安全
   - 升级失败可随时恢复

5. **升级后验证**
   - 检查 Memory 状态
   - 测试记忆检索功能

---

**文档生成时间**: 2026-02-05
**适用版本**: clawdbot 2026.1.24-3 → openclaw 2026.2.2-3
**风险等级**: 🟢 低风险（有完整备份方案）

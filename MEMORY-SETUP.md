# Clawdbot Memory 功能配置记录

## 配置目标

为 Clawdbot 配置免费的本地 Memory 记忆功能，使用 Ollama 提供的嵌入模型，避免使用付费的 OpenAI API。

## 配置信息

| 项目 | 配置 |
|------|------|
| **日期** | 2026-02-05 |
| **目标** | 使用本地 Ollama 替代 OpenAI 嵌入 API |
| **聊天模型** | DeepSeek (通过 OpenRouter) - 保持不变 |
| **嵌入模型** | nomic-embed-text (本地 Ollama) |
| **成本** | 完全免费 |

## 配置步骤

### 1. 安装 Ollama

```bash
brew install --cask ollama
```

### 2. 启动 Ollama 服务

```bash
ollama serve &
```

### 3. 下载嵌入模型

```bash
ollama pull nomic-embed-text
```

模型大小：274 MB
向量维度：768

### 4. 配置 Clawdbot

编辑文件：`/Users/lijian/.clawdbot/clawdbot.json`

在 `agents.defaults` 中添加以下配置：

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

### 5. 重启 Gateway 服务

```bash
clawdbot gateway restart
```

### 6. 验证配置

```bash
# 检查 Memory 状态
clawdbot memory status --deep

# 索引 Memory 文件
clawdbot memory index --verbose
```

## 验证结果

```
Memory Search (main)
Provider: openai (requested: openai)
Model: nomic-embed-text
Sources: memory
Indexed: 1/1 files · 1 chunks
Vector: ready
Vector dims: 768
Embedding cache: enabled (1 entries)
```

✅ 配置成功！Memory 功能正常工作。

## 技术说明

### 为什么这样配置？

1. **OpenAI 兼容模式**: Ollama 提供了 OpenAI 兼容的 HTTP API
2. **本地运行**: 所有嵌入计算在本地完成，无需 API 费用
3. **模型分离**: 聊天模型（DeepSeek）和嵌入模型（nomic-embed-text）是独立的

### 配置原理

Clawdbot 的 Memory 系统使用 `memory-core` 插件，支持通过 OpenAI 兼容端点配置自定义嵌入服务。通过设置 `memorySearch.remote.baseUrl` 指向 Ollama 的本地端点，实现了零成本的嵌入服务。

### 文件说明

- **MEMORY.md**: 长期记忆文件
- **memory/YYYY-MM-DD.md**: 每日日志文件
- **~/.clawdbot/memory/main.sqlite**: 向量索引数据库

## 常见问题

### Q: 嵌入模型会影响对话吗？
A: 不会。嵌入模型仅用于 Memory 搜索，对话仍然使用 DeepSeek 模型。

### Q: 批处理模式失败怎么办？
A: Ollama 不支持 OpenAI 的批处理 API，系统会自动回退到标准模式，这是正常现象。

### Q: 如何确认 Memory 在工作？
A: 运行 `clawdbot memory status`，看到 "Embeddings: ready" 即表示正常。

## 参考资源

- [Clawdbot Memory 官方文档](https://docs.clawd.bot/concepts/memory)
- [Clawdbot Plugin 文档](https://docs.clawd.bot/plugin)
- [Ollama 官方文档](https://ollama.com)
- [nomic-embed-text 模型页](https://ollama.com/library/nomic-embed-text)

---

**配置完成时间**: 2026-02-05
**状态**: ✅ 运行正常

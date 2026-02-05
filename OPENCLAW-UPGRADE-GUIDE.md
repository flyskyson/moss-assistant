# OpenClaw 升级与优化指南

## 📊 当前状态分析

### 本地配置
- **当前版本**: clawdbot 2026.1.24-3
- **命令名称**: clawdbot（旧名称）
- **配置位置**: ~/.clawdbot/
- **已配置功能**:
  - ✅ Memory 搜索（本地 Ollama + nomic-embed-text）
  - ✅ 多模型支持（DeepSeek、Claude Sonnet 4.5、GLM、Kimi K2）
  - ✅ 基本网关配置

### 最新版本
- **最新版本**: openclaw 2026.2.2-3
- **发布日期**: 2026-02-04
- **项目名称**: OpenClaw（从 Clawdbot/Moltbot 演变）
- **GitHub Stars**: 146K+ ⭐

---

## ⚠️ 关键安全警告

### 严重漏洞风险
**你的版本 (2026.1.24-3) 存在已知的安全漏洞！**

OpenClaw v2026.1.29 修复了一个**严重级别的远程代码执行漏洞**：
- 允许通过 token 盗取和 WebSocket 劫持实现一键远程代码执行
- CVE 级别的安全风险
- **建议立即升级到 2026.2.2-3**

---

## 🚀 OpenClaw 2026.2.2 新功能

### 1. 飞书/Lark 原生支持 🇨🇳
- **首款支持中国主流聊天客户端的 AI 平台**
- 无需插件即可连接飞书
- 支持 Lark 国际版

### 2. 性能优化 ⚡
- 通过 tsdown 迁移实现更快构建
- 编译速度显著提升
- 更流畅的用户体验

### 3. 安全强化 🔒
- 更强的安全措施
- 修复已知漏洞
- 改进认证机制

### 4. 新 Memory 插件 🧠
- 改进的 Memory 功能
- 更好的上下文保持
- 优化的向量搜索

### 5. Web UI Agents 仪表板 🖥️
- **图形化管理界面**
- 可视化管理：
  - Agent 文件
  - 工具（Tools）
  - 技能（Skills）
  - 模型（Models）
  - 渠道（Channels）
  - 定时任务（Cron）
- 减少对命令行的依赖

### 6. Telegram 改进 📱
- 共享配对存储
- 消息线程修复
- HTML 渲染改进
- 平台稳定性增强

---

## 📦 升级步骤

### 步骤 1: 安装最新版本 OpenClaw

```bash
# 使用 npm 全局安装（推荐）
npm install -g openclaw@latest

# 或使用 pnpm
pnpm add -g openclaw@latest

# 验证安装
openclaw --version
# 应显示: 2026.2.2-3
```

### 步骤 2: 运行升级向导

```bash
# OpenClaw 会自动检测旧配置并迁移
openclaw upgrade

# 或重新运行引导流程
openclaw onboard
```

**注意**: 配置文件会自动从 `~/.clawdbot/` 迁移到 `~/.openclaw/`

### 步骤 3: 检查配置

```bash
# 查看迁移后的配置
cat ~/.openclaw/openclaw.json

# 确保 Memory 配置仍然正确
openclaw memory status --deep
```

### 步骤 4: 重启服务

```bash
# 停止旧服务
clawdbot gateway stop

# 启动新服务
openclaw gateway start

# 或运行在后台
openclaw gateway &
```

### 步骤 5: 验证升级

```bash
# 检查状态
openclaw status

# 访问 Web UI
open http://127.0.0.1:18789/

# 测试 Memory 功能
openclaw memory index --verbose
```

---

## 🎯 启用全部功能

### 1. 启用飞书集成（新功能）

```bash
# 登录飞书
openclaw channels login feishu

# 按提示扫描二维码
```

### 2. 配置新的 Agents 仪表板

访问 Web UI: `http://127.0.0.1:18789/`

新增的 Agents 仪表板允许你：
- 可视化创建和管理 Agents
- 配置工具和技能
- 管理模型和渠道
- 设置定时任务

### 3. 更新 Memory 配置（如需要）

如果 Memory 功能未自动迁移，手动添加到 `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "openai",
        "model": "nomic-embed-text",
        "remote": {
          "baseUrl": "http://localhost:11434/v1",
          "apiKey": "ollama"
        }
      }
    }
  }
}
```

### 4. 启用新功能选项

考虑添加以下优化配置：

```json
{
  "agents": {
    "defaults": {
      // 启用新的 Memory 插件功能
      "memory": {
        "enabled": true,
        "maxChunks": 100
      },
      // 优化并发
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  // Web UI 优化
  "gateway": {
    "port": 18789,
    "bind": "loopback",
    "auth": {
      "mode": "token"
    }
  }
}
```

---

## 🔄 命令对照表

| 旧命令 (clawdbot) | 新命令 (openclaw) | 说明 |
|------------------|------------------|------|
| `clawdbot gateway` | `openclaw gateway` | 启动网关 |
| `clawdbot message send` | `openclaw message send` | 发送消息 |
| `clawdbot memory status` | `openclaw memory status` | Memory 状态 |
| `clawdbot channels login` | `openclaw channels login` | 登录渠道 |
| `clawdbot doctor` | `openclaw doctor` | 诊断工具 |
| `clawdbot onboard` | `openclaw onboard` | 引导向导 |

---

## 🆚 功能对比

### 你当前缺失的功能

| 功能 | 当前版本 | 最新版本 | 说明 |
|------|---------|---------|------|
| 飞书/Lark 支持 | ❌ | ✅ | 中国主流平台 |
| 安全补丁 | ❌ | ✅ | 修复 RCE 漏洞 |
| Agents 仪表板 | ❌ | ✅ | 图形化配置界面 |
| 新 Memory 插件 | ⚠️ 旧版 | ✅ 新版 | 改进版 |
| 性能优化 | ❌ | ✅ | 更快构建 |
| Telegram 改进 | ❌ | ✅ | 6项修复 |
| 命令名称 | clawdbot | openclaw | 统一品牌 |

---

## 📚 额外优化建议

### 1. 使用 OpenRouter 访问更多模型

你当前已配置 OpenRouter，可以考虑添加更多模型：

```bash
# 列出可用模型
openclaw models list

# 测试新模型
openclaw chat --model openrouter/meta-llama/llama-3.1-70b
```

### 2. 配置 Tailnet 远程访问

```bash
# 启用 Tailscale 集成
openclaw gateway --bind tailnet --token YOUR_TOKEN

# 从任何设备访问你的 Agent
```

### 3. 安装社区 Skills

```bash
# 浏览可用技能
openclaw skills browse

# 安装示例技能
openclaw skills install blogwatcher

# 列出已安装技能
openclaw skills list
```

### 4. 配置多 Agent 路由

创建不同的工作区：

```bash
# 为不同任务创建独立 Agent
openclaw agents create coder --model openrouter/deepseek/deepseek-chat
openclaw agents create writer --model openrouter/anthropic/claude-sonnet-4-5-20250929
```

---

## 🧪 升级后验证清单

- [ ] 版本确认：`openclaw --version` 显示 2026.2.2-3
- [ ] 配置迁移：`~/.openclaw/openclaw.json` 存在且包含原有配置
- [ ] Memory 功能：`openclaw memory status --deep` 显示 ready
- [ ] Web UI 访问：http://127.0.0.1:18789/ 可正常打开
- [ ] 渠道连接：Telegram 等已配置渠道正常工作
- [ ] 新功能测试：飞书登录（如需要）
- [ ] 安全更新：确认不再有已知漏洞

---

## 🐛 故障排除

### 问题 1: 配置未自动迁移
**解决方案**:
```bash
# 手动复制配置
cp ~/.clawdbot/clawdbot.json ~/.openclaw/openclaw.json
# 然后运行向导更新
openclaw onboard
```

### 问题 2: Memory 功能失效
**解决方案**:
```bash
# 重新索引 Memory
openclaw memory index --verbose --force

# 检查 Ollama 服务
curl http://localhost:11434/api/tags
```

### 问题 3: 旧命令仍然可用
**说明**: 这是正常的，npm 会保留旧包。如需卸载：
```bash
npm uninstall -g clawdbot
```

### 问题 4: Gateway 启动失败
**解决方案**:
```bash
# 检查端口占用
lsof -i :18789

# 运行诊断
openclaw doctor

# 查看日志
tail -f ~/.openclaw/logs/gateway.log
```

---

## 📖 参考资源

### 官方文档
- [OpenClaw 官方文档](https://docs.openclaw.ai/zh-CN)
- [配置参考](https://docs.openclaw.ai/zh-CN/configuration)
- [更新日志](https://github.com/openclaw/openclaw/releases)

### 社区资源
- [GitHub 仓库](https://github.com/openclaw/openclaw)
- [OpenClaw 官网](https://openclaw.ai/)
- [Reddit 社区](https://www.reddit.com/r/ThinkingDeeplyAI/comments/1qsoq4h/)

### 教程
- [DataCamp OpenClaw 教程](https://www.datacamp.com/tutorial/moltbot-clawdbot-tutorial)
- [Codecademy 安装指南](https://www.codecademy.com/article/open-claw-tutorial-installation-to-first-chat-setup)
- [Medium 完整指南](https://medium.com/modelmind/how-to-set-up-clawdbot-step-by-step-guide-to-setup-a-personal-bot-3e7957ed2975)

---

## 🎉 总结

### 升级后的优势
1. ✅ **安全性**: 修复严重远程代码执行漏洞
2. ✅ **新功能**: 飞书支持、图形化管理界面
3. ✅ **性能**: 更快构建和响应速度
4. ✅ **兼容性**: 保持与现有配置的兼容
5. ✅ **品牌**: 统一使用 OpenClaw 名称

### 建议行动
1. **立即升级** - 安全问题不容忽视
2. **测试新功能** - 尝试飞书集成和 Agents 仪表板
3. **优化配置** - 根据新功能调整配置
4. **关注更新** - OpenClaw 更新频繁，保持最新

---

**文档生成时间**: 2026-02-05
**当前建议版本**: openclaw@2026.2.2-3
**状态**: ⚠️ 需要立即升级

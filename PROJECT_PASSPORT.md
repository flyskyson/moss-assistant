# 🤖 MOSS Assistant 项目护照

> 这是给 Claude AI 的项目档案文件
> 当对话丢失后，告诉 Claude："查看 C:\Users\flyskyson\moss-assistant\PROJECT_PASSPORT.md"

---

## 📋 项目基本信息

**项目名称：** MOSS Assistant
**项目路径：** `C:\Users\flyskyson\moss-assistant`
**创建时间：** 2025-01-10
**当前版本：** 0.1.0 (MVP)
**用户：** flyskyson
**协作模式：** 长期维护，持续迭代

---

## 🎯 项目简介

MOSS Assistant 是一个**苏格拉底式辩论伙伴 + 全能个人助理**系统，具备：

### 核心特性
- ✅ **四层角色系统**：导师/伙伴/秘书/朋友
- ✅ **持久化记忆**：永远记住用户的一切
- ✅ **智能路由**：自动选择合适的角色
- ✅ **DeepSeek API**：使用 DeepSeek 大模型
- ✅ **Web 界面**：Streamlit + Python
- ✅ **Git 管理**：完整的版本控制

### 技术栈
- **后端：** Python 3.14
- **前端：** Streamlit 1.52.2
- **LLM：** DeepSeek API (OpenAI 兼容)
- **存储：** JSON (可扩展 SQLite)
- **配置：** YAML

---

## 📁 项目结构

```
moss-assistant/
├── config.yaml              # 【核心】所有配置
├── moss.py                  # 主程序
├── app.py                   # Streamlit Web UI
├── start_moss.py            # 【核心】一键启动脚本
├── requirements.txt         # 依赖包
├── .env                     # 【重要】API Key
│
├── core/                    # 核心模块
│   ├── memory.py           # 持久化记忆
│   ├── user_model.py       # 用户模型
│   └── router.py           # 角色路由
│
├── data/                    # 【重要】数据存储
│   ├── user_model.json     # 用户的数字模型
│   ├── conversations.json  # 对话历史
│   └── interactions.json   # 交互日志
│
├── docs/                    # 文档
│   ├── 维护清单.md
│   └── 开发工作流.md
│
└── .git/                    # Git 仓库
```

---

## 🚀 快速启动

### 启动命令
```bash
cd C:\Users\flyskyson\moss-assistant
python start_moss.py
```

### 访问地址
http://localhost:8501

### 停止命令
```bash
taskkill //F //IM python.exe
```

---

## 🔧 常见维护任务

### 诊断 MOSS 运行状态
```bash
# 1. 检查是否在运行
netstat -ano | findstr :8501

# 2. 查看日志
tail -100 streamlit.log

# 3. 查看数据文件
ls -lh data/
```

### 备份数据
```bash
cp -r data/ backups/data_$(date +%Y%m%d)/
```

### 查看用户模型
```bash
cat data/user_model.json | python -m json.tool
```

---

## 🎨 用户已定制的配置

### API 配置
- **提供商：** DeepSeek
- **API Key：** sk-263512fcfa5348c1ad321d98616c3f85
- **Base URL：** https://api.deepseek.com
- **模型：** deepseek-chat

### 已修复的问题
1. ✅ emoji 编码问题（Windows GBK）
2. ✅ 日志列表类型检查
3. ✅ openai 库安装
4. ✅ 环境变量加载

### 用户偏好
- 喜欢：苏格拉底式辩论
- 思考方式：第一性原理
- 数据偏好：观察 > 数据

---

## 📊 使用统计

- 对话次数：查看 `data/user_model.json` 中的 `stats.total_conversations`
- 交互次数：查看 `stats.total_interactions`
- 角色分布：查看 `stats.roles_used`

---

## 🔄 Git 历史关键提交

- `0742e98` - 集成 DeepSeek API + 修复编码问题
- `dea8838` - 项目完成总结
- `1cff503` - 快速参考卡
- `344da56` - 中文使用说明
- `31312f5` - 初始版本

---

## 💡 未来计划

### 短期（1-2 月）
- [ ] 优化角色 prompts
- [ ] 添加更多专业工具
- [ ] 改进 UI/UX

### 中期（3-6 月）
- [ ] 语义搜索
- [ ] 知识图谱
- [ ] 多模态输入

### 长期（6-12 月）
- [ ] 本地 LLM
- [ ] 多用户系统
- [ ] 云端同步

---

## 🤝 与其他系统的集成

### 工作区文件管家智能体
- **状态：** 待集成
- **需求：** MOSS 可以调用管家的功能
- **方式：** API 调用或直接导入

---

## 📞 给 Claude 的提示

### 当用户说这些话时：

**"诊断 MOSS 运行情况"**
→ 检查 `streamlit.log`，查看进程状态，报告问题

**"优化 XX 角色"**
→ 编辑 `config.yaml` 中对应角色的 `system_prompt`

**"添加 XX 功能"**
→ 评估需求，设计实现，编写代码，测试验证

**"MOSS 记忆丢失了"**
→ 检查 `data/` 目录，从备份恢复

**"集成工作区管家"**
→ 分析接口，设计集成方案

**"用 VS Code 工作区管理"**
→ 创建工作区配置，优化文件组织

---

## 🎯 关键文件路径

**必须知道的：**
- 配置：`C:\Users\flyskyson\moss-assistant\config.yaml`
- 数据：`C:\Users\flyskyson\moss-assistant\data\`
- 启动：`C:\Users\flyskyson\moss-assistant\start_moss.py`
- 日志：`C:\Users\flyskyson\moss-assistant\streamlit.log`
- 护照：`C:\Users\flyskyson\moss-assistant\PROJECT_PASSPORT.md`（本文件）

---

## 🔐 敏感信息

**已提交到 .gitignore：**
- `.env` (API Key)
- `data/` (用户数据)
- `*.log` (日志文件)

---

## 📝 维护记录

| 日期 | 操作 | 说明 |
|------|------|------|
| 2025-01-10 | 创建 | MVP 版本 |
| 2025-01-10 | 集成 DeepSeek | 替换 Claude API |
| 2025-01-10 | 修复编码 | Windows GBK 兼容 |
| 2025-01-10 | 创建护照 | 本文件 |

---

## 🎊 最后的话

**这是 MOSS 的身份证。**

无论何时，只要对话丢失，告诉 Claude：
> "查看 `C:\Users\flyskyson\moss-assistant\PROJECT_PASSPORT.md`"

Claude 就能了解：
- ✅ MOSS 是什么
- ✅ 在哪里
- ✅ 如何使用
- ✅ 如何维护
- ✅ 未来计划

**持续迭代，越来越好。🚀**

---

*最后更新：2025-01-10*

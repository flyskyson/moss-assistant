# 🤖 MOSS Assistant

> 苏格拉底式辩论伙伴 + 全能个人助理

## 📖 项目简介

MOSS Assistant 是一个 AI 个人助理，它能够：

- **理解你是谁**：持续构建你的数字孪生
- **挑战你的思考**：通过辩论理清思路
- **执行任务**：处理琐事，释放你的时间
- **记住一切**：长期记忆，每次对话自动积累

### 🎯 核心特性

1. **四层角色系统**
   - 🎓 **导师**：挑战假设，拓展思维边界
   - 🤝 **伙伴**：共同探索，平等对话
   - 📋 **秘书**：处理琐事，高效执行
   - 💚 **朋友**：情感支持，记住故事

2. **持久化记忆**
   - 每次对话自动保存
   - 下次对话自动加载
   - 永远不会忘记你

3. **第一性原理思考**
   - 不只是回答问题
   - 帮你找到根本原因
   - 共同逼近最优解

## 🚀 快速开始

### 1. 安装依赖

```bash
cd moss-assistant
pip install -r requirements.txt
```

### 2. 配置 API Key

```bash
# 设置 Claude API Key
export ANTHROPIC_API_KEY="your-api-key-here"

# Windows PowerShell
$env:ANTHROPIC_API_KEY="your-api-key-here"
```

### 3. 运行

**命令行模式：**
```bash
python moss.py
```

**Web UI 模式：**
```bash
streamlit run app.py
```

然后在浏览器打开 `http://localhost:8501`

## 📁 项目结构

```
moss-assistant/
├── config.yaml          # 配置文件（可以随时修改）
├── moss.py              # 核心程序
├── app.py               # Streamlit Web UI
├── requirements.txt     # 依赖包
├── core/                # 核心模块
│   ├── memory.py        # 持久化记忆系统
│   ├── user_model.py    # 用户模型管理
│   └── router.py        # 角色路由系统
├── prompts/             # Prompt 模板（可扩展）
├── data/                # 数据存储（自动生成）
│   ├── user_model.json
│   ├── conversations.json
│   ├── interactions.json
│   └── backups/
├── tests/               # 测试文件
└── docs/                # 文档
```

## ⚙️ 配置说明

### 修改角色行为

编辑 `config.yaml` 中的 `roles` 部分：

```yaml
roles:
  mentor:
    enabled: true
    trigger_keywords:
      - "决定"
      - "选择"
    system_prompt: |
      你的 prompt 内容...
```

### 更换存储后端

```yaml
memory:
  backend: "sqlite"  # 从 json 改为 sqlite
```

### 更换 LLM 模型

```yaml
llm:
  provider: "claude"
  model: "claude-3-5-sonnet-20241022"  # 或其他模型
```

## 💡 使用技巧

### 对话示例

**导师模式：**
```
你: 我想辞职创业
MOSS: 作为你的导师，我想先问你几个问题：
      1. 你创业的真实动机是什么？
      2. 你能承受最坏的情况吗？
      3. 你的 Plan B 是什么？
```

**伙伴模式：**
```
你: 怎么看当今的女权问题？
MOSS: 这个问题很有意思！让我们一起探索一下。
      我注意到你提到了XX，这让我想到另一个角度...
```

**秘书模式：**
```
你: 帮我写个周报
MOSS: 好的，我来帮你写周报。
      [生成周报中...]
```

**朋友模式：**
```
你: 最近感觉很迷茫
MOSS: 我能理解你现在的感受。
      如果你愿意的话，可以和我说说...
```

### 特殊命令

- `/info 姓名 张三` - 更新用户信息
- `/goal 学好 Python` - 添加目标
- `/backup` - 备份数据
- `/exit` - 退出并保存

## 🔧 进阶功能

### 1. 数据备份

所有数据存储在 `data/` 目录：
- `user_model.json` - 用户模型
- `conversations.json` - 对话历史
- `interactions.json` - 交互日志
- `backups/` - 自动备份

定期备份 `data/` 目录即可。

### 2. 接入工作区管家系统

如果你有 GitHub 仓库，可以：

1. 在仓库中创建 `moss-data/` 分支
2. 配置 Git 自动同步
3. 多设备共享用户数据

示例（未来功能）：
```bash
git checkout -b moss-data
cp -r data/ moss-data/
git add moss-data/
git commit -m "Update MOSS data"
git push origin moss-data
```

### 3. 自定义 Prompt

在 `prompts/roles/` 目录创建新的角色 prompt：

```
prompts/
├── roles/
│   ├── mentor.md
│   ├── partner.md
│   ├── secretary.md
│   ├── friend.md
│   └── custom_role.md  # 你的自定义角色
```

然后在 `config.yaml` 中引用。

## 🐛 常见问题

### Q: 忘记我是谁了？

A: 检查 `data/user_model.json` 是否存在，如果被删除了，系统会重新初始化。

### Q: API 调用失败？

A: 检查：
1. API Key 是否正确设置
2. 网络连接是否正常
3. API 额度是否充足

### Q: 如何重置记忆？

A: 删除 `data/` 目录，系统会重新初始化。

## 📈 未来计划

- [ ] 语义搜索历史对话
- [ ] 知识图谱可视化
- [ ] 多模态输入（语音、图片）
- [ ] 专业 Agent 插件系统
- [ ] 多设备同步
- [ ] 移动端 App

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**祝你使用愉快！🚀**

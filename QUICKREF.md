# 🎴 MOSS Assistant 快速参考卡

## ⚡ 30 秒启动

```bash
# 1. 安装
pip install -r requirements.txt

# 2. 设置 API Key
export ANTHROPIC_API_KEY="你的密钥"

# 3. 启动
streamlit run app.py
```

## 🎭 四种角色速查

| 角色 | 触发词 | 用途 |
|------|--------|------|
| 🎓 导师 | 决定、创业、辞职 | 重大决策时的挑战者 |
| 🤝 伙伴 | 讨论、怎么看、为什么 | 探索话题的思考者 |
| 📋 秘书 | 查、写、提醒、周报 | 处理琐事的执行者 |
| 💚 朋友 | 难过、迷茫、焦虑 | 情感支持的支持者 |

## 🔧 常用命令

| 命令 | 功能 |
|------|------|
| `/info 姓名 张三` | 更新个人信息 |
| `/goal 学好Python` | 添加新目标 |
| `/backup` | 备份数据 |
| `/exit` | 退出（命令行） |

## 📁 重要文件

| 文件 | 作用 |
|------|------|
| `config.yaml` | **核心配置**（修改角色行为） |
| `data/user_model.json` | 你的数字模型 |
| `data/conversations.json` | 对话历史 |
| `使用说明.md` | 中文快速指南 |

## 🎯 测试示例

```
导师: "我想辞职创业"
伙伴: "你怎么看女权问题？"
秘书: "帮我写个周报"
朋友: "最近感觉很迷茫"
```

## 🔄 修改配置

编辑 `config.yaml`：

```yaml
roles:
  mentor:
    trigger_keywords:
      - "决定"
      - "选择"  # 添加关键词
    system_prompt: |
      你的自定义 Prompt...
```

## 💾 数据备份

```bash
# 方式 1: 使用命令
/backup

# 方式 2: 手动备份
cp -r data/ data_backup_$(date +%Y%m%d)/

# 方式 3: Git 版本
git add data/
git commit -m "Backup MOSS data"
```

## ⚠️ 常见问题

| 问题 | 解决方案 |
|------|----------|
| ImportError | `pip install -r requirements.txt` |
| API 失败 | 检查 `ANTHROPIC_API_KEY` |
| 忘记记忆 | 检查 `data/` 目录是否存在 |
| 端口占用 | `streamlit run app.py --server.port 8502` |

## 🚀 下一步

1. **阅读文档**
   - 新手：`使用说明.md`
   - 详细：`README.md`
   - 总结：`PROJECT_SUMMARY.md`

2. **测试功能**
   ```bash
   python tests/test_basic.py
   ```

3. **自定义配置**
   - 编辑 `config.yaml`
   - 修改角色 Prompt
   - 调整触发词

4. **接入 GitHub**
   ```bash
   git remote add origin <你的仓库>
   git push -u origin master
   ```

---

**提示**：将此文件加入收藏，随时快速查阅！🔖

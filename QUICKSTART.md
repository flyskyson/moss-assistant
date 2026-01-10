# 🚀 快速开始指南

## 第一步：安装依赖

### Windows
```bash
# 双击运行
start.bat

# 或手动执行
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### Mac/Linux
```bash
# 运行启动脚本
chmod +x start.sh
./start.sh

# 或手动执行
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 第二步：设置 API Key

### Windows PowerShell
```powershell
$env:ANTHROPIC_API_KEY="your-api-key-here"
```

### Windows CMD
```cmd
set ANTHROPIC_API_KEY=your-api-key-here
```

### Mac/Linux
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

## 第三步：启动

### 方式 1：使用启动脚本（推荐）
**Windows:** 双击 `start.bat`
**Mac/Linux:** 运行 `./start.sh`

### 方式 2：手动启动

**Web UI 模式（推荐）:**
```bash
streamlit run app.py
```
然后打开浏览器访问 `http://localhost:8501`

**命令行模式:**
```bash
python moss.py
```

## 第四步：开始对话

### 示例对话

**测试导师角色：**
```
你: 我想辞职创业
```

**测试伙伴角色：**
```
你: 怎么看当今的女权问题？
```

**测试秘书角色：**
```
你: 帮我写个周报
```

**测试朋友角色：**
```
你: 最近感觉很迷茫
```

### 特殊命令

- `/info 姓名 张三` - 更新用户信息
- `/goal 学好 Python` - 添加目标
- `/backup` - 备份数据
- `/exit` - 退出并保存（命令行模式）

## 💡 提示

1. **第一次对话**：系统会加载用户模型，如果有历史记录会显示摘要
2. **角色自动切换**：根据你的输入自动选择合适的角色
3. **数据自动保存**：每次对话结束后自动保存，无需手动操作
4. **查看数据**：所有数据保存在 `data/` 目录

## 🔍 验证安装

运行以下命令检查：
```bash
python -c "import yaml, anthropic, streamlit; print('所有依赖已安装')"
```

如果显示 "所有依赖已安装"，说明安装成功！

## 🆘 遇到问题？

### 问题 1: ImportError
**解决**：重新安装依赖
```bash
pip install -r requirements.txt
```

### 问题 2: API 调用失败
**解决**：检查 API Key 是否正确设置
```bash
echo $ANTHROPIC_API_KEY  # Mac/Linux
echo %ANTHROPIC_API_KEY%  # Windows
```

### 问题 3: 端口被占用
**解决**：更换端口
```bash
streamlit run app.py --server.port 8502
```

## 📚 下一步

- 阅读 [README.md](README.md) 了解详细功能
- 编辑 `config.yaml` 自定义角色行为
- 查看 `data/` 目录了解数据存储

---

**祝你使用愉快！🎉**

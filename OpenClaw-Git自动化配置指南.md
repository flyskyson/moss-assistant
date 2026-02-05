# OpenClaw Git 自动化推送配置指南 (Windows)

## 一、已完成配置

### 1.1 Git 凭证存储
```powershell
git config --global credential.helper store
```
首次推送时输入一次用户名和密码/令牌后，后续操作无需重复输入。

### 1.2 权限配置
已更新 `settings.local.json`，添加了：
- Git 命令权限
- PowerShell 执行权限
- 目录切换权限

### 1.3 自动化脚本
创建了 `git-push.ps1` 脚本，位于：
```
C:\Users\flyskyson\.openclaw\scripts\git-push.ps1
```

---

## 二、使用方法

### 方法一：使用自动化脚本（推荐）

在 OpenClaw 中让 AI 执行：

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\flyskyson\.openclaw\scripts\git-push.ps1" -RepoPath "C:\Users\flyskyson\my_github\moss-assistant" -File "OpenClaw_Feishu_Deployment.md" -Message "[Bot] Add OpenClaw deployment doc"
```

**参数说明**：
| 参数 | 说明 | 示例 |
|------|------|------|
| `-RepoPath` | 仓库路径 | `C:\Users\flyskyson\my_github\moss-assistant` |
| `-File` | 要提交的文件 | `OpenClaw_Feishu_Deployment.md` |
| `-Message` | 提交信息 | `[Bot] Add deployment doc` |
| `-Branch` | 分支名（可选） | `main`（默认） |

---

### 方法二：PowerShell 分步执行

```powershell
# 1. 进入仓库目录
cd C:\Users\flyskyson\my_github\moss-assistant

# 2. 添加文件
git add OpenClaw_Feishu_Deployment.md

# 3. 提交
git commit -m "[Bot] Add OpenClaw deployment doc"

# 4. 推送
git push origin main
```

---

### 方法三：一行命令（PowerShell）

```powershell
cd C:\Users\flyskyson\my_github\moss-assistant; git add OpenClaw_Feishu_Deployment.md; git commit -m "[Bot] Add doc"; git push origin main
```

**注意**：PowerShell 使用 `;` 分隔命令，不是 `&&`

---

## 三、常见问题

### 3.1 认证失败
**错误**：`fatal: authentication failed`

**解决**：
1. 确保已配置 `credential.helper store`
2. 使用 GitHub Personal Access Token（推荐）或密码
3. 首次推送时会提示输入凭证

### 3.2 分支名错误
**错误**：`fatal: 'master' does not appear to be a git repository`

**解决**：检查默认分支名，GitHub 现在默认使用 `main`
```powershell
git branch
```

### 3.3 权限被拒绝
**错误**：`Permission denied`

**解决**：确保已添加 PowerShell 和 git 权限到 `settings.local.json`

---

## 四、在 OpenClaw 中使用示例

### 示例 1：提交单个文件
```
请帮我把 OpenClaw_Feishu_Deployment.md 提交到 GitHub
仓库路径：C:\Users\flyskyson\my_github\moss-assistant
```

AI 会自动调用脚本完成操作。

### 示例 2：提交所有更改
```
请帮我提交当前目录的所有更改到 GitHub
提交信息：fix bug
```

AI 会执行：
```powershell
git add .
git commit -m "fix bug"
git push origin main
```

---

## 五、GitHub Personal Access Token 配置

### 5.1 生成 Token
1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 设置权限：
   - ✅ repo (完整仓库访问权限)
4. 复制生成的 token（只显示一次）

### 5.2 配置 Git 使用 Token
```powershell
git config --global credential.helper store
git push  # 提示输入时：
# Username: your_github_username
# Password: ghp_xxxxxxxxxxxxxx (粘贴 token)
```

---

## 六、安全建议

1. **限制仓库访问**：在脚本中硬编码允许的仓库路径
2. **审查提交**：重要更改先让 AI 展示 diff，确认后再提交
3. **Token 轮换**：定期更新 GitHub Token
4. **分支保护**：在 GitHub 上设置 main 分支保护规则

---

## 七、文件位置参考

| 文件 | 路径 |
|------|------|
| Git 推送脚本 | `C:\Users\flyskyson\.openclaw\scripts\git-push.ps1` |
| 权限配置 | `C:\Users\flyskyson\.openclaw\.claude\settings.local.json` |
| 主配置 | `C:\Users\flyskyson\.openclaw\openclaw.json` |

---

**配置完成时间**：2026-02-05
**Git 版本**：2.52.0.windows.1
**OpenClaw 版本**：2026.2.2-3

# iOS 18 Mixed Content 适配指南

**更新日期**：2026-02-08
**适用范围**：钉钉小程序、H5 应用、工作台插件
**紧急程度**：🔴 高优先级

---

## 一、问题概述

### 1.1 iOS 18 安全策略变化

**核心变化**：
- iOS 18 的 WebKit 修改了安全策略
- **HTTPS 页面不能加载 HTTP 资源**（Mixed Content）
- 受影响资源类型：
  - `img` - 图片
  - `audio` / `video` - 音视频
  - `script` - JavaScript
  - `iframe` - 嵌入页面
  - `fetch` / `XMLHttpRequest` - AJAX 请求
  - CSS 样式表中的 `url()`

**官方文档**：
- [WebKit Features in Safari 18.0](https://webkit.org/blog/15865/webkit-features-in-safari-18-0/#https)
- [MDN: Mixed Content](https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content)

### 1.2 受影响场景

| 场景 | 是否受影响 | 说明 |
|------|-----------|------|
| iOS 18 Safari 浏览器 | ✅ 已受影响 | 策略已开启 |
| 钉钉小程序（H5 页面） | ⏳ 即将受影响 | 基于 Xcode 16 打包后触发 |
| 钉钉工作台插件（H5） | ⏳ 即将受影响 | 同上 |
| 微信小程序 | ✅ 已受影响 | 微信已强制 HTTPS |
| 企业微信 H5 | ⏳ 即将受影响 | 同钉钉 |

### 1.3 为什么现在还能用？

**钉钉当前状态**：
- 基于 Xcode 16 **之前**的版本打包
- iOS 18 的 Mixed Content 策略**暂未触发**
- H5 应用暂时正常运行

**未来变化**：
- 钉钉**新版本**将基于 Xcode 16 打包
- 届时**所有 HTTP 资源将被拦截**
- **必须提前适配**，避免服务中断

---

## 二、OpenClaw 项目适配检查

### 2.1 问题诊断

通过扫描发现，OpenClaw 项目中存在 **HTTP 资源**：

**主要问题**：
- Bark 推送服务器使用 HTTP：`http://8.163.19.50:8080`
- 影响 8 个文件

**详细清单**：

| 文件 | 行号 | 内容 | 优先级 |
|------|------|------|--------|
| `skills/bark-push/skill.json` | 26 | `"default": "http://8.163.19.50:8080"` | 🔴 高 |
| `skills/bark-push/bark-push.ts` | 15 | `const BARK_SERVER = 'http://8.163.19.50:8080'` | 🔴 高 |
| `skills/bark-push.ts` | 15 | 同上 | 🔴 高 |
| `skills/daily-briefing/briefing.sh` | 180 | `BARK_SERVER_URL="http://8.163.19.50:8080"` | 🔴 高 |
| `skills/bark-push/README.md` | 多处 | 文档中的示例 | 🟡 中 |

### 2.2 影响评估

**当前影响**：
- ✅ OpenClaw 后端推送功能正常
- ✅ 命令行工具不受影响
- ✅ 纯服务端场景不受影响

**潜在影响**（钉钉集成后）：
- ❌ 如果在钉钉小程序中显示推送历史
- ❌ 如果在工作台插件中查看推送状态
- ❌ 如果通过 H5 页面直接触发推送
- ❌ 所有依赖 Bark 的 H5 功能

**适配必要性**：🔴 **必须适配**
- 即使目前不受影响，为未来钉钉集成做准备
- 符合安全最佳实践
- 避免钉钉新版本上线后服务中断

---

## 三、适配方案

### 方案对比

| 方案 | 成本 | 复杂度 | 安全性 | 推荐度 |
|------|------|--------|--------|--------|
| **1. 配置 HTTPS** | 低-中 | 中 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **2. Cloudflare Tunnel** | 免费 | 低 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **3. 使用公共服务** | 免费 | 极低 | ⭐⭐⭐ | ⭐⭐ |
| **4. 暂不修改** | 无 | 无 | ⭐ | ❌ 不推荐 |

---

## 四、方案一：为 Bark 服务器配置 HTTPS

### 4.1 申请 SSL 证书

#### 免费证书（推荐）

**Let's Encrypt**（免费 90 天，自动续期）
```bash
# 安装 Certbot
brew install certbot

# 申请证书（需要先有域名）
sudo certbot certonly --standalone -d your-domain.com

# 证书位置
# /etc/letsencrypt/live/your-domain.com/fullchain.pem
# /etc/letsencrypt/live/your-domain.com/privkey.pem
```

**阿里云免费证书**（免费 3 个月）
1. 登录：https://yundun.console.aliyun.com/
2. 选择：SSL 证书 → 买证书
3. 选择：免费版 → 0 元 → 立即购买
4. 下载证书（Nginx 版本）

**腾讯云免费证书**（免费 1 年）⭐ 推荐
1. 登录：https://console.cloud.tencent.com/ssl
2. 申请：免费证书 → 填写域名信息
3. 验证：DNS 验证或文件验证
4. 下载：Nginx 格式

#### 付费证书（企业级）

**推荐**：
- DigiCert Secure Site
- GeoTrust True BusinessID
- GlobalSign

**优势**：
- 更长有效期（1-2 年）
- 更高赔付保障
- 更好的兼容性

### 4.2 配置 Nginx

#### 编辑 Nginx 配置

```bash
# SSH 到您的服务器
ssh root@8.163.19.50

# 备份现有配置
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# 编辑配置
sudo nano /etc/nginx/sites-available/bark
```

#### 配置内容

```nginx
# HTTPS 服务器配置
server {
    listen 443 ssl http2;
    server_name your-domain.com;  # 替换为您的域名

    # SSL 证书（根据您的证书路径调整）
    ssl_certificate /path/to/your/fullchain.pem;
    ssl_certificate_key /path/to/your/privkey.pem;

    # SSL 协议和加密套件（推荐配置）
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;

    # SSL 会话缓存
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # 安全头部
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;

    # 日志
    access_log /var/log/nginx/bark-access.log;
    error_log /var/log/nginx/bark-error.log;

    # Bark 服务反向代理
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持（如果需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

# HTTP 自动跳转 HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

#### 启用配置并重启

```bash
# 创建软链接启用站点
sudo ln -s /etc/nginx/sites-available/bark /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx

# 检查状态
sudo systemctl status nginx
```

### 4.3 配置防火墙

```bash
# 开放 443 端口（HTTPS）
sudo ufw allow 443/tcp

# 如果使用云厂商（阿里云/腾讯云），在控制台：
# 安全组 → 添加规则 → 443 端口 → TCP → 允许
```

### 4.4 验证 HTTPS

```bash
# 本地测试
curl -I https://your-domain.com/ping

# 检查 SSL 评级
# 访问：https://www.ssllabs.com/ssltest/analyze.html?d=your-domain.com
```

### 4.5 更新 OpenClaw 配置

#### 创建修复脚本

```bash
# 在本地 Mac 上执行
cat > ~/clawd/scripts/fix-bark-https.sh << 'EOF'
#!/bin/bash
#
# 修复 Bark 服务的 HTTP 地址为 HTTPS
#

OLD_URL="http://8.163.19.50:8080"
NEW_URL="https://your-domain.com"  # ⚠️ 替换为您的实际域名

echo "🔧 Bark HTTPS 修复工具"
echo "===================="
echo ""
echo "旧地址: $OLD_URL"
echo "新地址: $NEW_URL"
echo ""
read -p "确认开始修复？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 1
fi

echo ""
echo "🔧 正在修复文件..."

# 修复技能配置
if [ -f "$HOME/clawd/skills/bark-push/skill.json" ]; then
    sed -i '' "s|$OLD_URL|$NEW_URL|g" "$HOME/clawd/skills/bark-push/skill.json"
    echo "✅ skills/bark-push/skill.json"
fi

# 修复 TypeScript 文件
if [ -f "$HOME/clawd/skills/bark-push/bark-push.ts" ]; then
    sed -i '' "s|$OLD_URL|$NEW_URL|g" "$HOME/clawd/skills/bark-push/bark-push.ts"
    echo "✅ skills/bark-push/bark-push.ts"
fi

if [ -f "$HOME/clawd/skills/bark-push.ts" ]; then
    sed -i '' "s|$OLD_URL|$NEW_URL|g" "$HOME/clawd/skills/bark-push.ts"
    echo "✅ skills/bark-push.ts"
fi

# 修复 Shell 脚本
if [ -f "$HOME/clawd/skills/daily-briefing/briefing.sh" ]; then
    sed -i '' "s|$OLD_URL|$NEW_URL|g" "$HOME/clawd/skills/daily-briefing/briefing.sh"
    echo "✅ skills/daily-briefing/briefing.sh"
fi

echo ""
echo "✅ 修复完成！"
echo ""
echo "请验证修改："
echo "grep -r '$NEW_URL' ~/clawd/skills/bark-push/"
echo ""
echo "重启 OpenClaw Gateway 以应用更改："
echo "openclaw gateway restart"
EOF

chmod +x ~/clawd/scripts/fix-bark-https.sh
```

#### 执行修复

```bash
# 1. 修改脚本中的 NEW_URL 为您的实际域名
nano ~/clawd/scripts/fix-bark-https.sh

# 2. 执行修复
~/clawd/scripts/fix-bark-https.sh

# 3. 验证修改
grep -r "https://" ~/clawd/skills/bark-push/

# 4. 重启 Gateway
openclaw gateway restart
```

---

## 五、方案二：Cloudflare Tunnel（免费，推荐）

### 5.1 为什么选择 Cloudflare Tunnel？

**优势**：
- ✅ 完全免费
- ✅ 无需购买域名（可选）
- ✅ 自动 HTTPS 配置
- ✅ 全球 CDN 加速
- ✅ DDoS 防护
- ✅ 配置极其简单

### 5.2 安装步骤

#### 步骤 1：安装 cloudflared

**macOS**：
```bash
brew install cloudflare/cloudflare/cloudflared
```

**Linux（阿里云/腾讯云）**：
```bash
# 下载
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64

# 安装
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
```

#### 步骤 2：登录 Cloudflare

```bash
# 登录（会打开浏览器）
cloudflared tunnel login
```

1. 登录您的 Cloudflare 账号（免费注册）
2. 授权您的域名
3. 完成后回到终端

#### 步骤 3：创建隧道

```bash
# 创建隧道（命名为 bark-tunnel）
cloudflared tunnel create bark-tunnel
```

**输出示例**：
```
Tunnel credentials written to /path/to/credentials.json
cloudflared chose a random ID for this tunnel: 12345678-1234-1234-1234-123456789abc
```

**记录以下信息**：
- Tunnel ID：`12345678-1234-1234-1234-123456789abc`
- Credentials 文件路径

#### 步骤 4：配置隧道

```bash
# 创建配置目录
mkdir -p ~/.cloudflared

# 编辑配置
nano ~/.cloudflared/config.yml
```

**配置内容**：

```yaml
tunnel: 12345678-1234-1234-1234-123456789abc  # 替换为您的 Tunnel ID
credentials-file: /root/.cloudflared/12345678-1234-1234-1234-123456789abc.json  # 替换为实际路径

ingress:
  # Bark 服务（替换为您的域名）
  - hostname: bark.yourdomain.com
    service: http://localhost:8080

  # 或使用 Cloudflare 提供的免费子域名
  - hostname: your-tunnel-id.cfargotunnel.com
    service: http://localhost:8080

  # 其他请求返回 404
  - service: http_status:404
```

#### 步骤 5：运行隧道

**测试运行**：
```bash
cloudflared tunnel run
```

**后台运行**：
```bash
# 安装为服务（Linux）
sudo cloudflared service install

# 启动服务
sudo systemctl start cloudflared
sudo systemctl enable cloudflared

# 查看状态
sudo systemctl status cloudflared
```

**macOS 后台运行**：
```bash
# 使用 LaunchAgent
cloudflared service install
```

#### 步骤 6：获取 HTTPS 地址

Cloudflare 会提供一个地址：
```
https://bark.yourdomain.com
# 或
https://your-tunnel-id.cfargotunnel.com
```

**测试访问**：
```bash
curl https://bark.yourdomain.com/ping
```

### 5.3 更新 OpenClaw 配置

使用方案一中提供的修复脚本，将 `NEW_URL` 改为 Cloudflare 提供的地址即可。

---

## 六、方案三：使用 Bark 公共服务（临时方案）

### 6.1 公共服务地址

Bark 官方提供的公共 API：

```
https://api.day.app
```

### 6.2 使用方法

#### 测试推送

```bash
curl https://api.day.app/你的设备密钥/标题/内容
```

#### 更新配置

```bash
# 编辑环境变量
export BARK_SERVER="https://api.day.app"

# 或修改配置文件
sed -i '' 's|http://8.163.19.50:8080|https://api.day.app|g' ~/clawd/skills/bark-push/skill.json
```

### 6.3 限制

**公共服务的限制**：
- ⚠️ 有频率限制
- ⚠️ 不适合生产环境
- ⚠️ 隐私风险（消息经过公共服务器）
- ⚠️ 可能不稳定

**适用场景**：
- 仅用于测试
- 临时过渡方案
- 低频推送

---

## 七、适配检查清单

### 7.1 代码适配清单

- [ ] ✅ 已识别所有 HTTP 资源
- [ ] 🔧 已为 Bark 服务器配置 HTTPS
- [ ] 🔧 已更新 `skills/bark-push/skill.json`
- [ ] 🔧 已更新 `skills/bark-push/bark-push.ts`
- [ ] 🔧 已更新 `skills/bark-push.ts`
- [ ] 🔧 已更新 `skills/daily-briefing/briefing.sh`
- [ ] ✅ 已测试 HTTPS 推送功能
- [ ] ✅ 已验证钉钉小程序/H5 功能

### 7.2 验证步骤

#### 步骤 1：验证 HTTPS 可访问

```bash
# 测试 Bark 服务器 HTTPS 访问
curl -I https://your-domain.com/ping

# 应返回 200 OK
```

#### 步骤 2：验证 OpenClaw 配置

```bash
# 检查配置文件
cat ~/clawd/skills/bark-push/skill.json | grep -i "https://"

# 应该看到 HTTPS 地址，没有 HTTP
```

#### 步骤 3：测试推送功能

```bash
# 发送测试推送
openclaw skills run bark-push --title="iOS 18 适配测试" --body="HTTPS 推送成功！"

# 或直接调用 Bark API
curl "https://your-domain.com/你的设备密钥/测试/HTTPS 推送成功"
```

#### 步骤 4：验证钉钉集成（如果已配置）

在钉钉中：
1. 打开工作台插件
2. 触发一个推送操作
3. 检查是否正常收到推送
4. 打开 Safari（iOS 18）查看推送历史页面
5. 确认没有 Mixed Content 错误

### 7.3 监控和维护

**长期维护**：
- [ ] 设置 SSL 证书自动续期（Let's Encrypt）
- [ ] 定期检查 SSL 证书有效期
- [ ] 监控 HTTPS 服务可用性
- [ ] 关注 iOS 系统更新和策略变化

---

## 八、常见问题

### Q1: 为什么不直接在 H5 页面中允许 HTTP？

**A**：
- iOS 18 的安全策略**不允许**在 HTTPS 页面中加载 HTTP 资源
- 这是系统级别的限制，无法通过代码绕过
- 必须将所有资源升级为 HTTPS

### Q2: 检查到其他 HTTP 资源怎么办？

**A**：
```bash
# 在项目中搜索所有 HTTP 资源
cd ~/clawd
grep -r "http://" --exclude-dir=node_modules --exclude-dir=.git .
```

**常见 HTTP 资源**：
- 图片：CDN 地址
- API：第三方服务
- 脚本：外部 JS 库
- iframe：嵌入页面

**解决方案**：
- 联系服务提供方确认是否支持 HTTPS
- 或使用反向代理（如 Cloudflare Workers）
- 或下载到本地托管

### Q3: 本地开发环境怎么办？

**A**：
**选项 1**：使用 HTTPS 本地服务器
```bash
# 使用 mkcert 创建本地证书
brew install mkcert
mkcert -install
mkcert localhost 127.0.0.1 ::1
```

**选项 2**：使用 ngrok 临时隧道
```bash
brew install ngrok
ngrok http 8080
# 会提供一个 HTTPS 地址
```

**选项 3**：开发时忽略（不推荐生产）

### Q4: SSL 证书过期怎么办？

**A**：
**Let's Encrypt**（自动续期）：
```bash
# Certbot 自动续期
sudo certbot renew --dry-run

# 添加定时任务（自动续期）
sudo crontab -e
# 添加：0 0 * * * certbot renew --quiet
```

**手动续期**：
```bash
# 重新申请证书
sudo certbot certonly --standalone -d your-domain.com

# 重启 Nginx
sudo systemctl restart nginx
```

### Q5: Cloudflare Tunnel 稳定吗？适合生产吗？

**A**：
- ✅ **非常稳定**：Cloudflare 基础设施
- ✅ **适合生产**：很多企业都在用
- ✅ **免费且无限制**：流量不限制
- ⚠️ **依赖 Cloudflare**：如果 Cloudflare 故障会受影响

**建议**：
- 小型项目：直接用 Cloudflare Tunnel
- 大型企业：自建 HTTPS + CDN

---

## 九、快速参考

### 9.1 紧急修复（5 分钟）

如果钉钉新版本即将上线，来不及配置 HTTPS：

```bash
# 临时使用 Bark 公共服务
cd ~/clawd

# 批量替换
find skills -name "*.json" -o -name "*.ts" -o -name "*.sh" | xargs sed -i '' 's|http://8.163.19.50:8080|https://api.day.app|g'

# 重启
openclaw gateway restart
```

**⚠️ 注意**：这只是临时方案，长期还是要配置自己的 HTTPS。

### 9.2 推荐工具

| 工具 | 用途 | 链接 |
|------|------|------|
| **Let's Encrypt** | 免费 SSL 证书 | https://letsencrypt.org/ |
| **Cloudflare Tunnel** | 免费 HTTPS 隧道 | https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
| **mkcert** | 本地 HTTPS 开发 | https://github.com/FiloSottile/mkcert |
| **ngrok** | 临时隧道 | https://ngrok.com/ |
| **SSL Labs** | SSL 测试 | https://www.ssllabs.com/ssltest/ |

### 9.3 检查命令

```bash
# 检查所有 HTTP 资源
cd ~/clawd
grep -r "http://" --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.gitignore .

# 检查 SSL 证书
curl -I https://your-domain.com
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# 测试推送
curl "https://your-domain.com/设备密钥/测试/内容"
```

---

## 十、总结

### 核心要点

1. **iOS 18 强制 HTTPS**：无商量余地
2. **钉钉新版本即将发布**：必须提前适配
3. **OpenClaw 项目需要修复**：Bark 服务地址
4. **推荐方案**：Cloudflare Tunnel（免费）或自建 HTTPS

### 行动建议

**立即行动**（今天）：
- [x] ✅ 已识别问题
- [ ] 🔧 选择适配方案
- [ ] 🔧 开始配置 HTTPS

**本周完成**：
- [ ] 配置 HTTPS 服务
- [ ] 更新 OpenClaw 配置
- [ ] 测试推送功能
- [ ] 验证钉钉集成

**长期维护**：
- [ ] 设置证书自动续期
- [ ] 监控服务可用性
- [ ] 关注 iOS 策略变化

---

**适配状态**：
- ✅ 问题已识别
- ⏳ 等待选择适配方案
- ⏳ 等待执行修复

**预计完成时间**：1-2 小时（取决于选择的方案）

---

**需要帮助？**

- Let's Encrypt 文档：https://letsencrypt.org/docs/
- Cloudflare 文档：https://developers.cloudflare.com/cloudflare-one/
- SSL Labs 测试：https://www.ssllabs.com/ssltest/
- OpenClaw 社区：https://coclaw.com/

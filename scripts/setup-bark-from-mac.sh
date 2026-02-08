#!/bin/bash

# 在 Mac 上下载 Bark 并上传到服务器
# 然后在服务器上配置和启动

set -e

echo "========================================="
echo "   Bark 部署助手（Mac 端）"
echo "========================================="
echo ""

# 服务器信息
SERVER="root@8.163.19.50"
BARK_VERSION="v2.3.3"

# 检测架构（大多数阿里云服务器是 x86_64）
echo "正在下载 Bark for Linux (amd64)..."

# 下载 Bark
if [ ! -f "/tmp/bark-server" ]; then
    curl -L -o /tmp/bark-server \
      "https://github.com/Finb/bark-server/releases/download/${BARK_VERSION}/bark-server_linux_amd64_v2"
    chmod +x /tmp/bark-server
fi

echo "✓ 下载完成"
echo ""

# 上传到服务器
echo "正在上传到服务器..."
scp /tmp/bark-server "$SERVER:/tmp/"

echo "✓ 上传完成"
echo ""

# 在服务器上配置和启动
echo "========================================="
echo "   正在服务器上配置 Bark..."
echo "========================================="
echo ""

ssh "$SERVER" bash -s <<'EOFREMOTE'
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "正在创建目录..."
mkdir -p /opt/bark
mkdir -p /var/log/bark

echo "正在安装 Bark..."
mv /tmp/bark-server /opt/bark/bark
chmod +x /opt/bark/bark

echo "正在创建配置文件..."
cat > /opt/bark/config.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ENV</key>
    <string>production</string>
    <key>IP</key>
    <string>0.0.0.0</string>
    <key>PORT</key>
    <string>8080</string>
    <key>connector</key>
    <dict>
        <key>token</key>
        <string></string>
        <key>devMode</key>
        <false/>
    </dict>
</dict>
</plist>
EOF

echo "正在创建 systemd 服务..."
cat > /etc/systemd/system/bark.service <<'EOFSVC'
[Unit]
Description=Bark Push Notification Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/bark
ExecStart=/opt/bark/bark
Restart=always
RestartSec=10
StandardOutput=append:/var/log/bark/access.log
StandardError=append:/var/log/bark/error.log

[Install]
WantedBy=multi-user.target
EOFSVC

echo "正在启动 Bark 服务..."
systemctl daemon-reload
systemctl enable bark
systemctl start bark

sleep 3

if systemctl is-active --quiet bark; then
    SERVER_IP=$(curl -s ifconfig.me)
    echo ""
    echo "========================================="
    echo -e "${GREEN}   Bark 服务部署成功！${NC}"
    echo "========================================="
    echo ""
    echo "服务地址: http://$SERVER_IP:8080"
    echo ""
    echo "服务状态:"
    systemctl status bark | head -5
    echo ""

    if curl -s http://localhost:8080/ping | grep -q "pong"; then
        echo -e "${GREEN}✓ 服务测试通过${NC}"
    else
        echo -e "${YELLOW}⚠ 服务测试失败，查看日志${NC}"
    fi

    echo ""
    echo "========================================="
    echo -e "${YELLOW}⚠️  下一步:${NC}"
    echo "========================================="
    echo ""
    echo "1. 在阿里云控制台配置安全组，开放 8080 端口"
    echo "2. 在 iOS/Android 设备上下载 Bark 应用"
    echo "3. 获取设备密钥后，使用以下地址测试:"
    echo ""
    echo -e "   http://$SERVER_IP:8080/您的设备密钥/测试标题/测试内容"
    echo ""
    echo "========================================="
else
    echo -e "${RED}✗ Bark 服务启动失败${NC}"
    tail -20 /var/log/bark/error.log
    exit 1
fi
EOFREMOTE

echo ""
echo "✅ 部署完成！"
echo ""
echo "清理临时文件:"
rm -f /tmp/bark-server

#!/bin/bash

# Bark 推送服务部署 - 二进制方案
# 直接下载 Bark 二进制文件并使用 systemd 管理

set -e

echo "========================================="
echo "   Bark 推送服务部署（二进制版）"
echo "========================================="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 获取系统架构
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    BARK_ARCH="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    BARK_ARCH="arm64"
else
    echo "不支持的架构: $ARCH"
    exit 1
fi

echo "系统架构: $ARCH -> $BARK_ARCH"
echo ""

# 安装必要的工具
echo "正在安装依赖..."
yum install -y wget unzip

# 创建目录
mkdir -p /opt/bark
mkdir -p /var/log/bark

# 下载 Bark（从 GitHub releases）
echo -e "${YELLOW}正在下载 Bark...${NC}"

# 尝试多个下载源
BARK_URL="https://github.com/Finb/Bark-server/releases/download/v2.0.9/Bark-server_v2.0.9_linux_$BARK_ARCH.zip"

if wget -O /tmp/bark.zip "$BARK_URL" --timeout=30; then
    echo -e "${GREEN}✓ 下载成功${NC}"
else
    echo -e "${YELLOW}GitHub 下载失败，尝试备用方案...${NC}"

    # 使用 Go 安装（如果服务器有 Go）
    if command -v go &> /dev/null; then
        echo "使用 Go 安装 Bark..."
        go install github.com/Finb/Bark-server@latest
        cp ~/go/bin/Bark-server /opt/bark/bark
    else
        echo "请手动下载 Bark 并上传到服务器 /tmp/bark.zip"
        echo "下载地址: https://github.com/Finb/Bark-server/releases"
        exit 1
    fi
fi

# 解压（如果下载成功）
if [ -f "/tmp/bark.zip" ]; then
    cd /tmp
    unzip -o bark.zip
    mv Bark-server /opt/bark/bark
    chmod +x /opt/bark/bark
    rm -f /tmp/bark.zip
fi

# 创建配置文件
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

# 创建 systemd 服务
cat > /etc/systemd/system/bark.service <<'EOF'
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
EOF

# 启动服务
echo -e "${YELLOW}正在启动 Bark 服务...${NC}"
systemctl daemon-reload
systemctl enable bark
systemctl start bark

# 等待启动
sleep 3

# 检查状态
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

    # 测试服务
    if curl -s http://localhost:8080/ping | grep -q "pong"; then
        echo -e "${GREEN}✓ 服务测试通过${NC}"
    else
        echo -e "${YELLOW}⚠ 服务测试失败，查看日志${NC}"
        tail -20 /var/log/bark/error.log
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
    echo ""
    echo "常用命令:"
    echo "  查看日志: tail -f /var/log/bark/access.log"
    echo "  重启服务: systemctl restart bark"
    echo "  停止服务: systemctl stop bark"
    echo "  查看状态: systemctl status bark"
    echo ""

else
    echo -e "${RED}✗ Bark 服务启动失败${NC}"
    echo ""
    echo "查看错误日志:"
    tail -50 /var/log/bark/error.log
    exit 1
fi

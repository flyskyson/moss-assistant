#!/bin/bash

# Bark 推送服务 - 备用部署方案
# 使用 GitHub 直接部署或从国内镜像拉取

set -e

echo "========================================="
echo "   Bark 推送服务部署（备用方案）"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 获取服务器 IP
SERVER_IP=$(curl -s ifconfig.me)

echo "服务器 IP: $SERVER_IP"
echo ""

# 创建数据目录
mkdir -p /root/bark-data

# 方案 1: 尝试从阿里云镜像拉取
echo -e "${YELLOW}方案 1: 尝试从阿里云镜像拉取...${NC}"
if docker pull registry.cn-hangzhou.aliyuncs.com/finab/bark-server:latest 2>/dev/null; then
    echo -e "${GREEN}✓ 从阿里云镜像拉取成功${NC}"

    # 给镜像打标签
    docker tag registry.cn-hangzhou.aliyuncs.com/finab/bark-server:latest finab/bark-server:latest

    # 启动容器
    docker run -dt \
      --name bark \
      --restart=unless-stopped \
      -p 8080:8080 \
      -v /root/bark-data:/bark-data \
      finab/bark-server:latest

    success=true
elif docker pull registry.cn-beijing.aliyuncs.com/finab/bark-server:latest 2>/dev/null; then
    echo -e "${GREEN}✓ 从北京镜像拉取成功${NC}"

    docker tag registry.cn-beijing.aliyuncs.com/finab/bark-server:latest finab/bark-server:latest

    docker run -dt \
      --name bark \
      --restart=unless-stopped \
      -p 8080:8080 \
      -v /root/bark-data:/bark-data \
      finab/bark-server:latest

    success=true
else
    echo -e "${RED}✗ 阿里云镜像拉取失败${NC}"
    echo ""
    echo -e "${YELLOW}方案 2: 从 GitHub 下载 Bark 并构建...${NC}"

    # 安装必要的工具
    yum install -y git wget

    # 克隆 Bark 仓库
    cd /root
    if [ -d "/root/Bark-server" ]; then
        rm -rf /root/Bark-server
    fi

    git clone https://github.com/Finb/Bark-server.git
    cd Bark-server

    # 使用 Docker 构建
    echo "正在构建 Bark 镜像..."
    docker build -t bark-server:latest .

    # 启动容器
    docker run -dt \
      --name bark \
      --restart=unless-stopped \
      -p 8080:8080 \
      -v /root/bark-data:/bark-data \
      bark-server:latest

    success=true
fi

# 等待容器启动
sleep 5

# 检查容器状态
if docker ps | grep -q bark; then
    echo ""
    echo "========================================="
    echo -e "${GREEN}   Bark 服务部署成功！${NC}"
    echo "========================================="
    echo ""
    echo "服务信息:"
    echo "  服务器地址: http://$SERVER_IP:8080"
    echo "  本地地址: http://localhost:8080"
    echo ""
    echo "容器状态:"
    docker ps | grep bark
    echo ""

    # 测试服务
    if curl -s http://localhost:8080/ping | grep -q "pong"; then
        echo -e "${GREEN}✓ 服务测试通过${NC}"
    else
        echo -e "${YELLOW}⚠ 服务测试失败，请检查日志${NC}"
        docker logs bark
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
    echo -e "${RED}✗ Bark 容器启动失败${NC}"
    echo ""
    echo "查看日志:"
    docker logs bark
    exit 1
fi

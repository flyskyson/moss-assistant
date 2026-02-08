#!/bin/bash

# Bark 自动化部署脚本
# 适用于 CentOS/RHEL/Ubuntu/Debian
# 使用方法: bash deploy-bark.sh

set -e

echo "========================================="
echo "   Bark 推送服务自动化部署脚本"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    else
        echo -e "${RED}无法检测操作系统${NC}"
        exit 1
    fi
    echo -e "${GREEN}检测到操作系统: $OS${NC}"
}

# 检查并安装 Docker
install_docker() {
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}Docker 已安装: $(docker --version)${NC}"
        return
    fi

    echo -e "${YELLOW}Docker 未安装，开始安装...${NC}"

    case $OS in
        centos|rhel|almalinux|rocky|alinux)
            echo "正在安装 Docker (CentOS/RHEL/Alibaba Linux)..."
            yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true
            yum install -y yum-utils
            yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
            yum install -y docker-ce docker-ce-cli containerd.io
            ;;

        ubuntu|debian)
            echo "正在安装 Docker (Ubuntu/Debian)..."
            apt-get update
            apt-get install -y ca-certificates curl gnupg lsb-release
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
              https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
              $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
            ;;

        *)
            echo -e "${RED}不支持的操作系统: $OS${NC}"
            exit 1
            ;;
    esac

    # 配置 Docker 镜像加速
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://registry.cn-beijing.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF

    # 启动 Docker
    systemctl start docker
    systemctl enable docker

    echo -e "${GREEN}Docker 安装完成: $(docker --version)${NC}"
  else
    # Docker 已安装，检查是否配置了镜像加速
    if ! grep -q "registry-mirrors" /etc/docker/daemon.json 2>/dev/null; then
      echo -e "${YELLOW}正在配置 Docker 镜像加速器...${NC}"
      mkdir -p /etc/docker
      cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://registry.cn-beijing.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF
      systemctl daemon-reload
      systemctl restart docker
      echo -e "${GREEN}✓ 镜像加速器配置完成${NC}"
    fi
}

# 部署 Bark 服务
deploy_bark() {
    echo ""
    echo -e "${YELLOW}开始部署 Bark 服务...${NC}"

    # 创建数据目录
    mkdir -p /root/bark-data

    # 停止并删除旧容器（如果存在）
    if docker ps -a | grep -q bark; then
        echo "删除旧的 Bark 容器..."
        docker stop bark 2>/dev/null || true
        docker rm bark 2>/dev/null || true
    fi

    # 拉取镜像并运行容器
    echo "拉取 Bark 镜像..."
    docker pull finab/bark-server:latest

    echo "启动 Bark 容器..."
    docker run -dt \
      --name bark \
      --restart=unless-stopped \
      -p 8080:8080 \
      -v /root/bark-data:/bark-data \
      finab/bark-server:latest

    # 等待容器启动
    sleep 5

    # 检查容器状态
    if docker ps | grep -q bark; then
        echo -e "${GREEN}✓ Bark 容器启动成功${NC}"
    else
        echo -e "${RED}✗ Bark 容器启动失败${NC}"
        docker logs bark
        exit 1
    fi
}

# 配置防火墙
configure_firewall() {
    echo ""
    echo -e "${YELLOW}配置防火墙...${NC}"

    # firewalld
    if command -v firewall-cmd &> /dev/null; then
        if systemctl is-active --quiet firewalld; then
            echo "配置 firewalld..."
            firewall-cmd --permanent --add-port=8080/tcp 2>/dev/null || true
            firewall-cmd --reload 2>/dev/null || true
            echo -e "${GREEN}✓ firewalld 已配置${NC}"
        fi
    fi

    # ufw
    if command -v ufw &> /dev/null; then
        echo "配置 ufw..."
        ufw allow 8080/tcp 2>/dev/null || true
        echo -e "${GREEN}✓ ufw 已配置${NC}"
    fi
}

# 测试服务
test_service() {
    echo ""
    echo -e "${YELLOW}测试服务...${NC}"

    # 获取服务器 IP
    SERVER_IP=$(curl -s ifconfig.me)

    # 测试本地访问
    if curl -s http://localhost:8080/ping | grep -q "pong"; then
        echo -e "${GREEN}✓ 本地访问测试成功${NC}"
    else
        echo -e "${RED}✗ 本地访问测试失败${NC}"
        docker logs bark
        exit 1
    fi
}

# 显示结果
show_result() {
    echo ""
    echo "========================================="
    echo -e "${GREEN}   Bark 服务部署完成！${NC}"
    echo "========================================="
    echo ""
    echo "服务信息:"
    echo "  服务器地址: http://$SERVER_IP:8080"
    echo "  本地地址: http://localhost:8080"
    echo ""
    echo "容器状态:"
    docker ps | grep bark
    echo ""
    echo "查看日志:"
    echo "  docker logs -f bark"
    echo ""
    echo "重启服务:"
    echo "  docker restart bark"
    echo ""
    echo "========================================="
    echo -e "${YELLOW}⚠️  重要提示:${NC}"
    echo "1. 请在阿里云控制台配置安全组，开放 8080 端口"
    echo "2. 在 iOS/Android 设备上下载 Bark 应用"
    echo "3. 获取设备密钥后，使用以下地址测试:"
    echo ""
    echo -e "   http://$SERVER_IP:8080/您的设备密钥/测试标题/测试内容"
    echo ""
    echo "========================================="
}

# 主函数
main() {
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}请使用 root 用户执行此脚本${NC}"
        exit 1
    fi

    detect_os
    install_docker
    deploy_bark
    configure_firewall
    test_service
    show_result
}

main

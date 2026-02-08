#!/bin/bash

# 修复 Docker 镜像拉取问题 - 配置国内镜像加速器

set -e

echo "========================================="
echo "   配置 Docker 镜像加速器"
echo "========================================="
echo ""

# 创建配置目录
mkdir -p /etc/docker

# 配置多个国内镜像源（按优先级排序）
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://registry.cn-beijing.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

echo "✓ 已配置 Docker 镜像加速器"
echo ""

# 重启 Docker 服务
echo "正在重启 Docker 服务..."
systemctl daemon-reload
systemctl restart docker

# 等待 Docker 启动
sleep 3

# 验证配置
echo ""
echo "========================================="
echo "   验证 Docker 配置"
echo "========================================="
echo ""

docker info | grep -A 5 "Registry Mirrors" || true

echo ""
echo "✓ Docker 配置完成！"
echo ""
echo "现在可以重新运行部署脚本："
echo "  bash deploy-bark.sh"

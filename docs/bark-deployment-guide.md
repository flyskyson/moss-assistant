# Bark 推送服务部署指南

> **服务器信息**
> - IP: 8.163.19.50
> - 用户: root
> - 端口: 22
> - 部署日期: 2026-02-07

---

## 第一步：连接服务器

在您的本地终端执行：

```bash
ssh root@8.163.19.50
```

---

## 第二步：检查系统环境

连接成功后，运行以下命令检查系统：

```bash
# 检查操作系统
cat /etc/os-release

# 检查 Docker 是否安装
docker --version

# 检查 Docker 服务状态
systemctl status docker
```

---

## 第三步：安装 Docker（如果未安装）

### CentOS/RHEL/AlmaLinux:

```bash
# 卸载旧版本
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine

# 安装依赖
yum install -y yum-utils

# 添加 Docker 仓库（使用阿里云镜像）
yum-config-manager \
  --add-repo \
  https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装 Docker
yum install -y docker-ce docker-ce-cli containerd.io

# 启动 Docker
systemctl start docker
systemctl enable docker

# 验证安装
docker --version
```

### Ubuntu/Debian:

```bash
# 更新包索引
apt-get update

# 安装依赖
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加 Docker GPG 密钥
mkdir -p /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker 仓库
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# 启动 Docker
systemctl start docker
systemctl enable docker
```

---

## 第四步：部署 Bark 服务

```bash
# 创建数据目录
mkdir -p /root/bark-data

# 运行 Bark 容器
docker run -dt \
  --name bark \
  --restart=unless-stopped \
  -p 8080:8080 \
  -v /root/bark-data:/bark-data \
  finab/bark-server:latest

# 检查容器状态
docker ps | grep bark

# 查看日志（确认启动成功）
docker logs -f bark
```

看到类似以下日志说明启动成功：
```
Listening on port 8080...
```

按 `Ctrl+C` 退出日志查看。

---

## 第五步：配置防火墙/安全组

### 阿里云安全组配置（重要）：

1. 登录 [阿里云控制台](https://ecs.console.aliyun.com/)
2. 找到实例 `8.163.19.50`
3. 点击"安全组" → "配置规则"
4. 添加入方向规则：
   - **端口范围**: 8080/8080
   - **授权对象**: 0.0.0.0/0
   - **协议**: TCP

### 服务器内部防火墙（如果启用）：

```bash
# firewalld (CentOS/RHEL)
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# ufw (Ubuntu/Debian)
ufw allow 8080/tcp
```

---

## 第六步：验证服务

```bash
# 测试本地访问
curl http://localhost:8080/ping

# 应返回: pong
```

---

## 第七步：获取设备密钥

### iOS 设备：

1. 在 App Store 搜索并下载 **"Bark"** 应用
2. 打开应用，会自动获取设备密钥
3. 记下显示的密钥（类似：xxxxxxxxxxxxxxxxxxxxxxxxxxxx）

### Android 设备：

1. 在 Google Play 或第三方应用商店下载 **"Bark"** 应用
2. 打开应用，获取设备密钥

---

## 第八步：测试推送

### 方法 1：使用 curl 测试

```bash
# 替换 YOUR_DEVICE_KEY 为您的实际设备密钥
curl -X POST "http://8.163.19.50:8080/YOUR_DEVICE_KEY/测试标题/测试内容?sound=bell"
```

### 方法 2：在浏览器中测试

```
http://8.163.19.50:8080/YOUR_DEVICE_KEY/测试标题/测试内容?sound=bell
```

### 方法 3：使用 Bark 应用内测试

在 Bark 应用中填写服务器地址：
- 服务器地址: `http://8.163.19.50:8080`
- 点击测试推送

---

## 常用维护命令

```bash
# 查看容器状态
docker ps

# 查看日志
docker logs -f bark

# 重启服务
docker restart bark

# 停止服务
docker stop bark

# 删除容器（保留数据）
docker rm -f bark

# 重新创建容器
docker run -dt \
  --name bark \
  --restart=unless-stopped \
  -p 8080:8080 \
  -v /root/bark-data:/bark-data \
  finab/bark-server:latest

# 更新到最新版本
docker stop bark
docker rm bark
docker pull finab/bark-server:latest
docker run -dt \
  --name bark \
  --restart=unless-stopped \
  -p 8080:8080 \
  -v /root/bark-data:/bark-data \
  finab/bark-server:latest
```

---

## API 调用示例

### 基础推送

```bash
curl -X POST "http://8.163.19.50:8080/YOUR_DEVICE_KEY/标题/内容"
```

### 带参数的推送

```bash
curl -X POST "http://8.163.19.50:8080/YOUR_DEVICE_KEY/标题/内容?sound=bell&badge=1&group=通知分组"
```

### 自定义推送

```bash
curl -X POST "http://8.163.19.50:8080/YOUR_DEVICE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "标题",
    "body": "内容",
    "sound": "bell",
    "badge": 1,
    "group": "通知分组",
    "icon": "https://example.com/icon.png",
    "url": "https://example.com"
  }'
```

---

## 故障排查

### 问题 1：容器无法启动

```bash
# 查看详细日志
docker logs bark

# 检查端口占用
netstat -tunlp | grep 8080

# 如果端口被占用，停止占用进程或更改端口
```

### 问题 2：无法接收推送

1. 检查服务器防火墙和安全组配置
2. 检查设备密钥是否正确
3. 查看容器日志：`docker logs -f bark`
4. 确认 iOS/Android 应用的通知权限已开启

### 问题 3：Docker 安装失败

```bash
# 使用阿里云镜像加速
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com"
  ]
}
EOF

systemctl restart docker
```

---

## 集成到 OpenClaw

创建一个便捷的推送脚本：

```bash
#!/bin/bash
# /usr/local/bin/bark-push

DEVICE_KEY="YOUR_DEVICE_KEY"
SERVER="http://8.163.19.50:8080"

if [ -z "$1" ]; then
  echo "用法: bark-push \"标题\" \"内容\""
  exit 1
fi

TITLE="$1"
BODY="${2:-}"

curl -s -X POST "${SERVER}/${DEVICE_KEY}/${TITLE}/${BODY}"
echo ""
```

---

## 下一步

1. ✅ 部署 Bark 服务器
2. ⬜ 在您的 iOS/Android 设备上安装 Bark 应用
3. ⬜ 获取设备密钥并告诉我
4. ⬜ 创建 OpenClaw 技能集成 Bark 推送

---

**部署完成后，请告诉我您的设备密钥，我将帮您创建 OpenClaw 技能来实现自动推送功能。**

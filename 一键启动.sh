#!/bin/bash

# ============================================================
# MOSS Assistant - 一键启动脚本 (Linux/Mac)
# ============================================================
# 功能：
#   1. 智能环境检测
#   2. 自动加载环境变量
#   3. 检查并安装依赖
#   4. 健康检查
#   5. 启动服务并自动打开浏览器
# ============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║     🤖 MOSS Assistant - 一键启动 v2.0                ║"
echo "║     苏格拉底式辩论伙伴 + 全能个人助理                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# ========================================
# 步骤 1: 环境检测
# ========================================
echo -e "${BLUE}[1/6] 检测运行环境...${NC}"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 错误: 未检测到 Python3${NC}"
    echo -e "${YELLOW}💡 请先安装 Python 3.8 或更高版本${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✅ Python 版本: $PYTHON_VERSION${NC}"
echo ""

# 检查 pip
if ! python3 -m pip --version &> /dev/null; then
    echo -e "${RED}❌ 错误: pip 未安装${NC}"
    echo -e "${YELLOW}💡 请尝试重新安装 Python${NC}"
    exit 1
fi

echo -e "${GREEN}✅ pip 已就绪${NC}"
echo ""

# ========================================
# 步骤 2: 加载环境变量
# ========================================
echo -e "${BLUE}[2/6] 加载环境变量...${NC}"
echo ""

# 检查 .env 文件
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ 发现 .env 文件${NC}"

    # 导出环境变量
    export $(grep -v '^#' .env | xargs)

    if [ -n "$DEEPSEEK_API_KEY" ]; then
        MASKED_KEY="${DEEPSEEK_API_KEY:0:10}..."
        echo -e "${GREEN}✅ DeepSeek API Key: $MASKED_KEY${NC}"
    else
        echo -e "${YELLOW}⚠️  警告: .env 文件中未找到 DEEPSEEK_API_KEY${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  警告: .env 文件不存在${NC}"
    echo -e "${YELLOW}💡 提示: 如果 API Key 未设置，MOSS 将使用模拟响应模式${NC}"
fi

echo ""

# ========================================
# 步骤 3: 检查并安装依赖
# ========================================
echo -e "${BLUE}[3/6] 检查项目依赖...${NC}"
echo ""

# 检查 requirements.txt
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}❌ 错误: requirements.txt 文件不存在${NC}"
    echo -e "${YELLOW}💡 请确保在 MOSS Assistant 项目根目录下运行此脚本${NC}"
    exit 1
fi

# 检查关键依赖
if ! python3 -c "import streamlit" 2>/dev/null; then
    echo -e "${YELLOW}📦 安装项目依赖...${NC}"
    echo ""
    python3 -m pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 错误: 依赖安装失败${NC}"
        echo -e "${YELLOW}💡 请检查网络连接或手动运行: pip install -r requirements.txt${NC}"
        exit 1
    fi
    echo ""
    echo -e "${GREEN}✅ 依赖安装完成${NC}"
else
    echo -e "${GREEN}✅ 核心依赖已安装${NC}"
fi

echo ""

# ========================================
# 步骤 4: 检查核心文件
# ========================================
echo -e "${BLUE}[4/6] 检查核心文件...${NC}"
echo ""

MISSING_FILES=0

if [ ! -f "moss.py" ]; then
    echo -e "${RED}❌ 缺少核心文件: moss.py${NC}"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f "app.py" ]; then
    echo -e "${RED}❌ 缺少核心文件: app.py${NC}"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f "config.yaml" ]; then
    echo -e "${RED}❌ 缺少配置文件: config.yaml${NC}"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -d "core" ]; then
    echo -e "${RED}❌ 缺少核心目录: core/${NC}"
    MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ $MISSING_FILES -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ 错误: 项目文件不完整，缺少 $MISSING_FILES 个文件/目录${NC}"
    echo -e "${YELLOW}💡 请重新克隆项目或检查文件完整性${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 核心文件检查通过${NC}"
echo ""

# ========================================
# 步骤 5: 数据目录检查
# ========================================
echo -e "${BLUE}[5/6] 检查数据目录...${NC}"
echo ""

if [ ! -d "data" ]; then
    echo -e "${YELLOW}📁 创建数据目录...${NC}"
    mkdir -p data
    echo -e "${GREEN}✅ data/ 目录已创建${NC}"
else
    echo -e "${GREEN}✅ data/ 目录存在${NC}"
fi

if [ ! -d "data/logs" ]; then
    mkdir -p data/logs
fi

echo -e "${GREEN}✅ 数据目录就绪${NC}"
echo ""

# ========================================
# 步骤 6: 启动服务
# ========================================
echo -e "${BLUE}[6/6] 启动 MOSS Assistant...${NC}"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}🌐 访问地址: http://localhost:8501${NC}"
echo -e "${GREEN}📱 移动端: http://localhost:8501${NC}"
echo ""
echo -e "${YELLOW}💡 提示:${NC}"
echo "   - 浏览器将自动打开（如果没有，请手动访问上面的地址）"
echo "   - 按 Ctrl+C 停止服务"
echo "   - 关闭此窗口也会停止服务"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

# 等待 2 秒
sleep 2

# 启动 Streamlit（会自动打开浏览器）
python3 -m streamlit run app.py

# 如果 Streamlit 退出
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}👋 MOSS Assistant 已停止${NC}"
echo ""
echo -e "${YELLOW}💡 感谢使用！如需重新启动，请运行此脚本${NC}"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

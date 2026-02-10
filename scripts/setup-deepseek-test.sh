#!/bin/bash

# DeepSeek API Speed Test & Configuration Wizard
# DeepSeek API 速度测试与配置向导
# 2026-02-08

set -euo pipefail

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 配置文件路径
OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"
ENV_FILE="$HOME/.openclaw/.env"
LOG_DIR="/Users/lijian/clawd/logs"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 显示标题
show_header() {
    clear 2>/dev/null || true
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}DeepSeek API 速度测试与配置向导${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  MOSS 核心模型速度优化                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 显示帮助
show_help() {
    cat << EOF
${BOLD}使用方法:${NC}
  $0 [命令]

${BOLD}命令:${NC}
  check      - 检查当前配置状态
  setup      - 配置 API Keys
  test       - 运行速度测试
  compare    - 对比测试结果
  auto       - 自动配置并测试

${BOLD}示例:${NC}
  $0 check       # 检查配置
  $0 setup       # 配置 API Keys
  $0 test        # 运行测试
  $0 auto        # 自动完成所有步骤

${BOLD}说明:${NC}
  本脚本用于测试和对比以下 API 的速度：
  1. OpenRouter - DeepSeek V3.2
  2. DeepSeek 官方专线
  3. OpenRouter - MiniMax M2.1

  目标：为 MOSS 选择最快的模型配置

EOF
}

# 检查配置
check_config() {
    show_header
    echo -e "${BOLD}📋 当前配置状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查 OpenRouter
    echo -e "${BOLD}1. OpenRouter API:${NC}"
    if [ -n "${OPENROUTER_API_KEY:-}" ]; then
        echo -e "  ${GREEN}✓${NC} 环境变量已设置"
        echo "     Key: ${OPENROUTER_API_KEY:0:12}..."
    elif grep -q "openrouter" "$OPENCLAW_CONFIG" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC}  未在环境变量中设置，但 OpenClaw 配置中存在"
    else
        echo -e "  ${RED}✗${NC}  未配置"
    fi
    echo ""

    # 检查 DeepSeek
    echo -e "${BOLD}2. DeepSeek 官方 API:${NC}"
    if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
        echo -e "  ${GREEN}✓${NC} 环境变量已设置"
        echo "     Key: ${DEEPSEEK_API_KEY:0:12}..."
    else
        echo -e "  ${RED}✗${NC}  未配置"
    fi
    echo ""

    # 检查 OpenClaw 配置
    echo -e "${BOLD}3. OpenClaw 配置:${NC}"
    if [ -f "$OPENCLAW_CONFIG" ]; then
        echo -e "  ${GREEN}✓${NC}  配置文件存在"
        echo "     路径: $OPENCLAW_CONFIG"
    else
        echo -e "  ${RED}✗${NC}  配置文件不存在"
    fi
    echo ""

    # 当前使用的模型
    echo -e "${BOLD}4. 当前模型配置:${NC}"
    if grep -q "deepseek" "$OPENCLAW_CONFIG" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC}  DeepSeek 模型已配置"
        grep -o '"id":"[^"]*deepseek[^"]*"' "$OPENCLAW_CONFIG" 2>/dev/null | head -3 | sed 's/"id":"/    - /' | sed 's/"$//'
    else
        echo -e "  ${YELLOW}⚠${NC}  未找到 DeepSeek 模型配置"
    fi
    echo ""
}

# 配置 API Keys
setup_keys() {
    show_header
    echo -e "${BOLD}🔑 API Key 配置${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # OpenRouter
    echo -e "${BOLD}选项 1: OpenRouter API Key${NC}"
    echo "  用途: 访问 OpenRouter 上的所有模型（包括 DeepSeek）"
    echo "  获取: https://openrouter.ai/keys"
    echo ""
    if [ -z "${OPENROUTER_API_KEY:-}" ]; then
        echo -n "是否现在配置? [y/N] "
        read -r setup_or
        if [ "$setup_or" = "y" ] || [ "$setup_or" = "Y" ]; then
            echo -n "请输入 OpenRouter API Key: "
            read -r or_key
            if [ -n "$or_key" ]; then
                export OPENROUTER_API_KEY="$or_key"
                echo "export OPENROUTER_API_KEY=\"$or_key\"" >> "$ENV_FILE"
                echo -e "${GREEN}✓ OpenRouter API Key 已保存到 $ENV_FILE${NC}"
            fi
        fi
    else
        echo -e "  ${GREEN}✓${NC} 已配置"
    fi
    echo ""

    # DeepSeek
    echo -e "${BOLD}选项 2: DeepSeek 官方 API Key${NC}"
    echo "  用途: 直接访问 DeepSeek 官方 API（更快）"
    echo "  获取: https://platform.deepseek.com/api_keys"
    echo ""
    if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
        echo -n "是否现在配置? [y/N] "
        read -r setup_ds
        if [ "$setup_ds" = "y" ] || [ "$setup_ds" = "Y" ]; then
            echo -n "请输入 DeepSeek API Key: "
            read -r ds_key
            if [ -n "$ds_key" ]; then
                export DEEPSEEK_API_KEY="$ds_key"
                echo "export DEEPSEEK_API_KEY=\"$ds_key\"" >> "$ENV_FILE"
                echo -e "${GREEN}✓ DeepSeek API Key 已保存到 $ENV_FILE${NC}"
            fi
        fi
    else
        echo -e "  ${GREEN}✓${NC} 已配置"
    fi
    echo ""

    # 加载环境变量
    if [ -f "$ENV_FILE" ]; then
        echo -e "${BOLD}加载环境变量...${NC}"
        # shellcheck source=/dev/null
        source "$ENV_FILE"
        echo -e "${GREEN}✓ 环境变量已加载${NC}"
    fi
    echo ""
}

# 运行速度测试
run_test() {
    show_header
    echo -e "${BOLD}⚡ 开始速度测试${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查 API Keys
    if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -z "${DEEPSEEK_API_KEY:-}" ]; then
        echo -e "${RED}❌ 未找到任何 API Key${NC}"
        echo ""
        echo "请先配置 API Keys:"
        echo "  $0 setup"
        echo ""
        exit 1
    fi

    # 运行测试脚本
    if [ -f "/Users/lijian/clawd/scripts/test-api-speed.sh" ]; then
        bash /Users/lijian/clawd/scripts/test-api-speed.sh
    else
        echo -e "${RED}❌ 测试脚本不存在${NC}"
        exit 1
    fi
}

# 显示配置建议
show_recommendations() {
    show_header
    echo -e "${BOLD}💡 配置建议${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 读取最新的测试结果
    local latest_log=$(ls -t "$LOG_DIR"/api-speed-test-*.log 2>/dev/null | head -1)

    if [ -z "$latest_log" ]; then
        echo -e "${YELLOW}⚠️  未找到测试结果${NC}"
        echo ""
        echo "请先运行测试:"
        echo "  $0 test"
        echo ""
        return
    fi

    echo -e "${BOLD}最新测试结果:${NC} $(basename $latest_log)"
    echo ""

    # 提取测试结果
    echo -e "${BOLD}速度对比:${NC}"
    grep "平均响应时间" "$latest_log" | sed 's/平均响应时间: //' | while read -r line; do
        # 解析时间和方案名
        time=$(echo "$line" | grep -o '[0-9.]*s' | sed 's/s//')
        if [ -n "$time" ]; then
            # 速度评级
            faster=$(echo "$time < 2.0" | bc -l)
            if [ "$faster" = "1" ]; then
                rating="${GREEN}快 ✓${NC}"
            else
                rating="${YELLOW}中${NC}"
            fi
            echo "  $line  $rating"
        fi
    done
    echo ""

    echo -e "${BOLD}推荐配置:${NC}"
    echo ""
    echo "1. MOSS 主模型：选择最快的方案"
    echo "2. 其他任务：使用智能路由"
    echo ""
    echo "编辑文件: $OPENCLAW_CONFIG"
    echo ""
}

# 自动流程
auto_setup() {
    show_header
    echo -e "${BOLD}🚀 自动配置流程${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "步骤 1: 检查当前配置"
    check_config
    sleep 2

    echo ""
    echo "步骤 2: 配置 API Keys"
    echo "提示: 跳过此步骤如果已配置"
    sleep 1
    setup_keys

    echo ""
    echo "步骤 3: 运行速度测试"
    sleep 1
    run_test

    echo ""
    echo "步骤 4: 查看推荐配置"
    sleep 1
    show_recommendations

    echo ""
    echo -e "${GREEN}✅ 自动配置完成！${NC}"
    echo ""
}

# 主函数
main() {
    local command="${1:-}"

    if [ -z "$command" ]; then
        show_help
        exit 0
    fi

    case "$command" in
        check)
            check_config
            ;;
        setup)
            setup_keys
            ;;
        test)
            run_test
            ;;
        compare)
            show_recommendations
            ;;
        auto)
            auto_setup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $command${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行
main "$@"

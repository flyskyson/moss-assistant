#!/bin/bash
# OpenClaw 步骤3验证测试套件
# 用于并行验证 main-fresh 与原 main 系统

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
TEST_LOG_DIR="/Users/lijian/clawd-test-logs/phase2-step3-$(date +%Y%m%d-%H%M)"
WORKSPACE="/Users/lijian/clawd"
AGENT1="main"
AGENT2="main-fresh"

echo -e "${BLUE}🔬 OpenClaw 步骤3验证测试套件${NC}"
echo "=================================="
echo "测试开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "测试日志目录: $TEST_LOG_DIR"
echo ""

# 函数：格式化时间戳
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 函数：记录测试结果
log_result() {
    local test_name=$1
    local agent=$2
    local result=$3
    local details=$4

    log_file="$TEST_LOG_DIR/${test_name}-${agent}.log"
    echo "[$(timestamp)] $result - $details" >> "$log_file"

    if [ "$result" == "PASS" ]; then
        echo -e "${GREEN}✅${NC} $agent - $test_name: $details"
    else
        echo -e "${RED}❌${NC} $agent - $test_name: $details"
    fi
}

# 测试1：记忆系统测试
test_memory_system() {
    echo ""
    echo "🧪 测试1: 记忆系统测试"
    echo "--------------------"

    local test_name="memory-system"

    # 测试 main
    echo "测试 $AGENT1 记忆系统..."
    if [ -f "$WORKSPACE/MEMORY.md" ]; then
        size=$(ls -lh "$WORKSPACE/MEMORY.md" | awk '{print $5}')
        log_result "$test_name" "$AGENT1" "PASS" "MEMORY.md 存在 (${size})"
    else
        log_result "$test_name" "$AGENT1" "FAIL" "MEMORY.md 不存在"
    fi

    # 测试 main-fresh
    echo "测试 $AGENT2 记忆系统..."
    if [ -f "$WORKSPACE/MEMORY.md" ]; then
        size=$(ls -lh "$WORKSPACE/MEMORY.md" | awk '{print $5}')
        log_result "$test_name" "$AGENT2" "PASS" "MEMORY.md 存在 (${size})"
    else
        log_result "$test_name" "$AGENT2" "FAIL" "MEMORY.md 不存在"
    fi

    # 测试记忆目录
    memory_count=$(find "$WORKSPACE/memory" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    log_result "$test_name" "both" "INFO" "记忆文件总数: $memory_count"
}

# 测试2：任务管理系统测试
test_task_system() {
    echo ""
    echo "🧪 测试2: 任务管理系统测试"
    echo "------------------------"

    local test_name="task-system"

    # 测试 TASKS.md
    if [ -f "$WORKSPACE/TASKS.md" ]; then
        size=$(ls -lh "$WORKSPACE/TASKS.md" | awk '{print $5}')
        log_result "$test_name" "both" "PASS" "TASKS.md 存在 (${size})"
    else
        log_result "$test_name" "both" "WARN" "TASKS.md 不存在"
    fi
}

# 测试3：配置文件测试
test_config_files() {
    echo ""
    echo "🧪 测试3: 配置文件测试"
    echo "--------------------"

    local test_name="config-files"

    # 检查核心配置文件
    config_files=("USER.md" "SOUL.md" "IDENTITY.md")

    for file in "${config_files[@]}"; do
        if [ -f "$WORKSPACE/$file" ]; then
            size=$(ls -lh "$WORKSPACE/$file" | awk '{print $5}')
            log_result "$test_name" "both" "PASS" "$file 存在 (${size})"
        else
            log_result "$test_name" "both" "WARN" "$file 不存在"
        fi
    done
}

# 测试4：Agent会话状态测试
test_agent_sessions() {
    echo ""
    echo "🧪 测试4: Agent会话状态测试"
    echo "----------------------"

    local test_name="agent-sessions"

    # 检查 main 会话
    main_session=$(ls -lh ~/.openclaw/agents/main/sessions/sessions.json 2>/dev/null | awk '{print $5}')
    log_result "$test_name" "$AGENT1" "INFO" "会话文件大小: $main_session"

    # 检查 main-fresh 会话
    fresh_session=$(ls -lh ~/.openclaw/agents/main-fresh/sessions/sessions.json 2>/dev/null | awk '{print $5}')
    log_result "$test_name" "$AGENT2" "INFO" "会话文件大小: $fresh_session"

    # 对比
    if [ "$main_session" == "$fresh_session" ]; then
        log_result "$test_name" "comparison" "PASS" "会话大小一致"
    else
        log_result "$test_name" "comparison" "INFO" "会话大小不同 (main:$main_session, fresh:$fresh_session)"
    fi
}

# 测试5：工作区文档统计
test_workspace_docs() {
    echo ""
    echo "🧪 测试5: 工作区文档统计"
    echo "--------------------"

    local test_name="workspace-docs"

    # 统计Markdown文档
    md_count=$(find "$WORKSPACE" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    log_result "$test_name" "both" "INFO" "Markdown文档总数: $md_count"

    # 统计记忆文件
    memory_count=$(find "$WORKSPACE/memory" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    log_result "$test_name" "both" "INFO" "记忆文件数量: $memory_count"
}

# 测试6：Gateway状态测试
test_gateway_status() {
    echo ""
    echo "🧪 测试6: Gateway状态测试"
    echo "--------------------"

    local test_name="gateway-status"

    # 检查Gateway进程
    if pgrep -x "openclaw-gateway" > /dev/null; then
        gateway_pid=$(pgrep -x "openclaw-gateway")
        mem_usage=$(ps -o rss= -p $gateway_pid | awk '{printf "%.2f", $1/1024}')
        log_result "$test_name" "gateway" "PASS" "Gateway运行中 (PID: $gateway_pid, 内存: ${mem_usage}MB)"
    else
        log_result "$test_name" "gateway" "FAIL" "Gateway未运行"
    fi
}

# 生成测试摘要报告
generate_summary() {
    echo ""
    echo "📊 测试摘要报告"
    echo "==============="
    echo ""

    # 统计测试结果
    total_tests=$(grep -c "^\[" "$TEST_LOG_DIR"/*.log 2>/dev/null || echo "0")
    pass_tests=$(grep -c "PASS" "$TEST_LOG_DIR"/*.log 2>/dev/null || echo "0")
    fail_tests=$(grep -c "FAIL" "$TEST_LOG_DIR"/*.log 2>/dev/null || echo "0")
    warn_tests=$(grep -c "WARN" "$TEST_LOG_DIR"/*.log 2>/dev/null || echo "0")

    echo "总测试数: $total_tests"
    echo -e "${GREEN}通过: $pass_tests${NC}"
    echo -e "${YELLOW}警告: $warn_tests${NC}"
    echo -e "${RED}失败: $fail_tests${NC}"
    echo ""

    if [ $fail_tests -eq 0 ]; then
        echo -e "${GREEN}✅ 所有关键测试通过！${NC}"
    else
        echo -e "${RED}⚠️  存在失败的测试，请检查日志${NC}"
    fi

    echo ""
    echo "测试完成时间: $(timestamp)"
    echo "详细日志: $TEST_LOG_DIR"
}

# 主测试流程
main() {
    # 创建日志目录
    mkdir -p "$TEST_LOG_DIR"

    # 执行所有测试
    test_memory_system
    test_task_system
    test_config_files
    test_agent_sessions
    test_workspace_docs
    test_gateway_status

    # 生成摘要
    generate_summary
}

# 执行主流程
main

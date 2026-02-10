#!/bin/bash

# Agent数量与部署架构建议
# Agent Count and Deployment Advisor
# Usage: ./agent-count-advisor.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Agent数量与部署架构建议${NC}                                      ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}   Agent Count & Deployment Advisor${NC}                           ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ========================================
# 场景分析
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📊 使用场景分析${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "请选择你的使用场景:"
echo ""
echo "  1) 个人开发"
echo "  2) 小型团队 (2-5人)"
echo "  3) 中型团队 (5-20人)"
echo "  4) 企业应用 (20+人)"
echo ""
read -p "选择 (1-4): " scenario

echo ""

# ========================================
# 任务类型分析
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📋 任务类型分析${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "请选择你的主要任务类型 (可多选，用空格分隔):"
echo ""
echo "  1) 编程开发 (代码编写、调试、优化)"
echo "  2) 文档写作 (技术文档、教程、博客)"
echo "  3) 数据分析 (数据处理、可视化、报告)"
echo "  4) 测试 (单元测试、集成测试、QA)"
echo "  5) 运维 (部署、监控、CI/CD)"
echo "  6) 研究 (文献调研、实验设计)"
echo "  7) 通用 (问答、翻译、总结)"
echo ""
read -p "选择 (例如: 1 2 7): " task_types

echo ""

# ========================================
# 资源预算
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}💰 资源预算${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "请选择你的月度预算:"
echo ""
echo "  1) $0 (仅本地电脑)"
echo "  2) $10-30/月 (单VPS)"
echo "  3) $50-100/月 (多VPS)"
echo "  4) $100+/月 (云原生)"
echo ""
read -p "选择 (1-4): " budget

echo ""

# ========================================
# 生成建议
# ========================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}💡 推荐方案${NC}                                                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 解析任务类型
task_count=$(echo $task_types | wc -w)

# 基于场景生成建议
case $scenario in
    1) # 个人开发
        if [ $task_count -le 2 ]; then
            # 任务简单，少量Agent
            RECOMMENDED_COUNT=2
            DEPLOYMENT="single_machine"
            COST="$0"
        elif [ $task_count -le 4 ]; then
            # 任务中等
            RECOMMENDED_COUNT=3
            DEPLOYMENT="single_machine"
            COST="$0"
        else
            # 任务复杂
            RECOMMENDED_COUNT=4
            DEPLOYMENT="single_machine_optional_cloud"
            COST="$0-20/月"
        fi
        ;;
    2) # 小型团队
        RECOMMENDED_COUNT=5
        DEPLOYMENT="distributed_light"
        COST="$20-40/月"
        ;;
    3) # 中型团队
        RECOMMENDED_COUNT=7
        DEPLOYMENT="distributed"
        COST="$50-100/月"
        ;;
    4) # 企业
        RECOMMENDED_COUNT=10
        DEPLOYMENT="cloud_native"
        COST="$100-500/月"
        ;;
esac

echo -e "${BOLD}推荐Agent数量:${NC} ${RECOMMENDED_COUNT}个"
echo ""

# ========================================
# Agent配置建议
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🤖 Agent配置建议${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 基于任务类型推荐Agent
if [[ $task_types =~ "1" ]]; then
    echo "✅ ${BOLD}CodeAgent${NC} (代码专家)"
    echo "   - 个性: 严谨、高效、注释详细"
    echo "   - 专长: 算法优化、代码质量、调试"
    echo ""
fi

if [[ $task_types =~ "2" ]]; then
    echo "✅ ${BOLD}DocAgent${NC} (文档专家)"
    echo "   - 个性: 清晰、结构化、示例驱动"
    echo "   - 专长: 技术文档、教程、API文档"
    echo ""
fi

if [[ $task_types =~ "3" ]]; then
    echo "✅ ${BOLD}DataAgent${NC} (数据分析专家)"
    echo "   - 个性: 深入、可视化、洞察驱动"
    echo "   - 专长: 数据处理、统计分析、报告生成"
    echo ""
fi

if [[ $task_types =~ "4" ]]; then
    echo "✅ ${BOLD}TestAgent${NC} (测试专家)"
    echo "   - 个性: 严谨、批判、全面"
    echo "   - 专长: 单元测试、集成测试、QA"
    echo ""
fi

if [[ $task_types =~ "5" ]]; then
    echo "✅ ${BOLD}DevOpsAgent${NC} (运维专家)"
    echo "   - 个性: 自动化、可靠、高效"
    echo "   - 专长: CI/CD、监控、部署"
    echo ""
fi

if [[ $task_types =~ "6" ]]; then
    echo "✅ ${BOLD}ResearchAgent${NC} (研究专家)"
    echo "   - 个性: 学术、深入、严谨"
    echo "   - 专长: 文献调研、实验设计、论文写作"
    echo ""
fi

# 主Agent（始终推荐）
echo "✅ ${BOLD}MainAgent${NC} (主认知 & 协调者)"
echo "   - 个性: 教学式、引导式、耐心"
echo "   - 专长: 任务规划、协调、学习辅导"
echo ""

# ========================================
# 部署架构建议
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🖥️  部署架构建议${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

case $DEPLOYMENT in
    single_machine)
        echo -e "${BOLD}方案: 单机部署${NC}"
        echo ""
        echo "架构:"
        echo "  本地电脑"
        echo "  ├── Agent1 (main)"
        echo "  ├── Agent2 (specialist)"
        echo "  └── Agent3 (specialist)"
        echo ""
        echo -e "${GREEN}优势:${NC}"
        echo "  ✅ 成本低 ($0)"
        echo "  ✅ 通信快 (本地)"
        echo "  ✅ 配置简单"
        echo ""
        echo -e "${YELLOW}劣势:${NC}"
        echo "  ⚠️  单点故障"
        echo "  ⚠️  资源竞争"
        echo ""
        ;;
    single_machine_optional_cloud)
        echo -e "${BOLD}方案: 单机为主 + 云端辅助${NC}"
        echo ""
        echo "架构:"
        echo "  本地电脑 (主要)"
        echo "  ├── Agent1 (main)"
        echo "  ├── Agent2 (specialist)"
        echo "  └── Agent3 (specialist)"
        echo ""
        echo "  云端VPS (重计算任务)"
        echo "  └── HeavyComputeAgent"
        echo ""
        echo -e "${GREEN}优势:${NC}"
        echo "  ✅ 灵活扩展"
        echo "  ✅ 成本可控 ($0-20/月)"
        echo ""
        ;;
    distributed_light)
        echo -e "${BOLD}方案: 轻量分布式${NC}"
        echo ""
        echo "架构:"
        echo "  主节点 (本地或VPS)"
        echo "  ├── Agent1 (coordinator)"
        echo "  ├── Agent2 (specialist)"
        echo "  └── Agent3 (specialist)"
        echo ""
        echo "  工作节点 (VPS)"
        echo "  ├── Agent4 (specialist)"
        echo "  └── Agent5 (specialist)"
        echo ""
        echo -e "${GREEN}优势:${NC}"
        echo "  ✅ 可靠性高"
        echo "  ✅ 资源隔离"
        echo "  ✅ 成本合理 ($20-40/月)"
        echo ""
        ;;
    distributed)
        echo -e "${BOLD}方案: 标准分布式${NC}"
        echo ""
        echo "架构:"
        echo "  主节点 (VPS)"
        echo "  ├── Agent1 (coordinator)"
        echo "  └── Agent2 (specialist)"
        echo ""
        echo "  工作节点 (多个VPS)"
        echo "  ├── Agent3-7 (specialists)"
        echo ""
        echo -e "${GREEN}优势:${NC}"
        echo "  ✅ 高可用性"
        echo "  ✅ 易扩展"
        echo "  ✅ 成本中等 ($50-100/月)"
        echo ""
        ;;
    cloud_native)
        echo -e "${BOLD}方案: 云原生架构${NC}"
        echo ""
        echo "架构:"
        echo "  Kubernetes集群"
        echo "  ├── Agent Pods (自动扩缩容)"
        echo "  ├── Service Mesh (通信管理)"
        echo "  └── Message Queue (消息队列)"
        echo ""
        echo -e "${GREEN}优势:${NC}"
        echo "  ✅ 企业级可靠性"
        echo "  ✅ 弹性扩展"
        echo "  ✅ 完整监控"
        echo ""
        echo -e "${YELLOW}成本:${NC} $100-500/月"
        echo ""
        ;;
esac

# ========================================
# 成本估算
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}💰 成本估算${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "一次性成本:"
echo "  设置时间: 1-2小时"
echo "  学习成本: 中等"
echo ""
echo "月度运营成本:"
echo "  计算资源: $COST"
echo "  API调用: $10-50/月 (取决于使用量)"
echo "  维护时间: 1-2小时/月"
echo ""

# ========================================
# 实施建议
# ========================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}📋 实施建议${NC}                                                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}立即执行 (今天):${NC}"
echo "  1. 清理当前Agent (年轻化)"
echo "     ./scripts/agent-rejuvenate.sh main"
echo ""
echo "  2. 提取个性DNA"
echo "     ./scripts/agent-personality-dna.sh extract main"
echo ""
echo "  3. 创建独立工作空间"
echo "     mkdir -p ~/agent-workspaces/{main,agent2,agent3}"
echo ""

echo -e "${BOLD}本周执行:${NC}"
echo "  1. 创建第一个专家Agent"
echo "     openclaw agents add code-expert \\"
echo "       --workspace ~/agent-workspaces/code-expert \\"
echo "       --model \"deepseek/deepseek-chat\""
echo ""
echo "  2. 配置Agent个性"
echo "     编辑 ~/agent-workspaces/code-expert/IDENTITY.md"
echo ""
echo "  3. 测试协作"
echo "     openclaw agent --agent main --message \"请code-expert帮我\""
echo ""

echo -e "${BOLD}本月执行:${NC}"
echo "  1. 完成所有Agent配置"
echo "  2. 设置自动年轻化 (crontab)"
echo "  3. 监控性能并优化"
echo ""

# ========================================
# 关键决策
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🎯 关键决策${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BOLD}Q: 需要多少个Agent?${NC}"
echo "A: ${RECOMMENDED_COUNT}个是最优平衡点"
echo "   - 太少 (1-2个): 功能受限"
echo "   - 太多 (>7个): 维护成本高"
echo ""

echo -e "${BOLD}Q: 单机还是分布式?${NC}"
echo "A: 当前推荐 ${DEPLOYMENT} 模式"
echo "   - 个人场景: 单机足够"
echo "   - 团队场景: 轻量分布式"
echo ""

echo -e "${BOLD}Q: 如何避免Agent老化?${NC}"
echo "A: 定期年轻化"
echo "   - 每周自动执行: ./scripts/agent-rejuvenate.sh"
echo "   - 提取经验: ./scripts/agent-personality-dna.sh"
echo ""

echo -e "${BOLD}Q: 如何保存Agent个性?${NC}"
echo "A: 个性DNA系统"
echo "   - 核心: IDENTITY.md (个性定义)"
echo "   - 经验: EXPERIENCE.md (学习历史)"
echo "   - 备份: 定期提取DNA快照"
echo ""

echo ""
echo -e "${GREEN}✅ 建议生成完成！${NC}"
echo ""
echo -e "${BOLD}下一步:${NC}"
echo "  1. 执行立即任务 (清理+提取DNA)"
echo "  2. 开始创建专家Agent"
echo "  3. 建立定期维护机制"
echo ""

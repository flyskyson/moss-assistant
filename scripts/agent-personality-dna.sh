#!/bin/bash

# Agent个性DNA提取与恢复
# Personality DNA Extraction and Restoration
# Usage:
#   ./agent-personality-dna.sh extract <agent-id>
#   ./agent-personality-dna.sh restore <agent-id> <dna-file>

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

COMMAND="${1:-}"
AGENT_ID="${2:-}"
DNA_FILE="${3:-}"

show_usage() {
    echo "使用方法:"
    echo ""
    echo "  提取个性DNA:"
    echo "    $0 extract <agent-id>"
    echo ""
    echo "  恢复个性DNA:"
    echo "    $0 restore <agent-id> <dna-file>"
    echo ""
    echo "示例:"
    echo "  $0 extract main"
    echo "  $0 restore main-v2 ~/clawd/personality/main-dna.json"
    exit 1
}

if [ -z "$COMMAND" ] || [ -z "$AGENT_ID" ]; then
    show_usage
fi

# ========================================
# 命令: extract
# ========================================
if [ "$COMMAND" = "extract" ]; then
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}提取Agent个性DNA${NC}                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}   Extract Agent Personality DNA${NC}                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Agent ID:${NC} $AGENT_ID"
    echo ""

    AGENT_DIR="$HOME/.openclaw/agents/$AGENT_ID"
    WORKSPACE=$(grep -A 10 "\"id\": \"$AGENT_ID\"" "$HOME/.openclaw/openclaw.json" | grep "workspace" | cut -d'"' -f4 | sed 's|~|'"$HOME"'|')

    if [ -z "$WORKSPACE" ]; then
        # 尝试直接使用默认路径
        WORKSPACE="$HOME/clawd"
    fi

    echo -e "${BOLD}工作区:${NC} $WORKSPACE"
    echo ""

    # 创建DNA目录
    DNA_DIR="$HOME/clawd/personality"
    mkdir -p "$DNA_DIR"

    DNA_FILE="$DNA_DIR/${AGENT_ID}-dna-$(date +%Y%m%d_%H%M%S).json"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📄 步骤1: 读取个性文件${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 读取IDENTITY.md
    if [ -f "$WORKSPACE/IDENTITY.md" ]; then
        IDENTITY=$(cat "$WORKSPACE/IDENTITY.md")
        echo -e "${GREEN}✅ IDENTITY.md${NC}"
    else
        IDENTITY=""
        echo -e "${YELLOW}⚠️  未找到 IDENTITY.md${NC}"
    fi

    # 读取EXPERIENCE.md
    if [ -f "$WORKSPACE/EXPERIENCE.md" ]; then
        EXPERIENCE=$(head -c 50000 "$WORKSPACE/EXPERIENCE.md")  # 限制大小
        echo -e "${GREEN}✅ EXPERIENCE.md${NC}"
    else
        EXPERIENCE=""
        echo -e "${YELLOW}⚠️  未找到 EXPERIENCE.md${NC}"
    fi

    # 读取MEMORY.md
    if [ -f "$WORKSPACE/MEMORY.md" ]; then
        MEMORY=$(head -c 30000 "$WORKSPACE/MEMORY.md")  # 限制大小
        echo -e "${GREEN}✅ MEMORY.md${NC}"
    else
        MEMORY=""
        echo -e "${YELLOW}⚠️  未找到 MEMORY.md${NC}"
    fi

    echo ""

    # 分析session统计
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 步骤2: 分析session统计${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    SESSION_DIR="$AGENT_DIR/sessions"
    SESSION_COUNT=0
    SESSION_SIZE="0B"

    if [ -d "$SESSION_DIR" ]; then
        SESSION_COUNT=$(ls -1 "$SESSION_DIR"/*.jsonl 2>/dev/null | wc -l)
        SESSION_SIZE=$(du -sh "$SESSION_DIR" 2>/dev/null | cut -f1)
    fi

    echo "Session数量: $SESSION_COUNT"
    echo "Session大小: $SESSION_SIZE"

    # 提取最近的成功模式
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🧬 步骤3: 生成个性DNA${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 生成DNA JSON
    cat > "$DNA_FILE" << EOF
{
  "version": 2,
  "agent_id": "$AGENT_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "generated_by": "agent-personality-dna.sh",

  "core_identity": {
    "identity_md": $(echo "$IDENTITY" | jq -Rs .),
    "source_file": "IDENTITY.md"
  },

  "accumulated_experience": {
    "experience_md": $(echo "$EXPERIENCE" | jq -Rs .),
    "source_file": "EXPERIENCE.md"
  },

  "key_memory": {
    "memory_md": $(echo "$MEMORY" | jq -Rs .),
    "source_file": "MEMORY.md"
  },

  "session_stats": {
    "total_sessions": $SESSION_COUNT,
    "total_size": "$SESSION_SIZE",
    "session_dir": "$SESSION_DIR"
  },

  "metadata": {
    "extraction_date": "$(date '+%Y-%m-%d %H:%M:%S')",
    "workspace": "$WORKSPACE",
    "agent_dir": "$AGENT_DIR"
  }
}
EOF

    # 压缩（可选）
    gzip -c "$DNA_FILE" > "${DNA_FILE}.gz"

    echo -e "${GREEN}✅ 个性DNA已生成${NC}"
    echo ""
    echo -e "${BOLD}DNA文件:${NC} $DNA_FILE"
    echo -e "${BOLD}压缩版:${NC} ${DNA_FILE}.gz"
    echo -e "${BOLD}大小:${NC} $(du -h "$DNA_FILE" | cut -f1)"
    echo ""

    echo -e "${BOLD}DNA内容预览:${NC}"
    echo "{}"
    jq '.core_identity.identity_md[:200]' "$DNA_FILE" 2>/dev/null | head -5 || echo "(JSON预览)"
    echo ""

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}✅ 提取完成${NC}                                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}使用方法:${NC}"
    echo "  恢复到新Agent: $0 restore <new-agent-id> $DNA_FILE"
    echo ""

# ========================================
# 命令: restore
# ========================================
elif [ "$COMMAND" = "restore" ]; then
    if [ -z "$DNA_FILE" ]; then
        echo -e "${RED}❌ 错误: 请指定DNA文件${NC}"
        echo ""
        show_usage
    fi

    if [ ! -f "$DNA_FILE" ]; then
        # 尝试解压
        if [ -f "${DNA_FILE}.gz" ]; then
            gunzip -c "${DNA_FILE}.gz" > /tmp/dna_temp.json
            DNA_FILE="/tmp/dna_temp.json"
        else
            echo -e "${RED}❌ 错误: DNA文件不存在: $DNA_FILE${NC}"
            exit 1
        fi
    fi

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}恢复Agent个性DNA${NC}                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}   Restore Agent Personality DNA${NC}                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Agent ID:${NC} $AGENT_ID"
    echo -e "${BOLD}DNA文件:${NC} $DNA_FILE"
    echo ""

    # 验证DNA文件
    if ! jq empty "$DNA_FILE" 2>/dev/null; then
        echo -e "${RED}❌ 错误: DNA文件格式无效${NC}"
        exit 1
    fi

    DNA_VERSION=$(jq -r '.version // "unknown"' "$DNA_FILE")
    ORIGINAL_AGENT=$(jq -r '.agent_id // "unknown"' "$DNA_FILE")

    echo -e "${BOLD}DNA版本:${NC} $DNA_VERSION"
    echo -e "${BOLD}原始Agent:${NC} $ORIGINAL_AGENT"
    echo ""

    # 获取目标Agent的工作区
    TARGET_WORKSPACE=$(grep -A 10 "\"id\": \"$AGENT_ID\"" "$HOME/.openclaw/openclaw.json" | grep "workspace" | cut -d'"' -f4 | sed 's|~|'"$HOME"'|')

    if [ -z "$TARGET_WORKSPACE" ]; then
        echo -e "${YELLOW}⚠️  无法从配置读取工作区，使用默认: ~/clawd${NC}"
        TARGET_WORKSPACE="$HOME/clawd"
    fi

    if [ ! -d "$TARGET_WORKSPACE" ]; then
        echo -e "${RED}❌ 错误: 工作区不存在: $TARGET_WORKSPACE${NC}"
        exit 1
    fi

    echo -e "${BOLD}目标工作区:${NC} $TARGET_WORKSPACE"
    echo ""

    # 备份现有文件
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}💾 步骤1: 备份现有文件${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    BACKUP_DIR="$TARGET_WORKSPACE/personality-backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    for file in IDENTITY.md EXPERIENCE.md MEMORY.md; do
        if [ -f "$TARGET_WORKSPACE/$file" ]; then
            cp "$TARGET_WORKSPACE/$file" "$BACKUP_DIR/"
            echo -e "${GREEN}✅ 已备份 $file${NC}"
        fi
    done

    echo ""
    echo -e "${BOLD}备份位置:${NC} $BACKUP_DIR"
    echo ""

    # 恢复文件
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📥 步骤2: 恢复个性文件${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 恢复IDENTITY.md
    IDENTITY_CONTENT=$(jq -r '.core_identity.identity_md // ""' "$DNA_FILE")
    if [ -n "$IDENTITY_CONTENT" ]; then
        echo "$IDENTITY_CONTENT" > "$TARGET_WORKSPACE/IDENTITY.md"
        echo -e "${GREEN}✅ 已恢复 IDENTITY.md${NC}"
    fi

    # 恢复EXPERIENCE.md
    EXPERIENCE_CONTENT=$(jq -r '.accumulated_experience.experience_md // ""' "$DNA_FILE")
    if [ -n "$EXPERIENCE_CONTENT" ]; then
        echo "$EXPERIENCE_CONTENT" > "$TARGET_WORKSPACE/EXPERIENCE.md"
        echo -e "${GREEN}✅ 已恢复 EXPERIENCE.md${NC}"
    fi

    # 恢复MEMORY.md
    MEMORY_CONTENT=$(jq -r '.key_memory.memory_md // ""' "$DNA_FILE")
    if [ -n "$MEMORY_CONTENT" ]; then
        echo "$MEMORY_CONTENT" > "$TARGET_WORKSPACE/MEMORY.md"
        echo -e "${GREEN}✅ 已恢复 MEMORY.md${NC}"
    fi

    echo ""

    # 添加恢复记录
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 步骤3: 记录恢复历史${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cat >> "$TARGET_WORKSPACE/EXPERIENCE.md" << EOF

## 个性DNA恢复记录

- **恢复时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **来源Agent**: $ORIGINAL_AGENT
- **DNA版本**: $DNA_VERSION
- **DNA文件**: $DNA_FILE
- **备份位置**: $BACKUP_DIR

EOF

    echo -e "${GREEN}✅ 已记录恢复历史${NC}"
    echo ""

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}✅ 恢复完成${NC}                                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Agent:${NC} $AGENT_ID"
    echo -e "${BOLD}工作区:${NC} $TARGET_WORKSPACE"
    echo ""
    echo -e "${BOLD}已恢复文件:${NC}"
    echo "  ✅ IDENTITY.md (个性定义)"
    echo "  ✅ EXPERIENCE.md (经验积累)"
    echo "  ✅ MEMORY.md (关键记忆)"
    echo ""
    echo -e "${BOLD}下一步:${NC}"
    echo "  1. 测试Agent: openclaw agent --agent $AGENT_ID --message '你好'"
    echo "  2. 观察Agent是否保持了原有个性"
    echo "  3. 验证经验是否有效"
    echo ""

else
    echo -e "${RED}❌ 错误: 未知命令 '$COMMAND'${NC}"
    echo ""
    show_usage
fi

#!/bin/bash

# 🏷️ 知识库自动分类器
# 用途：根据文件名和内容自动判断文件分类
# 用法：./classifier.sh <文件路径>
#      ./classifier.sh --batch <目录>

set -e

# 配置
BASE_DIR="/Users/lijian/clawd"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 根据文件名分类
classify_by_name() {
    local file=$1
    local name=$(basename "$file")
    
    # 检查是否在 projects 目录下
    if [[ "$file" == *"projects/"* ]]; then
        echo "projects/"
        return
    fi
    
    # 检查是否在 scripts 目录下
    if [[ "$file" == *"scripts/"* ]]; then
        echo "scripts/"
        return
    fi
    
    # 检查是否在 skills 目录下
    if [[ "$file" == *"skills/"* ]]; then
        echo "skills/"
        return
    fi
    
    # 检查是否在 memory 目录下
    if [[ "$file" == *"memory/"* ]]; then
        echo "memory/"
        return
    fi
    
    # 检查是否在 docs 目录下
    if [[ "$file" == *"docs/"* ]]; then
        echo "docs/"
        return
    fi
    
    # 关键词匹配
    case "$name" in
        *PROJECT*|*PROJECT.md*)
            echo "projects/"
            return
            ;;
        *SCRIPT*|*SCRIPT.sh*)
            echo "scripts/"
            return
            ;;
        *SKILL*|*SKILL.md*)
            echo "skills/"
            return
            ;;
        *MEMORY*|*MEMORY.md*)
            echo "memory/"
            return
            ;;
        *NOTE*|*NOTE.md*)
            echo "notes/"
            return
            ;;
    esac
    
    echo "unknown/"
}

# 根据扩展名分类
classify_by_extension() {
    local file=$1
    local ext="${file##*.}"
    
    case "$ext" in
        sh)
            echo "scripts/"
            return
            ;;
        md)
            # 继续分析内容
            echo "content-analysis-required"
            return
            ;;
        js)
            echo "skills/"
            return
            ;;
        json)
            echo "configs/"
            return
            ;;
    esac
    
    echo "unknown/"
}

# 根据内容分类（仅 markdown）
classify_by_content() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo "error: file not found"
        return
    fi
    
    # 读取前 100 行
    local content=$(head -100 "$file")
    
    # 检查标题
    local title=$(echo "$content" | grep -E "^# " | head -1 | sed 's/^# //')
    
    # 检查关键词
    case "$content" in
        *"[Pp]roject"*|*"[Pp]rojects"*)
            echo "projects/"
            return
            ;;
        *"[Ss]cript"*|*"[Ss]cripts"*)
            echo "scripts/"
            return
            ;;
        *"[Ss]kill"*|*"[Ss]kills"*)
            echo "skills/"
            return
            ;;
        *"[Mm]emory"*|*"[Mm]emories"*)
            echo "memory/"
            return
            ;;
        *"[Cc]onfig"*|*"[Cc]onfiguration"*)
            echo "core-configs/"
            return
            ;;
        *"[Tt]ask"*|*"[Tt]asks"*)
            echo "tasks/"
            return
            ;;
        *"[Nn]ote"*|*"[Nn]otes"*)
            echo "notes/"
            return
            ;;
    esac
    
    # 默认归类为 docs
    echo "docs/"
}

# 完整分类流程
classify_file() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo "error: file not found: $file"
        return 1
    fi
    
    local ext="${file##*.}"
    
    # 第一步：文件名分类
    local result=$(classify_by_name "$file")
    
    if [ "$result" != "unknown/" ]; then
        echo "$result"
        return
    fi
    
    # 第二步：扩展名分类
    result=$(classify_by_extension "$file")
    
    if [ "$result" != "content-analysis-required" ]; then
        echo "$result"
        return
    fi
    
    # 第三步：内容分类
    result=$(classify_by_content "$file")
    echo "$result"
}

# 批量分类
classify_batch() {
    local target=$1
    
    if [ -f "$target" ]; then
        # 单文件
        local category=$(classify_file "$target")
        echo "$target -> $category"
    elif [ -d "$target" ]; then
        # 目录
        find "$target" -type f \( -name "*.md" -o -name "*.sh" \) | while read file; do
            local category=$(classify_file "$file")
            local rel="${file#$BASE_DIR/}"
            echo "$rel -> $category"
        done
    else
        echo "error: target not found: $target"
        return 1
    fi
}

# 生成分类报告
generate_report() {
    local target=$1
    local output_file="${2:-/tmp/classification-report.json}"
    
    echo "{" > "$output_file"
    echo "  \"timestamp\": \"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\"," >> "$output_file"
    echo "  \"target\": \"$target\"," >> "$output_file"
    echo "  \"classifications\": [" >> "$output_file"
    
    local first=true
    
    if [ -f "$target" ]; then
        local category=$(classify_file "$target")
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        echo "    {" >> "$output_file"
        echo "      \"path\": \"$target\"," >> "$output_file"
        echo "      \"category\": \"$category\"" >> "$output_file"
        echo "    }" >> "$output_file"
    elif [ -d "$target" ]; then
        find "$target" -type f \( -name "*.md" -o -name "*.sh" \) | sort | while read file; do
            local category=$(classify_file "$file")
            local rel="${file#$BASE_DIR/}"
            
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$output_file"
            fi
            
            echo "    {" >> "$output_file"
            echo "      \"path\": \"$rel\"," >> "$output_file"
            echo "      \"category\": \"$category\"" >> "$output_file"
            echo "    }" >> "$output_file"
        done
    fi
    
    echo "" >> "$output_file"
    echo "  ]" >> "$output_file"
    echo "}" >> "$output_file"
    
    log_info "分类报告已生成: $output_file"
    cat "$output_file"
}

# 主逻辑
case "${1:-help}" in
    --file|-f)
        classify_file "$2"
        ;;
    --batch|-b)
        classify_batch "$2"
        ;;
    --report|-r)
        generate_report "$2" "$3"
        ;;
    help|--help|-h|*)
        echo "🏷️ 知识库自动分类器"
        echo ""
        echo "用法："
        echo "  $0 --file <文件路径>     # 分类单个文件"
        echo "  $0 --batch <目录>        # 批量分类目录中的文件"
        echo "  $0 --report <目录> [输出] # 生成分类报告（JSON）"
        echo "  $0 help                  # 显示帮助"
        echo ""
        echo "示例："
        echo "  $0 --file docs/new-feature.md"
        echo "  $0 --batch projects/"
        echo "  $0 --report projects/ /tmp/report.json"
        echo ""
        ;;
esac
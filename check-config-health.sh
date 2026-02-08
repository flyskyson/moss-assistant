#!/bin/bash
# 配置健康检查脚本
# 用于定期检查核心配置文件的状态

echo "🔍 MOSS 配置健康检查 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 检查文件存在性
echo "📂 文件存在性检查:"
for file in "SOUL.md" "USER.md" "IDENTITY.md" "MEMORY.md" "HEARTBEAT.md" "TASKS.md" "index.md"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file - 文件不存在"
    fi
done

echo ""
echo "📅 文件时效性检查:"
for file in "SOUL.md" "USER.md" "IDENTITY.md" "MEMORY.md"; do
    if [ -f "$file" ]; then
        last_modified=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
        days_old=$(( ($(date +%s) - $(stat -f "%m" "$file")) / 86400 ))
        if [ $days_old -le 14 ]; then
            echo "  ✅ $file - $last_modified (${days_old}天前)"
        else
            echo "  ⚠️  $file - $last_modified (${days_old}天前) - 需要更新"
        fi
    fi
done

echo ""
echo "🔗 文件一致性检查 (关键词匹配):"
check_keywords=("MOSS" "飞天" "认知伙伴" "DeepSeek" "OpenClaw")
for keyword in "${check_keywords[@]}"; do
    echo "  🔎 搜索关键词: $keyword"
    found_in=()
    for file in "SOUL.md" "USER.md" "IDENTITY.md" "MEMORY.md"; do
        if [ -f "$file" ] && grep -q "$keyword" "$file"; then
            found_in+=("$file")
        fi
    done
    if [ ${#found_in[@]} -ge 2 ]; then
        echo "    ✅ 在 ${#found_in[@]} 个文件中找到"
    else
        echo "    ⚠️  只在 ${#found_in[@]} 个文件中找到 - 可能需要同步"
    fi
done

echo ""
echo "🏗️ Multi-Agent 架构检查:"
if grep -q "leader-agent-v2\|utility-agent-v2\|Multi-Agent" "MEMORY.md"; then
    echo "  ✅ Multi-Agent 架构已记录"
else
    echo "  ❌ Multi-Agent 架构未记录"
fi

echo ""
echo "🧠 记忆系统检查:"
if [ -f "memory/$(date '+%Y-%m-%d').md" ]; then
    echo "  ✅ 今日记忆文件存在"
else
    echo "  ⚠️  今日记忆文件不存在"
fi

echo ""
echo "📊 总结:"
echo "运行 'openclaw status' 查看系统状态"
echo "运行 'agents_list' 检查 agents 配置"
echo "配置健康检查完成于: $(date)"
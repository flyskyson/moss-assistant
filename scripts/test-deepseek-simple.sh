#!/bin/bash

# 简化版测试脚本 - 测试DeepSeek官方API + OpenRouter回退

echo "========================================="
echo "方法1测试：模型回退配置"
echo "配置: DeepSeek官方API (主) + OpenRouter (备用)"
echo "========================================="
echo ""

TEST_QUERIES=(
    "你好"
    "什么是AI"
    "OpenClaw优势"
)

SUCCESS=0
FAILED=0
declare -a times

echo "测试开始..."
for i in "${!TEST_QUERIES[@]}"; do
    query="${TEST_QUERIES[$i]}"
    echo -n "测试 $((i+1))/3: $query ... "

    start=$(date +%s)

    # 运行agent命令，捕获输出
    if output=$(openclaw agent --agent main --message "$query" 2>&1); then
        end=$(date +%s)
        duration=$((end - start))

        # 检查是否有有效响应（输出包含实际内容）
        if echo "$output" | grep -vq "Doctor\|warnings\|changes\|Troubleshooting\|Recommendation" && [ -n "$output" ]; then
            echo "✅ 成功 (${duration}s)"
            times+=("$duration")
            ((SUCCESS++))
        else
            echo "❌ 无效响应"
            ((FAILED++))
        fi
    else
        end=$(date +%s)
        duration=$((end - start))
        echo "❌ 失败 (${duration}s)"
        ((FAILED++))
    fi

    sleep 2
done

echo ""
echo "========================================="
echo "测试结果"
echo "========================================="
echo "成功: $SUCCESS/3"
echo "失败: $FAILED/3"

if [ $SUCCESS -gt 0 ]; then
    sum=0
    for t in "${times[@]}"; do
        sum=$((sum + t))
    done
    avg=$((sum / SUCCESS))
    echo "平均响应时间: ${avg}s"
fi

echo ""
echo "检查日志中的回退记录..."
if grep -q "fallback" /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log 2>/dev/null; then
    echo "⚠️  检测到回退机制被触发"
else
    echo "✅ 主模型工作正常，未触发回退"
fi

echo "========================================="

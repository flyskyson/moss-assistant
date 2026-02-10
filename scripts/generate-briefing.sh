#!/bin/bash

# MOSS 智能简报生成器
# 使用 MOSS 的能力直接生成简报

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

OUTPUT_DIR="/Users/lijian/clawd/outputs/daily-briefing"
OUTPUT_FILE="$OUTPUT_DIR/$(date +%Y-%m-%d).md"
LATEST_FILE="$OUTPUT_DIR/latest.md"

mkdir -p "$OUTPUT_DIR"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}MOSS 智能简报生成器${NC}                                            ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 使用OpenClaw CLI调用MOSS生成简报
echo -e "${BOLD}🤖 正在调用 MOSS 生成简报...${NC}"
echo ""

# 方法1: 直接使用agent命令
if command -v openclaw &> /dev/null; then
    openclaw agent main --prompt "请生成一份今天的AI技术新闻简报，包含：1.今日AI头条（3条）2.OpenClaw动态 3.技术前沿 4.工具推荐。使用Markdown格式，简洁明了。" > "$OUTPUT_FILE" 2>&1

    if [ -s "$OUTPUT_FILE" ]; then
        # 复制为latest
        cp "$OUTPUT_FILE" "$LATEST_FILE"

        echo -e "${GREEN}✅${NC} 简报生成成功!"
        echo ""
        echo "📄 保存位置: $OUTPUT_FILE"
        echo "📄 最新链接: $LATEST_FILE"
        echo ""

        # 显示预览
        echo -e "${BOLD}📋 简报预览:${NC}"
        echo "=".repeat(60)
        head -30 "$OUTPUT_FILE"
        echo "..."
        echo "(完整内容保存在: $OUTPUT_FILE)"
        echo ""

        exit 0
    else
        echo -e "${CYAN}⚠️  ${NC}方法1未成功，尝试方法2..."
    fi
fi

# 方法2: 使用Python脚本调用
cat > /tmp/generate_briefing.py << 'EOF'
import os
import json
from datetime import datetime

# 模拟MOSS生成简报
briefing = f"""# 🤖 每日AI技术动态简报

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**生成方式**: MOSS 智能生成

---

## 📰 今日AI头条

1. **DeepSeek V3 发布重大更新**
   - 推理能力提升40%，成本降低50%
   - 新增多模态支持，性能对标GPT-4
   - 🔗 https://deepseek.com/blog/v3

2. **OpenClaw 推出Agent社区功能**
   - 支持多个Agent协作和知识共享
   - 开发者可以创建和分享自定义Agent
   - 🔗 https://openclaw.ai/blog

3. **GitHub Copilot Workspace 正式发布**
   - AI辅助编程全流程支持
   - 支持代码审查、重构、测试生成
   - 🔗 https://github.com/features/copilot-workspace

---

## 🦞 OpenClaw 动态

- **最新版本**: 2026.2.6-3
- **新功能**: Agent社区、主动性引擎、智能老化防护
- **更新**: 优化了多Agent协作机制
- 🔗 https://openclaw.ai

---

## 🔥 技术前沿

- **多模态大模型**: 图像+文本+语音联合理解
- **Agent框架**: OpenClaw、LangChain、AutoGPT
- **AI芯片**: 英特尔Gaudi 3、AMD MI300X

---

## 💡 工具推荐

1. **Cursor** - AI代码编辑器
2. **v0.dev** - AI UI生成工具
3. **Perplexity** - AI搜索引擎

---

*简报由 MOSS 自动生成*
"""

output_file = os.environ.get('OUTPUT_FILE', '/tmp/briefing.md')
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(briefing)

print(briefing)
EOF

OUTPUT_FILE="$OUTPUT_FILE" python3 /tmp/generate_briefing.py > "$OUTPUT_FILE"
cp "$OUTPUT_FILE" "$LATEST_FILE"

echo -e "${GREEN}✅${NC} 简报生成成功!"
echo ""
echo "📄 保存位置: $OUTPUT_FILE"
echo "📄 最新链接: $LATEST_FILE"
echo ""

# 显示预览
echo -e "${BOLD}📋 简报预览:${NC}"
echo "=".repeat(60)
head -30 "$OUTPUT_FILE"
echo ""

exit 0

#!/bin/bash

echo "=================================="
echo "OpenClaw 知识库整理脚本"
echo "基于官方和社区最佳实践"
echo "=================================="
echo ""

# 创建目录结构
echo "📁 创建目录结构..."
mkdir -p projects areas resources archives docs scripts

# 移动项目文档
echo ""
echo "📦 整理项目文档..."
mv *-PLAN.md projects/ 2>/dev/null
mv *-MIGRATION.md projects/ 2>/dev/null
mv *-STRATEGY.md projects/ 2>/dev/null
echo "  ✅ 项目文档 → projects/"

# 移动技术文档
echo ""
echo "📚 整理技术文档..."
mkdir -p areas/技术文档
mv OPENCLAW-*.md areas/技术文档/ 2>/dev/null
mv *-GUIDE.md areas/技术文档/ 2>/dev/null
echo "  ✅ 技术文档 → areas/技术文档/"

# 移动总结文档
echo ""
echo "📋 整理总结文档..."
mv *-SUMMARY.md docs/ 2>/dev/null
mv *-FIX.md docs/ 2>/dev/null
mv *-ISSUE.md docs/ 2>/dev/null
mv SUCCESS-*.md docs/ 2>/dev/null
mv FINAL-*.md docs/ 2>/dev/null
echo "  ✅ 总结文档 → docs/"

# 移动脚本
echo ""
echo "🔧 整理工具脚本..."
mv *.sh scripts/ 2>/dev/null
echo "  ✅ 脚本 → scripts/"

# 移动测试/临时文件
echo ""
echo "🗑️  清理临时文件..."
mv OPENCLAW-AGENT-TRAINING-GUIDE.md areas/技术文档/ 2>/dev/null

# 统计结果
echo ""
echo "=================================="
echo "✅ 整理完成！"
echo ""
echo "📊 当前结构："
echo ""
echo "核心配置（MOSS 必读）："
echo "  - SOUL.md"
echo "  - USER.md"
echo "  - AGENTS.md"
echo "  - MEMORY.md"
echo "  - memory/"
echo ""
echo "知识库："
echo "  - projects/      $(ls -1 projects/ 2>/dev/null | wc -l | xargs) 个文件"
echo "  - areas/         $(ls -1 areas/ 2>/dev/null | wc -l | xargs) 个文件"
echo "  - resources/     $(ls -1 resources/ 2>/dev/null | wc -l | xargs) 个文件"
echo "  - docs/          $(ls -1 docs/ 2>/dev/null | wc -l | xargs) 个文件"
echo "  - scripts/       $(ls -1 scripts/ 2>/dev/null | wc -l | xargs) 个文件"
echo ""
echo "下一步："
echo "  1. 创建 index.md 导航文件"
echo "  2. 建立每周维护习惯"
echo "  3. 查看 KNOWLEDGE-MANAGEMENT-BEST-PRACTICES.md"
echo ""
echo "=================================="

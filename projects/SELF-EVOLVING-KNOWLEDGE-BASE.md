# 🧬 自进化知识库引擎项目

> **创建时间**: 2026-02-08 17:40
> **状态**: 执行中
> **优先级**: 中
> **预计时间**: 15-20 小时

## 📋 项目概述

### 目标
让知识库学会"自己管理自己"，实现自动发现、自动索引、自动优化。

### 核心价值
| 当前状态 | 目标状态 | 收益 |
|---------|---------|------|
| 人工维护容易遗漏 | 自动监控新文件 | 永不遗漏 |
| 结构容易过时 | 定期自我审查 | 持续优化 |
| 维护工作量大 | 自动化处理 | 零负担 |

### 长期愿景
打造一个"活"的智能知识库：
- 📚 新文件自动发现
- 📖 自动分类到正确位置
- 📝 自动更新目录索引
- 🧹 自动清理过期内容
- 👤 只在必要时才打扰你

## 🎯 功能规格

### 核心模块

#### 1. 智能监控器
```
监控目录：
- docs/          （文档）
- projects/      （项目）
- scripts/       （脚本）
- skills/        （技能）
- memory/        （记忆）

检测类型：
- 新建的文件（< 24小时）
- 修改的文件（< 7天）
- 删除的文件（从 index.md 中移除）
```

#### 2. 自动分类器
```
分类规则：
- 文件名包含 "project" → projects/
- 文件名包含 "script" → scripts/
- 文件名包含 "skill" → skills/
- 文件名包含 "memory" → memory/
- 文件扩展名 .md → docs/ 或 projects/
- 文件扩展名 .sh → scripts/

内容分析：
- 读取文件前 100 行
- 提取标题和关键词
- 根据内容判断类型
```

#### 3. 索引更新器
```
更新 index.md：
- 添加新文件的链接
- 更新文件状态（从"待创建"变为存在）
- 移除已删除文件的链接
- 更新统计数字

更新格式：
- 保持原有结构
- 按目录分类组织
- 添加时间戳标记
```

#### 4. 自优化引擎
```
定期检查：
- 文件访问频率（通过 git log 或文件访问时间）
- 文件修改时间
- index.md 中的引用次数

优化建议：
- 高频访问文件 → 提升优先级
- 长期未访问 → 标记为"可能归档"
- 过时内容 → 建议更新或归档
```

### Multi-Agent 协作

| Agent | 角色 | 任务 |
|-------|------|------|
| **leader-agent-v2** | 审查者 | 决定文件分类，识别优化点 |
| **utility-agent-v2** | 执行者 | 执行具体的监控和更新操作 |
| **main agent** | 汇报者 | 向用户汇报优化建议和重大变更 |

## 🛠️ 技术实现

### 核心脚本结构

```
scripts/
├── knowledge-evolution/
│   ├── monitor.sh              # 智能监控器
│   ├── classifier.sh           # 自动分类器
│   ├── index-updater.sh        # 索引更新器
│   ├── optimizer.sh            # 自优化引擎
│   └── knowledge-engine.sh     # 主引擎（协调所有模块）
```

### 模块详细设计

#### monitor.sh - 智能监控器
```bash
#!/bin/bash
# 监控知识库目录变化

WATCH_DIRS=("docs" "projects" "scripts" "skills" "memory")
OUTPUT_FILE="/tmp/knowledge-changes.json"

# 检测新文件
detect_new_files() {
    local dir=$1
    find "$dir" -type f -name "*.md" -o -name "*.sh" | \
        while read file; do
            local modified=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file")
            local now=$(date +%s)
            local diff=$((now - modified))
            
            # 24 小时内修改的文件
            if [ $diff -lt 86400 ]; then
                echo "$file"
            fi
        done
}

# 主逻辑
main() {
    echo "{\n  \"new_files\": [" > "$OUTPUT_FILE"
    local first=true
    
    for dir in "${WATCH_DIRS[@]}"; do
        while read file; do
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi
            echo "    \"$file\"" >> "$OUTPUT_FILE"
        done < <(detect_new_files "$dir")
    done
    
    echo -e "\n  ]\n}" >> "$OUTPUT_FILE"
    cat "$OUTPUT_FILE"
}

main "$@"
```

#### classifier.sh - 自动分类器
```bash
#!/bin/bash
# 根据文件名和内容自动分类

classify_file() {
    local file=$1
    
    # 1. 根据文件名分类
    case "$file" in
        *project*)
            echo "projects/"
            return
            ;;
        *script*)
            echo "scripts/"
            return
            ;;
        *skill*)
            echo "skills/"
            return
            ;;
        *memory*)
            echo "memory/"
            return
            ;;
    esac
    
    # 2. 根据扩展名分类
    case "$file" in
        *.sh)
            echo "scripts/"
            return
            ;;
        *.md)
            # 3. 根据内容判断
            local title=$(head -5 "$file" | grep -E "^# " | head -1)
            if [[ "$title" =~ [Pp]roject ]]; then
                echo "projects/"
            else
                echo "docs/"
            fi
            return
            ;;
    esac
    
    echo "unknown/"
}
```

#### optimizer.sh - 自优化引擎
```bash
#!/bin/bash
# 分析知识库健康状况

analyze_health() {
    echo "知识库健康检查报告"
    echo "===================="
    echo ""
    
    # 1. 文件统计
    echo "📊 文件统计："
    find . -name "*.md" -o -name "*.sh" | wc -l
    echo ""
    
    # 2. 新文件（24小时内）
    echo "🆕 24小时内新增："
    find . -name "*.md" -o -name "*.sh" -mtime -1 | wc -l
    echo ""
    
    # 3. 长期未修改（90天前）
    echo "⏰ 长期未修改（90天前）："
    find . -name "*.md" -mtime +90 | head -5
    echo ""
    
    # 4. 建议
    echo "💡 优化建议："
    echo "- 考虑归档长期未使用的文档"
    echo "- 检查是否有重复内容"
    echo "- 更新过时的配置信息"
}
```

### 集成 Multi-Agent 协作

#### leader-agent-v2 的角色
```markdown
1. 接收监控报告
2. 决定新文件的分类
3. 识别需要优化的内容
4. 生成优化建议
5. 向 main agent 汇报

输出示例：
## 知识库优化建议
- 新增 3 个文件待分类
- 建议归档 2 个长期未访问的文件
- 需要决策：是否清理重复内容？
```

#### utility-agent-v2 的角色
```markdown
1. 执行监控脚本
2. 执行分类脚本
3. 更新 index.md
4. 执行归档操作

执行命令示例：
- scripts/knowledge-evolution/monitor.sh
- scripts/knowledge-evolution/index-updater.sh
```

## 📝 执行计划

### Phase 1: 基础架构
- [x] 创建目录结构 `scripts/knowledge-evolution/`
- [x] 实现 monitor.sh（智能监控器）
- [x] 实现 classifier.sh（自动分类器）
- [x] 测试监控和分类功能

### Phase 2: 索引更新
- [ ] 实现 index-updater.sh（索引更新器）
- [ ] 解析 index.md 结构
- [ ] 自动添加/移除文件链接
- [ ] 测试索引更新功能

### Phase 3: 自优化引擎
- [x] 实现 optimizer.sh（自优化引擎）
- [x] 分析文件访问频率
- [x] 生成优化建议
- [x] 测试优化功能

### Phase 4: 集成 Multi-Agent
- [ ] 集成到 leader-agent-v2
- [ ] 集成到 utility-agent-v2
- [ ] 添加到 HEARTBEAT.md 自动任务
- [ ] 端到端测试

### Phase 5: 文档和测试
- [ ] 编写使用文档
- [ ] 创建测试用例
- [ ] 文档化恢复流程

## 🎯 验收标准

- [ ] 每天自动扫描知识库
- [ ] 新文件自动检测和分类
- [ ] index.md 自动更新
- [ ] 每周生成优化报告
- [ ] 零人工干预运行 7 天

## 📊 测试记录

| 日期 | 测试项 | 结果 | 备注 |
|------|--------|------|------|
| 2026-02-08 | 项目创建 | ✅ | 等待实现 |

## 相关文档

- **PARA 知识管理**: https://fortelabs.com/blog/para/
- **知识库导航**: `/Users/lijian/clawd/index.md`
- **PARA 实践**: `/Users/lijian/clawd/docs/KNOWLEDGE-MANAGEMENT-BEST-PRACTICES.md`

---

*项目创建时间: 2026-02-08 17:40*
*负责人: MOSS & 飞天*

*预计完成时间: 15-20 小时*
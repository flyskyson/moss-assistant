#!/usr/bin/env python3
"""
Token优化器 - 减少API调用的token消耗
Token Optimizer - Reduce API token consumption

核心策略:
1. 上下文压缩
2. 智能缓存
3. 去重优化
4. 本地知识库
"""

import json
import hashlib
from pathlib import Path
from datetime import datetime, timedelta
import re

class TokenOptimizer:
    """Token优化器"""

    def __init__(self):
        self.cache_dir = Path.home() / "clawd/cache/queries"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.knowledge_base = Path.home() / "clawd/knowledge-base"
        self.knowledge_base.mkdir(parents=True, exist_ok=True)

    def estimate_tokens(self, text):
        """估算token数量 (中文: 1字符≈2tokens, 英文: 1字符≈0.25tokens)"""
        chinese_chars = len(re.findall(r'[\u4e00-\u9fff]', text))
        other_chars = len(text) - chinese_chars
        estimated = chinese_chars * 2 + other_chars * 0.25
        return int(estimated)

    def compress_context(self, messages):
        """压缩上下文"""
        compressed = []

        for msg in messages:
            # 去除冗余空白
            content = re.sub(r'\n+', '\n', msg['content'])
            content = re.sub(r' +', ' ', content)

            # 截断过长的内容（保留重要部分）
            if self.estimate_tokens(content) > 5000:
                # 保留开头和结尾
                lines = content.split('\n')
                if len(lines) > 100:
                    # 保留前50行和后50行
                    compressed_content = '\n'.join(lines[:50])
                    compressed_content += '\n... [中间部分已压缩] ...\n'
                    compressed_content += '\n'.join(lines[-50:])
                    content = compressed_content

            compressed.append({
                "role": msg["role"],
                "content": content
            })

        return compressed

    def get_cache_key(self, query):
        """生成查询缓存key"""
        # 标准化查询（去除大小写、多余空格）
        normalized = re.sub(r'\s+', ' ', query.lower().strip())
        return hashlib.md5(normalized.encode()).hexdigest()

    def check_cache(self, query):
        """检查缓存"""
        cache_key = self.get_cache_key(query)
        cache_file = self.cache_dir / f"{cache_key}.json"

        if cache_file.exists():
            # 检查是否过期（24小时）
            age = datetime.now() - datetime.fromtimestamp(cache_file.stat().st_mtime)
            if age < timedelta(hours=24):
                with open(cache_file) as f:
                    return json.load(f)

        return None

    def save_to_cache(self, query, response, tokens_used):
        """保存到缓存"""
        cache_key = self.get_cache_key(query)
        cache_file = self.cache_dir / f"{cache_key}.json"

        cache_data = {
            "query": query,
            "response": response,
            "tokens_used": tokens_used,
            "timestamp": datetime.now().isoformat(),
            "cost_yuan": tokens_used * 0.14 / 1000000  # DeepSeek价格
        }

        with open(cache_file, 'w') as f:
            json.dump(cache_data, f, ensure_ascii=False, indent=2)

    def optimize_query(self, query, context=None):
        """优化查询"""
        # 1. 检查缓存
        cached = self.check_cache(query)
        if cached:
            return {
                "response": cached["response"],
                "tokens_saved": self.estimate_tokens(query) + self.estimate_tokens(cached["response"]),
                "from_cache": True,
                "cost_saved": cached["cost_yuan"]
            }

        # 2. 压缩上下文
        if context:
            context = self.compress_context(context)

        # 3. 如果没有缓存，返回优化后的查询
        return {
            "query": query,
            "context": context,
            "from_cache": False
        }

    def build_local_knowledge(self, topic):
        """构建本地知识库"""
        kb_file = self.knowledge_base / f"{topic}.md"

        if kb_file.exists():
            with open(kb_file) as f:
                return f.read()

        return None

    def save_to_knowledge(self, topic, content):
        """保存到知识库"""
        kb_file = self.knowledge_base / f"{topic}.md"

        with open(kb_file, 'w') as f:
            f.write(f"# {topic}\n\n")
            f.write(f"**更新时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(content)

    def query_with_knowledge(self, query):
        """结合知识库查询"""
        # 检查是否有相关知识
        knowledge_files = list(self.knowledge_base.glob("*.md"))

        related_knowledge = []
        for kb_file in knowledge_files:
            with open(kb_file) as f:
                content = f.read()
                # 简单的相关性检查（关键词匹配）
                if any(word in content.lower() for word in query.lower().split()):
                    related_knowledge.append(content)

        if related_knowledge:
            # 将相关知识添加到查询中
            enhanced_query = f"""
基于以下知识回答问题：

{''.join(related_knowledge)}

问题: {query}
"""
            return enhanced_query

        return query

    def analyze_session_cost(self, session_file):
        """分析session成本"""
        total_tokens = 0
        total_cost = 0

        with open(session_file) as f:
            for line in f:
                try:
                    data = json.loads(line)
                    if data.get('role') == 'assistant':
                        content = data.get('content', '')
                        tokens = self.estimate_tokens(content)
                        total_tokens += tokens
                        total_cost += tokens * 0.14 / 1000000
                except:
                    pass

        return {
            "total_tokens": total_tokens,
            "estimated_cost_yuan": total_cost
        }


class IntelligentRouter:
    """智能路由器"""

    def __init__(self, config_path=None):
        self.optimizer = TokenOptimizer()
        # 加载配置
        config_file = Path.home() / "clawd/config/smart-routing-config.json"
        if config_file.exists():
            with open(config_file) as f:
                self.config = json.load(f)
        else:
            self.config = {"models": {}, "intelligent_routing": {"rules": []}}

    def route(self, task):
        """智能路由任务到合适的模型"""

        # 估算token消耗
        estimated_tokens = self.optimizer.estimate_tokens(str(task))

        # 规则匹配
        rules = self.config.get("intelligent_routing", {}).get("rules", [])

        # 规则1: 调试/测试任务 → DeepSeek
        if task.get("type") in ["debugging", "testing"]:
            return {
                "model": "deepseek_official",
                "reason": "调试/测试任务使用低成本模型",
                "estimated_cost": "¥0.01-0.05"
            }

        # 规则2: 大token量 → DeepSeek
        if estimated_tokens > 50000:
            return {
                "model": "deepseek_official",
                "reason": f"预估{estimated_tokens} tokens，必须控制成本",
                "estimated_cost": f"¥{estimated_tokens * 0.14 / 1000000:.2f}"
            }

        # 规则3: 小量高价值任务 → GPT-4o
        if task.get("type") == "research" and task.get("complexity") == "high" and estimated_tokens < 5000:
            return {
                "model": "gpt4o",
                "reason": "少量高价值任务值得投资",
                "estimated_cost": f"¥{estimated_tokens * 2.5 / 1000000:.2f}"
            }

        # 默认: DeepSeek
        return {
            "model": "deepseek_official",
            "reason": "默认使用成本最优模型",
            "estimated_cost": f"¥{estimated_tokens * 0.14 / 1000000:.2f}"
        }


def main():
    """命令行工具"""
    import sys

    optimizer = TokenOptimizer()
    router = IntelligentRouter()

    if len(sys.argv) < 2:
        print("用法:")
        print("  token-optimizer.py analyze <session-file>")
        print("  token-optimizer.py estimate <text>")
        print("  token-optimizer.py route <task-type> <query>")
        return

    command = sys.argv[1]

    if command == "analyze":
        # 分析session成本
        session_file = sys.argv[2]
        result = optimizer.analyze_session_cost(session_file)
        print(json.dumps(result, indent=2))

    elif command == "estimate":
        # 估算token
        text = " ".join(sys.argv[2:])
        tokens = optimizer.estimate_tokens(text)
        cost = tokens * 0.14 / 1000000
        print(f"估算tokens: {tokens}")
        print(f"估算成本(DeepSeek): ¥{cost:.4f}")
        print(f"估算成本(GPT-4o): ¥{tokens * 2.5 / 1000000:.4f}")
        print(f"估算成本(Claude): ¥{tokens * 15 / 1000000:.4f}")

    elif command == "route":
        # 路由任务
        task_type = sys.argv[2]
        query = " ".join(sys.argv[3:])
        result = router.route({"type": task_type, "query": query})
        print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()

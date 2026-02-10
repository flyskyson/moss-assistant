#!/usr/bin/env python3
"""
主动性引擎 - 监控守护进程
Proactive Engine - Monitoring Daemon

功能:
1. 持续监控Agent性能
2. 主动发现问题和机会
3. 触发分析和建议
"""

import json
import time
import subprocess
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict

class ProactiveMonitor:
    """主动性监控器"""

    def __init__(self, agent_id="main"):
        self.agent_id = agent_id
        self.session_dir = Path.home() / f".openclaw/agents/{agent_id}/sessions"
        self.workspace = Path.home() / "clawd"

        # 数据目录
        self.data_dir = self.workspace / "proactive-data"
        self.data_dir.mkdir(parents=True, exist_ok=True)

        # 指标文件
        self.metrics_file = self.data_dir / "metrics.jsonl"
        self.alerts_file = self.data_dir / "alerts.jsonl"
        self.suggestions_file = self.data_dir / "suggestions.jsonl"

    def collect_metrics(self):
        """收集指标"""
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "agent_id": self.agent_id,
        }

        # 1. Session指标
        try:
            sessions = list(self.session_dir.glob("*.jsonl"))
            metrics["session_count"] = len(sessions)
            metrics["session_total_size"] = sum(f.stat().st_size for f in sessions)

            # 最近的session
            if sessions:
                latest = max(sessions, key=lambda f: f.stat().st_mtime)
                metrics["latest_session_age_hours"] = (datetime.now() - datetime.fromtimestamp(latest.stat().st_mtime)).total_seconds() / 3600
        except Exception as e:
            metrics["session_error"] = str(e)

        # 2. 工作区指标
        try:
            metrics["workspace_size_bytes"] = sum(
                f.stat().st_size for f in self.workspace.rglob("*") if f.is_file()
            )

            # node_modules检查
            node_modules = self.workspace / "node_modules"
            if node_modules.exists():
                metrics["node_modules_size_bytes"] = sum(
                    f.stat().st_size for f in node_modules.rglob("*") if f.is_file()
                )
        except Exception as e:
            metrics["workspace_error"] = str(e)

        # 3. 性能指标（最近响应时间）
        try:
            latest_metrics = list(self.data_dir.glob("performance-*.json"))
            if latest_metrics:
                with open(latest_metrics[-1]) as f:
                    perf = json.load(f)
                    metrics["last_response_time_seconds"] = perf.get("response_time", 0)
        except:
            pass

        return metrics

    def check_alerts(self, metrics):
        """检查告警条件"""
        alerts = []

        # 告警1: Session数量过多
        if metrics.get("session_count", 0) > 20:
            alerts.append({
                "type": "session_bloat",
                "severity": "high",
                "message": f"Session数量过多: {metrics['session_count']}个，建议清理",
                "suggestion": "运行: ~/clawd/scripts/agent-rejuvenate.sh main"
            })

        # 告警2: 响应时间过长
        if metrics.get("last_response_time_seconds", 0) > 10:
            alerts.append({
                "type": "slow_response",
                "severity": "medium",
                "message": f"响应时间过长: {metrics['last_response_time_seconds']}秒",
                "suggestion": "检查工作区大小或清理session"
            })

        # 告警3: node_modules存在且很大
        if metrics.get("node_modules_size_bytes", 0) > 100 * 1024 * 1024:  # >100MB
            alerts.append({
                "type": "large_node_modules",
                "severity": "low",
                "message": f"node_modules过大: {metrics['node_modules_size_bytes'] / 1024 / 1024:.1f}MB",
                "suggestion": "考虑移到其他位置或清理"
            })

        return alerts

    def find_opportunities(self, metrics):
        """发现优化机会"""
        opportunities = []

        # 机会1: 节省成本的模式
        # 可以通过分析历史查询找到重复模式

        # 机会2: 自动化潜力
        if metrics.get("session_count", 0) > 15:
            opportunities.append({
                "type": "automation",
                "potential": "high",
                "message": "可以设置自动清理",
                "benefit": "保持Agent高性能",
                "action": "crontab任务"
            })

        return opportunities

    def save_metrics(self, metrics):
        """保存指标"""
        with open(self.metrics_file, 'a') as f:
            f.write(json.dumps(metrics) + "\n")

    def save_alerts(self, alerts):
        """保存告警"""
        if alerts:
            for alert in alerts:
                alert["timestamp"] = datetime.now().isoformat()
                with open(self.alerts_file, 'a') as f:
                    f.write(json.dumps(alert) + "\n")

    def generate_summary(self):
        """生成摘要报告"""
        # 读取最近的指标
        recent_metrics = []
        try:
            with open(self.metrics_file) as f:
                for line in f:
                    recent_metrics.append(json.loads(line))
                    if len(recent_metrics) >= 10:  # 最近10次
                        break
        except:
            return "暂无数据"

        if not recent_metrics:
            return "暂无数据"

        # 分析趋势
        session_counts = [m.get("session_count", 0) for m in recent_metrics]
        avg_sessions = sum(session_counts) / len(session_counts)

        summary = f"""
主动性引擎监控报告
{'='*50}
监控时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Agent: {self.agent_id}

📊 当前状态:
  Session数量: {recent_metrics[-1].get('session_count', 'N/A')}
  工作区大小: {recent_metrics[-1].get('workspace_size_bytes', 0) / 1024 / 1024:.1f} MB

📈 趋势分析:
  平均Session数: {avg_sessions:.1f}

💡 建议:
  {'继续监控...' if avg_sessions < 15 else '建议清理session'}
"""

        return summary

    def run_daemon(self, interval_seconds=300):
        """运行守护进程"""
        print("🤖 主动性引擎启动...")
        print(f"📊 监控间隔: {interval_seconds}秒")
        print(f"📁 数据目录: {self.data_dir}")
        print("")

        while True:
            try:
                # 1. 收集指标
                metrics = self.collect_metrics()
                print(f"[{datetime.now().strftime('%H:%M:%S')}] 📊 收集指标...")

                # 2. 检查告警
                alerts = self.check_alerts(metrics)
                if alerts:
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] 🚨 发现{len(alerts)}个告警")
                    for alert in alerts:
                        print(f"  - {alert['message']}")
                    self.save_alerts(alerts)

                # 3. 发现机会
                opportunities = self.find_opportunities(metrics)
                if opportunities:
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] 💡 发现{len(opportunities)}个机会")
                    for opp in opportunities:
                        print(f"  - {opp['message']}")

                # 4. 保存指标
                self.save_metrics(metrics)

                # 5. 休眠
                time.sleep(interval_seconds)

            except KeyboardInterrupt:
                print("\n停止主动性引擎")
                break
            except Exception as e:
                print(f"错误: {e}")
                time.sleep(60)  # 出错后等待1分钟


class AnalysisEngine:
    """分析引擎"""

    def __init__(self, agent_id="main"):
        self.agent_id = agent_id
        self.data_dir = Path.home() / "clawd/proactive-data"

    def analyze_recent_performance(self):
        """分析最近性能"""
        metrics_file = self.data_dir / "metrics.jsonl"

        if not metrics_file.exists():
            return "暂无数据可分析"

        # 读取最近100条指标
        recent_metrics = []
        with open(metrics_file) as f:
            for i, line in enumerate(f):
                try:
                    recent_metrics.append(json.loads(line))
                    if len(recent_metrics) >= 100:
                        break
                except:
                    pass

        if not recent_metrics:
            return "暂无有效数据"

        # 分析
        analysis = {
            "分析时间": datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            "样本数": len(recent_metrics)
        }

        # Session趋势
        session_counts = [m.get("session_count", 0) for m in recent_metrics]
        if session_counts:
            analysis["session趋势"] = {
                "最新": session_counts[-1],
                "平均": sum(session_counts) / len(session_counts),
                "最高": max(session_counts),
                "最低": min(session_counts)
            }

        # 检测问题
        issues = []
        if session_counts and session_counts[-1] > 15:
            issues.append("Session数量过多，建议清理")

        analysis["发现问题"] = issues

        # 生成建议
        suggestions = []
        if issues:
            suggestions.append({
                "类型": "优化建议",
                "建议": "清理旧session",
                "命令": "~/clawd/scripts/agent-rejuvenate.sh main",
                "预期效果": "响应时间降低"
            })

        analysis["建议"] = suggestions

        return analysis

    def generate_report(self):
        """生成详细报告"""
        analysis = self.analyze_recent_performance()

        if isinstance(analysis, str):
            return analysis

        report = f"""
主动性分析报告
{'='*50}
{analysis['分析时间']}

📊 数据统计:
  样本数: {analysis['样本数']}

📈 Session趋势:
  最新: {analysis['session趋势']['最新']} 个
  平均: {analysis['session趋势']['平均']:.1f} 个
  最高: {analysis['session趋势']['最高']} 个
  最低: {analysis['session趋势']['最低']} 个
"""

        if analysis["发现问题"]:
            report += "\n🚨 发现问题:\n"
            for issue in analysis["发现问题"]:
                report += f"  - {issue}\n"

        if analysis["建议"]:
            report += "\n💡 优化建议:\n"
            for suggestion in analysis["建议"]:
                report += f"  建议: {suggestion['建议']}\n"
                report += f"  命令: {suggestion['命令']}\n"
                report += f"  效果: {suggestion['预期效果']}\n"

        return report


def main():
    """主函数"""
    import sys

    agent_id = sys.argv[1] if len(sys.argv) > 1 else "main"
    mode = sys.argv[2] if len(sys.argv) > 2 else "daemon"

    if mode == "daemon":
        # 守护进程模式
        monitor = ProactiveMonitor(agent_id)

        # 先运行一次分析
        engine = AnalysisEngine(agent_id)
        print(engine.generate_report())
        print("\n开始监控...")

        # 启动守护进程
        monitor.run_daemon(interval_seconds=300)  # 5分钟

    elif mode == "analyze":
        # 分析模式
        engine = AnalysisEngine(agent_id)
        print(engine.generate_report())

    else:
        print("用法:")
        print("  python3 proactive-engine.py [agent-id] daemon  # 守护进程")
        print("  python3 proactive-engine.py [agent-id] analyze  # 分析报告")


if __name__ == "__main__":
    main()

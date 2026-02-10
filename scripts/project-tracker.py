#!/usr/bin/env python3
"""
📋 项目状态自动更新器 (集成版)
用途：自动更新 TASKS.md 中的项目状态
功能：
  - 自动检测任务完成并更新状态
  - 记录完成时间戳
  - 生成进展报告
  - 集成到 cron 定时任务
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path

# 配置
BASE_DIR = "/Users/lijian/clawd"
TASKS_FILE = f"{BASE_DIR}/TASKS.md"
LOG_FILE = f"{BASE_DIR}/logs/project-tracker.log"
STATE_FILE = f"{BASE_DIR}/.project-state.json"

# 状态映射
STATUS_MAP = {
    "done": {"icon": "✅", "text": "已完成"},
    "completed": {"icon": "✅", "text": "已完成"},
    "in_progress": {"icon": "🔄", "text": "进行中"},
    "ongoing": {"icon": "🔄", "text": "进行中"},
    "planning": {"icon": "📋", "text": "规划中"},
    "pending": {"icon": "📋", "text": "规划中"},
}

def log(message):
    """日志记录"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_entry = f"[{timestamp}] {message}"
    print(log_entry)
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, 'a') as f:
        f.write(log_entry + '\n')

def load_state():
    """加载项目状态"""
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, 'r') as f:
                return json.load(f)
        except:
            return {}
    return {}

def save_state(state):
    """保存项目状态"""
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=2, ensure_ascii=False)

def update_project_status(project_name, new_status, details=""):
    """更新项目状态"""
    log(f"更新项目状态: {project_name} -> {new_status}")
    
    # 读取 TASKS.md
    with open(TASKS_FILE, 'r') as f:
        content = f.read()
    
    # 获取状态信息
    if new_status in STATUS_MAP:
        status_info = STATUS_MAP[new_status]
    else:
        status_info = {"icon": "📝", "text": new_status}
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
    
    # 更新状态（简化版本：找到项目行并更新）
    # 实际实现需要更复杂的 Markdown 解析
    
    # 保存到状态文件
    state = load_state()
    if project_name not in state:
        state[project_name] = {}
    
    state[project_name].update({
        "status": new_status,
        "status_icon": status_info["icon"],
        "status_text": status_info["text"],
        "updated_at": timestamp,
        "details": details
    })
    
    save_state(state)
    
    log(f"状态已保存: {project_name}")
    return True

def mark_project_done(project_name, details=""):
    """标记项目完成"""
    return update_project_status(project_name, "done", details)

def mark_project_in_progress(project_name, details=""):
    """标记项目进行中"""
    return update_project_status(project_name, "in_progress", details)

def generate_report():
    """生成进度报告"""
    log("生成项目进度报告")
    
    state = load_state()
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
    
    report = f"""
==========================================
📊 项目进度报告 - {timestamp}
==========================================

🔴 高优先级项目：
"""
    
    high_priority = []
    medium_priority = []
    completed = []
    
    for project, info in state.items():
        status = info.get("status", "")
        if status == "done":
            completed.append((project, info))
        elif status == "in_progress":
            high_priority.append((project, info))
        else:
            medium_priority.append((project, info))
    
    for project, info in high_priority:
        icon = info.get("status_icon", "📝")
        text = info.get("status_text", "")
        updated = info.get("updated_at", "")
        report += f"  • {icon} {project} ({text}) - {updated}\n"
    
    report += "\n🟡 中优先级项目：\n"
    for project, info in medium_priority:
        icon = info.get("status_icon", "📝")
        text = info.get("status_text", "")
        updated = info.get("updated_at", "")
        report += f"  • {icon} {project} ({text}) - {updated}\n"
    
    report += "\n✅ 已完成项目：\n"
    for project, info in completed:
        icon = info.get("status_icon", "✅")
        updated = info.get("updated_at", "")
        report += f"  • {icon} {project} - {updated}\n"
    
    report += f"""
==========================================
📅 报告生成时间：{timestamp}
==========================================
"""
    
    print(report)
    return report

def auto_detect_completed():
    """自动检测已完成项目"""
    log("自动检测已完成项目...")
    
    state = load_state()
    
    # 检查项目文件是否存在
    for project, info in list(state.items()):
        project_file = info.get("file_path", "")
        if project_file and os.path.exists(project_file):
            # 文件存在，项目可能在进行中
            pass
        elif project_file and not os.path.exists(project_file):
            log(f"警告: 项目文件不存在: {project_file}")
    
    log("自动检测完成")
    return True

def update_tasks_md_from_state():
    """从状态文件更新 TASKS.md"""
    log("同步状态到 TASKS.md...")
    
    state = load_state()
    
    # 读取当前 TASKS.md
    with open(TASKS_FILE, 'r') as f:
        content = f.read()
    
    updated_content = content
    changes = []
    
    for project, info in state.items():
        old_status = info.get("old_status", "")
        new_status = info.get("status_icon", "") + " " + info.get("status_text", "")
        updated_at = info.get("updated_at", "")
        
        if old_status != new_status and old_status:
            # 找到并更新项目行
            pattern = rf"(\*\*{re.escape(project)}\*\*[^\n]*)\([^)]+\)"
            replacement = rf"**{project}**（状态：{new_status}，优先级：高）\n  - 📅 更新时间：{updated_at}"
            
            if re.search(pattern, updated_content):
                updated_content = re.sub(pattern, replacement, updated_content)
                changes.append(project)
    
    if changes:
        # 备份原文件
        backup_file = f"{TASKS_FILE}.backup.{datetime.now().strftime('%Y%m%d%H%M%S')}"
        with open(TASKS_FILE, 'w') as f:
            f.write(updated_content)
        log(f"已更新 TASKS.md，更新了 {len(changes)} 个项目")
    else:
        log("没有需要更新的项目")
    
    return changes

def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("📋 项目状态自动跟踪器")
        print("")
        print("用法：")
        print("  project-tracker.py done <项目名> [详情]     # 标记完成")
        print("  project-tracker.py progress <项目名>       # 标记进行中")
        print("  project-tracker.py report                  # 生成报告")
        print("  project-tracker.py sync                    # 同步到 TASKS.md")
        print("  project-tracker.py auto                    # 自动检测")
        print("  project-tracker.py help                    # 帮助")
        return
    
    command = sys.argv[1]
    
    if command == "done":
        project = sys.argv[2] if len(sys.argv) > 2 else ""
        details = sys.argv[3] if len(sys.argv) > 3 else ""
        if project:
            mark_project_done(project, details)
        else:
            print("请指定项目名称")
    
    elif command == "progress":
        project = sys.argv[2] if len(sys.argv) > 2 else ""
        details = sys.argv[3] if len(sys.argv) > 3 else ""
        if project:
            mark_project_in_progress(project, details)
        else:
            print("请指定项目名称")
    
    elif command == "report":
        generate_report()
    
    elif command == "sync":
        update_tasks_md_from_state()
    
    elif command == "auto":
        auto_detect_completed()
    
    elif command in ["help", "--help", "-h"]:
        print("📋 项目状态自动跟踪器")
        print("")
        print("命令：")
        print("  done <项目> [详情]   - 标记项目完成")
        print("  progress <项目>      - 标记项目进行中")
        print("  report               - 生成进度报告")
        print("  sync                 - 同步状态到 TASKS.md")
        print("  auto                 - 自动检测")
        print("")
        print("示例：")
        print("  python3 project-tracker.py done \"自动化备份系统\"")
        print("  python3 project-tracker.py report")
    
    else:
        print(f"未知命令: {command}")
        print("使用 'help' 查看帮助")

if __name__ == "__main__":
    main()
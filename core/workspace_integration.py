"""
Office Workspace 集成接口
让 MOSS 能够调用工作区管理功能
"""

import subprocess
import json
from pathlib import Path
from typing import Dict, Any


class OfficeWorkspaceIntegration:
    """Office Workspace 集成"""

    def __init__(self, workspace_path: str = "C:\\Users\\flyskyson\\Office_Agent_Workspace"):
        """
        初始化工作区集成

        Args:
            workspace_path: 工作区路径
        """
        self.workspace_path = Path(workspace_path)
        self.enabled = self.workspace_path.exists()

    def generate_health_report(self) -> Dict[str, Any]:
        """生成工作区健康报告"""
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            report_script = self.workspace_path / "workspace_report.py"

            if not report_script.exists():
                return {"success": False, "error": "报告脚本不存在"}

            result = subprocess.run(
                f'python "{report_script}"',
                shell=True,
                capture_output=True,
                text=True,
                cwd=self.workspace_path
            )

            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def clean_workspace(self, execute: bool = False) -> Dict[str, Any]:
        """
        清理工作区

        Args:
            execute: 是否实际执行（False = 演习模式）
        """
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            cleaner_script = self.workspace_path / "workspace_cleaner.py"

            if not cleaner_script.exists():
                return {"success": False, "error": "清理脚本不存在"}

            cmd = f'python "{cleaner_script}"'
            if execute:
                cmd += " --execute"

            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                cwd=self.workspace_path
            )

            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr,
                "mode": "execute" if execute else "dry-run"
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def run_maintenance(self, with_health_report: bool = False) -> Dict[str, Any]:
        """
        运行定期维护

        Args:
            with_health_report: 是否生成健康报告
        """
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            maintenance_script = self.workspace_path / "workspace_maintenance.py"

            if not maintenance_script.exists():
                return {"success": False, "error": "维护脚本不存在"}

            cmd = f'python "{maintenance_script}"'
            if with_health_report:
                cmd += " --health-report"

            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                cwd=self.workspace_path
            )

            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def get_project_structure(self) -> Dict[str, Any]:
        """获取项目结构 - 调用超级管家"""
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            # 优先调用超级管家脚本
            super_butler_script = self.workspace_path / "超级管家.py"

            if super_butler_script.exists():
                result = subprocess.run(
                    f'python "{super_butler_script}" --json-only',
                    shell=True,
                    capture_output=True,
                    text=True,
                    cwd=self.workspace_path
                )

                if result.returncode == 0:
                    # 超级管家返回的是JSON
                    try:
                        report_data = json.loads(result.stdout)
                        return {
                            "success": True,
                            "source": "超级管家",
                            "data": report_data
                        }
                    except json.JSONDecodeError:
                        pass

            # 降级方案：使用简单的文件扫描
            structure = {}

            # 检查是否是 Office Workspace 的标准目录
            is_office_workspace = (self.workspace_path / "00_Agent_Library").exists()

            if is_office_workspace:
                # Office Workspace 标准目录
                main_dirs = [
                    "00_Agent_Library",
                    "01_Active_Projects",
                    "02_Project_Archive",
                    "03_Code_Templates",
                    "04_Data_&_Resources",
                    "05_Outputs",
                    "06_Learning_Journal"
                ]

                for dir_name in main_dirs:
                    dir_path = self.workspace_path / dir_name
                    if dir_path.exists():
                        files = list(dir_path.rglob("*"))
                        structure[dir_name] = {
                            "path": str(dir_path),
                            "file_count": len([f for f in files if f.is_file()]),
                            "dir_count": len([d for d in files if d.is_dir()]),
                            "size_mb": sum(f.stat().st_size for f in files if f.is_file()) / (1024 * 1024)
                        }
            else:
                # 通用目录扫描（任意路径）
                try:
                    all_items = list(self.workspace_path.iterdir())

                    # 统计文件和目录
                    files = [f for f in all_items if f.is_file()]
                    dirs = [d for d in all_items if d.is_dir()]

                    structure["_top_level"] = {
                        "files": [{"name": f.name, "size_kb": f.stat().st_size / 1024} for f in files[:20]],  # 最多显示20个文件
                        "directories": [{"name": d.name} for d in dirs[:20]],  # 最多显示20个目录
                        "total_files": len(files),
                        "total_dirs": len(dirs),
                        "total_size_mb": sum(f.stat().st_size for f in files) / (1024 * 1024)
                    }

                    # 添加完整文件列表（用于调试）
                    structure["_all_files"] = [f.name for f in files]

                except Exception as scan_error:
                    return {"success": False, "error": f"扫描失败: {str(scan_error)}"}

            return {
                "success": True,
                "source": "直接扫描",
                "structure": structure,
                "workspace_path": str(self.workspace_path)
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def query_projects(self) -> Dict[str, Any]:
        """查询项目状态 - 调用智能管家项目查询"""
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            query_script = self.workspace_path / "智能管家项目查询.py"

            if not query_script.exists():
                return {"success": False, "error": "查询脚本不存在"}

            result = subprocess.run(
                f'python "{query_script}" list',
                shell=True,
                capture_output=True,
                text=True,
                cwd=self.workspace_path
            )

            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr if result.stderr else None
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def get_memory_info(self) -> Dict[str, Any]:
        """读取工作区记忆（AI_MEMORY.md）"""
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            memory_file = self.workspace_path / "06_Learning_Journal" / "AI_MEMORY.md"

            if not memory_file.exists():
                return {"success": False, "error": "记忆文件不存在"}

            content = memory_file.read_text(encoding='utf-8')

            return {
                "success": True,
                "content": content,
                "file_path": str(memory_file)
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def get_workspace_index(self) -> Dict[str, Any]:
        """读取工作区索引（workspace_index_latest.json）"""
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            index_file = self.workspace_path / "06_Learning_Journal" / "workspace_memory" / "workspace_index_latest.json"

            if not index_file.exists():
                return {"success": False, "error": "索引文件不存在"}

            content = index_file.read_text(encoding='utf-8')
            data = json.loads(content)

            return {
                "success": True,
                "data": data,
                "scan_time": data.get('scan_time'),
                "file_path": str(index_file)
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def create_new_project(self, project_name: str, project_type: str = "general") -> Dict[str, Any]:
        """
        创建新项目

        Args:
            project_name: 项目名称
            project_type: 项目类型
        """
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            active_projects = self.workspace_path / "01_Active_Projects" / project_name

            if active_projects.exists():
                return {"success": False, "error": "项目已存在"}

            # 创建项目目录
            active_projects.mkdir(parents=True, exist_ok=True)

            # 创建基本结构
            (active_projects / "README.md").write_text(f"# {project_name}\n\n创建于: {datetime.now()}\n")
            (active_projects / "src").mkdir(exist_ok=True)
            (active_projects / "tests").mkdir(exist_ok=True)
            (active_projects / "docs").mkdir(exist_ok=True)

            return {
                "success": True,
                "project_path": str(active_projects),
                "message": f"项目 {project_name} 创建成功"
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def archive_project(self, project_name: str) -> Dict[str, Any]:
        """
        归档项目

        Args:
            project_name: 项目名称
        """
        if not self.enabled:
            return {"success": False, "error": "工作区路径不存在"}

        try:
            active_project = self.workspace_path / "01_Active_Projects" / project_name
            archive_dir = self.workspace_path / "02_Project_Archive" / project_name

            if not active_project.exists():
                return {"success": False, "error": "项目不存在"}

            # 移动到归档
            import shutil
            shutil.move(str(active_project), str(archive_dir))

            return {
                "success": True,
                "message": f"项目 {project_name} 已归档",
                "archive_path": str(archive_dir)
            }

        except Exception as e:
            return {"success": False, "error": str(e)}


# 使用示例
if __name__ == "__main__":
    workspace = OfficeWorkspaceIntegration()

    # 测试连接
    print("工作区状态:", "启用" if workspace.enabled else "禁用")

    # 获取结构
    structure = workspace.get_project_structure()
    print("\n项目结构:")
    print(json.dumps(structure, indent=2, ensure_ascii=False))

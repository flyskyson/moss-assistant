import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from core.workspace_integration import OfficeWorkspaceIntegration

# 测试扫描 moss-assistant 目录
workspace = OfficeWorkspaceIntegration("C:\\Users\\flyskyson\\moss-assistant")

print(f"Enabled: {workspace.enabled}")
print()

result = workspace.get_project_structure()

print(f"Success: {result.get('success')}")
print(f"Source: {result.get('source')}")

if result.get("success"):
    structure = result.get("structure", {})
    print(f"Structure keys: {list(structure.keys())}")

    if "_top_level" in structure:
        top = structure["_top_level"]
        print(f"\nTotal files: {top['total_files']}")
        print(f"Total dirs: {top['total_dirs']}")
        print(f"Total size: {top['total_size_mb']:.2f} MB")

        print("\nFirst 10 files:")
        for f in top['files'][:10]:
            print(f"  - {f['name']} ({f['size_kb']:.1f} KB)")

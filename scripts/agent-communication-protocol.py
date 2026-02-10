#!/usr/bin/env python3
"""
优化的 Agent 通信协议
Optimized Agent Communication Protocol for OpenClaw

使用文件系统传递大对象，减少序列化开销
Uses file system to pass large objects, reducing serialization overhead
"""

import json
import pickle
import hashlib
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
from typing import Any, Dict, Optional

class AgentCommunicationProtocol:
    """优化的 Agent 通信协议"""

    def __init__(self, config_path=None):
        """初始化通信协议"""
        self.config = self._load_config(config_path)
        self.base_path = Path(self.config.get("sharedMemory", {}).get("basePath", "/tmp/openclaw-shared"))
        self.max_in_memory_size = self._parse_size(
            self.config.get("communication", {}).get("maxInMemorySize", "1MB")
        )
        self.use_compression = self.config.get("communication", {}).get("compression", True)

        # 创建共享目录
        self.base_path.mkdir(parents=True, exist_ok=True)

        # 为每个 Agent 创建子目录
        for agent_id in self.config.get("agents", {}).keys():
            agent_path = self.base_path / agent_id
            agent_path.mkdir(parents=True, exist_ok=True)

    def _load_config(self, config_path):
        """加载配置"""
        if config_path is None:
            config_path = Path(__file__).parent.parent / "config" / "shared-memory-config.json"
        else:
            config_path = Path(config_path)

        if config_path.exists():
            with open(config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        else:
            return {"sharedMemory": {"basePath": "/tmp/openclaw-shared"}}

    def _parse_size(self, size_str):
        """解析大小字符串"""
        size_str = size_str.upper()
        if 'KB' in size_str:
            return int(size_str.replace('KB', '')) * 1024
        elif 'MB' in size_str:
            return int(size_str.replace('MB', '')) * 1024 * 1024
        elif 'GB' in size_str:
            return int(size_str.replace('GB', '')) * 1024 * 1024 * 1024
        else:
            return int(size_str)

    def _get_object_size(self, obj):
        """获取对象大小（字节）"""
        return len(pickle.dumps(obj))

    def _calculate_hash(self, data):
        """计算数据哈希"""
        return hashlib.md5(json.dumps(data, sort_keys=True).encode()).hexdigest()[:16]

    def send_message(self, from_agent: str, to_agent: str, message: Dict[str, Any],
                     use_file_transfer: bool = None) -> Dict[str, Any]:
        """
        发送消息到另一个 Agent

        Args:
            from_agent: 发送者 Agent ID
            to_agent: 接收者 Agent ID
            message: 消息内容
            use_file_transfer: 是否使用文件传输（None 表示自动判断）

        Returns:
            dict: 发送结果，包含消息 ID 和传输方式
        """
        result = {
            "timestamp": datetime.now().isoformat(),
            "from": from_agent,
            "to": to_agent,
            "message_id": None,
            "transfer_mode": None,
            "size": 0,
            "status": "success"
        }

        try:
            # 判断是否使用文件传输
            if use_file_transfer is None:
                obj_size = self._get_object_size(message)
                use_file_transfer = obj_size > self.max_in_memory_size

            result["size"] = obj_size

            if use_file_transfer:
                # 使用文件传输
                result["transfer_mode"] = "file"
                result["message_id"] = self._send_via_file(from_agent, to_agent, message)
                result["reason"] = f"对象大小 {obj_size} 字节，超过阈值 {self.max_in_memory_size}"
            else:
                # 使用内存传输
                result["transfer_mode"] = "memory"
                result["message_id"] = self._send_via_memory(from_agent, to_agent, message)
                result["reason"] = f"对象大小 {obj_size} 字节，适合内存传输"

        except Exception as e:
            result["status"] = "error"
            result["error"] = str(e)

        return result

    def _send_via_file(self, from_agent: str, to_agent: str, message: Dict[str, Any]) -> str:
        """通过文件系统发送消息"""
        # 生成消息 ID
        message_id = f"{from_agent}_{to_agent}_{datetime.now().timestamp()}"

        # 计算哈希
        content_hash = self._calculate_hash(message)

        # 创建文件
        agent_dir = self.base_path / to_agent
        file_path = agent_dir / f"{message_id}_{content_hash}.pkl"

        # 序列化并写入
        with open(file_path, 'wb') as f:
            pickle.dump(message, f)

        # 创建元数据文件
        metadata = {
            "message_id": message_id,
            "from": from_agent,
            "to": to_agent,
            "timestamp": datetime.now().isoformat(),
            "file_path": str(file_path),
            "size": file_path.stat().st_size,
            "hash": content_hash
        }

        metadata_path = agent_dir / f"{message_id}_{content_hash}.meta.json"
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, ensure_ascii=False, indent=2)

        return message_id

    def _send_via_memory(self, from_agent: str, to_agent: str, message: Dict[str, Any]) -> str:
        """通过内存传输发送消息（创建轻量级指针）"""
        message_id = f"{from_agent}_{to_agent}_{datetime.now().timestamp()}"

        # 只在文件系统中创建轻量级指针
        agent_dir = self.base_path / to_agent
        pointer_path = agent_dir / f"{message_id}.ptr.json"

        pointer = {
            "message_id": message_id,
            "from": from_agent,
            "to": to_agent,
            "timestamp": datetime.now().isoformat(),
            "type": "memory_pointer",
            "data": message  # 小对象直接存储
        }

        with open(pointer_path, 'w', encoding='utf-8') as f:
            json.dump(pointer, f, ensure_ascii=False, indent=2)

        return message_id

    def receive_message(self, agent_id: str, message_id: str) -> Optional[Dict[str, Any]]:
        """
        接收消息

        Args:
            agent_id: 接收者 Agent ID
            message_id: 消息 ID

        Returns:
            dict: 消息内容，如果未找到返回 None
        """
        agent_dir = self.base_path / agent_id

        # 查找文件
        meta_files = list(agent_dir.glob(f"{message_id}_*.meta.json"))

        if meta_files:
            # 文件传输的消息
            meta_file = meta_files[0]
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)

            # 读取实际数据
            file_path = Path(metadata["file_path"])
            if file_path.exists():
                with open(file_path, 'rb') as f:
                    message = pickle.load(f)
                return message
        else:
            # 内存传输的消息
            ptr_files = list(agent_dir.glob(f"{message_id}.ptr.json"))
            if ptr_files:
                with open(ptr_files[0], 'r', encoding='utf-8') as f:
                    pointer = json.load(f)
                return pointer.get("data")

        return None

    def cleanup_old_messages(self, agent_id: str, max_age_seconds: int = 3600):
        """
        清理旧消息

        Args:
            agent_id: Agent ID
            max_age_seconds: 最大保留时间（秒）
        """
        agent_dir = self.base_path / agent_id
        now = datetime.now().timestamp()

        for file_path in agent_dir.glob("*"):
            if file_path.is_file():
                file_age = now - file_path.stat().st_mtime
                if file_age > max_age_seconds:
                    file_path.unlink()

    def get_stats(self, agent_id: str = None) -> Dict[str, Any]:
        """
        获取统计信息

        Args:
            agent_id: Agent ID（None 表示统计所有）

        Returns:
            dict: 统计信息
        """
        stats = {
            "timestamp": datetime.now().isoformat(),
            "shared_memory_path": str(self.base_path),
            "agents": {}
        }

        agents_to_check = [agent_id] if agent_id else self.config.get("agents", {}).keys()

        for agent in agents_to_check:
            agent_dir = self.base_path / agent
            if agent_dir.exists():
                files = list(agent_dir.glob("*"))
                total_size = sum(f.stat().st_size for f in files if f.is_file())

                stats["agents"][agent] = {
                    "message_count": len(files),
                    "total_size_bytes": total_size,
                    "total_size_mb": round(total_size / (1024 * 1024), 2)
                }

        return stats


def main():
    """命令行测试"""
    import sys

    protocol = AgentCommunicationProtocol()

    # 测试小消息（内存传输）
    small_message = {
        "type": "greeting",
        "content": "Hello from main!"
    }

    print("测试小消息传输:")
    result = protocol.send_message("main", "leader-agent-v2", small_message)
    print(json.dumps(result, indent=2, ensure_ascii=False))

    # 测试大消息（文件传输）
    large_message = {
        "type": "data",
        "content": "x" * (2 * 1024 * 1024),  # 2MB 数据
        "metadata": {"source": "test"}
    }

    print("\n测试大消息传输:")
    result = protocol.send_message("main", "utility-agent-v2", large_message)
    print(json.dumps(result, indent=2, ensure_ascii=False))

    # 查看统计
    print("\n统计信息:")
    stats = protocol.get_stats()
    print(json.dumps(stats, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()

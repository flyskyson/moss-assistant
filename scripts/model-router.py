#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
OpenClaw Model Router - Intelligent Model Selection Middleware
智能模型路由中间件 - 根据任务特征自动选择最合适的模型

Phase 3 Implementation - 2026-02-08

This router analyzes task requirements and automatically routes to the most
appropriate model based on:
- File characteristics (Chinese, emoji, size)
- Task complexity
- Model capabilities
- Cost optimization targets
"""

import sys
import os
import re
import yaml
import json
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple

# Configure logging
LOG_DIR = Path("/Users/lijian/clawd/logs")
LOG_DIR.mkdir(exist_ok=True)
LOG_FILE = LOG_DIR / "model-router.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

# Configuration path
CONFIG_PATH = Path("/Users/lijian/clawd/config/model-routing.yaml")


class ModelRouter:
    """Intelligent model routing engine"""

    def __init__(self, config_path: Path = CONFIG_PATH):
        """Initialize router with configuration"""
        self.config = self._load_config(config_path)
        self.models = self.config.get('models', {})
        self.routing_rules = self.config.get('routing_rules', [])
        self.fallback_config = self.config.get('fallback', {})
        self.monitoring_config = self.config.get('monitoring', {})

        logger.info("Model Router initialized successfully")
        logger.info(f"Loaded {len(self.models)} models, {len(self.routing_rules)} routing rules")

    def _load_config(self, config_path: Path) -> Dict:
        """Load routing configuration from YAML file"""
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = yaml.safe_load(f)
            logger.info(f"Configuration loaded from {config_path}")
            return config
        except Exception as e:
            logger.error(f"Failed to load config: {e}")
            raise

    def analyze_task(self, task_context: Dict) -> Dict:
        """
        Analyze task and determine optimal model

        Args:
            task_context: Dictionary containing:
                - task_type: str (e.g., 'file_edit', 'quick_question')
                - file_path: str (optional)
                - file_content: str (optional)
                - user_message: str (optional)

        Returns:
            Dictionary with:
                - recommended_model: str
                - reason: str
                - confidence: float
                - fallback_models: List[str]
        """
        logger.info(f"Analyzing task: {task_context.get('task_type', 'unknown')}")

        # Extract task features
        features = self._extract_features(task_context)

        # Evaluate routing rules
        selected_rule = self._evaluate_rules(features, task_context)

        # Get model recommendation
        if selected_rule:
            model_id = selected_rule['action']['use_model']
            reason = selected_rule['action'].get('reason', 'Rule matched')
            priority = selected_rule['priority']
        else:
            # Default to Flash for simple tasks
            model_id = 'gemini-2.5-flash'
            reason = 'Default model for simple tasks'
            priority = 0

        # Get model details
        model_info = self.models.get(model_id, {})
        fallback_models = self._get_fallback_order(model_id)

        result = {
            'recommended_model': model_id,
            'model_id': model_info.get('model_id', model_id),
            'provider': model_info.get('provider', 'unknown'),
            'reason': reason,
            'priority': priority,
            'confidence': self._calculate_confidence(features, selected_rule),
            'fallback_models': fallback_models,
            'features_detected': features
        }

        # Log routing decision
        if self.monitoring_config.get('log_routing_decisions', True):
            self._log_routing_decision(result)

        return result

    def _extract_features(self, task_context: Dict) -> Dict:
        """Extract features from task context"""
        features = {
            'has_chinese': False,
            'has_emoji': False,
            'is_core_config': False,
            'file_size_lines': 0,
            'file_size_bytes': 0,
            'complex_formatting': False
        }

        # Analyze file content if available
        file_content = task_context.get('file_content', '')
        file_path = task_context.get('file_path', '')

        if file_content:
            # Check for Chinese
            for char in file_content:
                if '\u4e00' <= char <= '\u9fff':
                    features['has_chinese'] = True
                    break

            # Check for emoji
            emoji_pattern = r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|✅|❌|⚠️|🔄|📝|💻|🧠|🎯|🚀|💡|🤔|📚|🔧|⭐|🦞'
            features['has_emoji'] = bool(re.search(emoji_pattern, file_content))

            # Count lines
            features['file_size_lines'] = len(file_content.splitlines())
            features['file_size_bytes'] = len(file_content.encode('utf-8'))

            # Check complex formatting
            code_blocks = file_content.count('```')
            nested_lists = len(re.findall(r'^  +-', file_content, re.MULTILINE))
            tables = len(re.findall(r'^\|', file_content, re.MULTILINE))

            features['complex_formatting'] = (
                code_blocks > 2 or nested_lists > 5 or tables > 0
            )

        # Check if core config file
        if file_path:
            file_name = Path(file_path).name
            core_configs = ['IDENTITY.md', 'USER.md', 'SOUL.md', 'TASKS.md', 'HEARTBEAT.md']
            features['is_core_config'] = file_name in core_configs

        return features

    def _evaluate_rules(self, features: Dict, task_context: Dict) -> Optional[Dict]:
        """Evaluate routing rules and return highest priority match"""
        matching_rules = []

        for rule in self.routing_rules:
            if self._matches_rule(rule, features, task_context):
                matching_rules.append(rule)

        if not matching_rules:
            return None

        # Sort by priority (descending) and return highest
        matching_rules.sort(key=lambda r: r['priority'], reverse=True)
        return matching_rules[0]

    def _matches_rule(self, rule: Dict, features: Dict, task_context: Dict) -> bool:
        """Check if task matches a routing rule"""
        condition = rule.get('condition', {})

        # Check file patterns
        if 'file_patterns' in condition:
            file_path = task_context.get('file_path', '')
            file_name = Path(file_path).name if file_path else ''
            if file_name not in condition['file_patterns']:
                return False

        # Check task types
        if 'task_types' in condition:
            task_type = task_context.get('task_type', '')
            if task_type not in condition['task_types']:
                return False

        # Check content indicators
        if 'content_indicators' in condition:
            indicators = condition['content_indicators']
            if indicators.get('has_chinese') and not features['has_chinese']:
                return False
            if indicators.get('has_emoji') and not features['has_emoji']:
                return False
            if not indicators.get('has_chinese') and features['has_chinese']:
                # Rule explicitly excludes Chinese
                return False
            if not indicators.get('has_emoji') and features['has_emoji']:
                # Rule explicitly excludes emoji
                return False

        # Check file size
        if 'file_size' in condition:
            size_constraints = condition['file_size']
            if 'min_lines' in size_constraints:
                if features['file_size_lines'] < size_constraints['min_lines']:
                    return False
            if 'max_lines' in size_constraints:
                if features['file_size_lines'] > size_constraints['max_lines']:
                    return False

        return True

    def _calculate_confidence(self, features: Dict, rule: Optional[Dict]) -> float:
        """Calculate confidence score for routing decision"""
        if not rule:
            return 0.5  # Low confidence for default

        base_confidence = 0.7

        # Increase confidence for high-priority rules
        if rule.get('priority', 0) >= 90:
            base_confidence = 0.95
        elif rule.get('priority', 0) >= 70:
            base_confidence = 0.85

        # Adjust based on feature clarity
        if features['has_chinese'] or features['has_emoji']:
            base_confidence += 0.05  # Clear signal

        if features['is_core_config']:
            base_confidence = 0.99  # Very high confidence

        return min(base_confidence, 1.0)

    def _get_fallback_order(self, primary_model: str) -> List[str]:
        """Get fallback model order"""
        fallback_rules = self.fallback_config.get('rules', [])

        # Find fallback rule
        for rule in fallback_rules:
            if rule['condition'] == 'model_unavailable':
                return rule.get('fallback_order', [])

        # Default fallback
        return ['gemini-2.5-pro', 'claude-sonnet-4']

    def _log_routing_decision(self, decision: Dict):
        """Log routing decision for monitoring"""
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'recommended_model': decision['recommended_model'],
            'reason': decision['reason'],
            'priority': decision['priority'],
            'confidence': decision['confidence'],
            'features': decision['features_detected']
        }

        logger.info(f"Routing decision: {json.dumps(log_entry, ensure_ascii=False)}")


def route_task(task_type: str, file_path: str = None, file_content: str = None) -> Dict:
    """
    Convenience function to route a task

    Usage:
        result = route_task(
            task_type='file_edit',
            file_path='/Users/lijian/clawd/IDENTITY.md',
            file_content=open('/Users/lijian/clawd/IDENTITY.md').read()
        )
        print(f"Use model: {result['recommended_model']}")
        print(f"Reason: {result['reason']}")
    """
    router = ModelRouter()

    task_context = {
        'task_type': task_type,
        'file_path': file_path,
        'file_content': file_content
    }

    return router.analyze_task(task_context)


def main():
    """CLI interface for testing"""
    if len(sys.argv) < 2:
        print("Usage: python3 model-router.py <file_path> [task_type]")
        print("")
        print("Examples:")
        print("  python3 model-router.py /Users/lijian/clawd/IDENTITY.md")
        print("  python3 model-router.py /path/to/file.py file_edit")
        sys.exit(1)

    file_path = sys.argv[1]
    task_type = sys.argv[2] if len(sys.argv) > 2 else 'file_edit'

    # Read file content
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            file_content = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

    # Route task
    result = route_task(
        task_type=task_type,
        file_path=file_path,
        file_content=file_content
    )

    # Output recommendation
    print("\n=== Model Router Recommendation ===")
    print(f"File: {Path(file_path).name}")
    print(f"Task Type: {task_type}")
    print("")
    print(f"✓ Recommended Model: {result['recommended_model']}")
    print(f"  Provider: {result['provider']}")
    print(f"  Model ID: {result['model_id']}")
    print(f"  Confidence: {result['confidence']:.0%}")
    print("")
    print(f"Reason: {result['reason']}")
    print("")
    print("Fallback order:")
    for i, model in enumerate(result['fallback_models'], 1):
        print(f"  {i}. {model}")

    # Return exit code based on recommendation
    if result['recommended_model'] == 'claude-sonnet-4':
        sys.exit(20)  # Requires Claude
    elif result['recommended_model'] == 'gemini-2.5-pro':
        sys.exit(10)  # Use Pro
    else:
        sys.exit(0)  # Flash is OK


if __name__ == '__main__':
    main()

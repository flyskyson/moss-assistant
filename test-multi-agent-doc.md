# OpenClaw Multi-Agent 架构测试文档

## 背景
OpenClaw 是一个开源的 AI Agent 平台，支持多代理协作和本地化部署。

## 核心功能
1. **多代理架构**：支持多个 AI agents 协同工作
2. **本地记忆系统**：使用 Ollama + nomic-embed-text 实现隐私优先的记忆管理
3. **成本优化**：通过智能调度策略实现 90% 的成本节省
4. **实时搜索**：集成 Tavily API 支持国内可用的网络搜索

## 技术栈
- **主要模型**：DeepSeek V3.2（主会话）、Gemini 2.5 Flash（工具代理）、MiniMax M2.1（领导代理）
- **记忆模型**：nomic-embed-text（本地部署）
- **搜索服务**：Tavily API（1000 次免费搜索/月）
- **工作区**：/Users/lijian/clawd

## 优化成果
经过架构优化后，系统配置如下：
- main agent（DeepSeek V3.2）：主会话，负责复杂分析和协调
- leader-agent-v2（MiniMax M2.1）：领导代理，负责任务分解和项目管理
- utility-agent-v2（Gemini 2.5 Flash）：工具代理，负责原子任务执行

## 预期收益
1. **成本降低**：从 Claude Sonnet 4.5 切换到成本更低的模型
2. **效率提升**：专门化的 agents 分工提高任务处理速度
3. **维护简化**：配置清晰，错误率降低
4. **扩展性**：支持未来的 Multi-Agent 协作扩展

## 测试要求
请测试这个 Multi-Agent 架构，确保各个 agents 能够：
- 正确分工协作
- 高效完成任务
- 保持配置的一致性
- 实现预期的成本节省目标
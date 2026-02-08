# 设计方案：通用“效用型”子Agent (`utility-agent`)

> **文档版本**: v1.0
> **创建日期**: 2026-02-07
> **作者**: MOSS
> **状态**: 草案

---

## 1. 愿景与定位

### 1.1. 项目愿景
创建一个专职的、低成本的、高效的子Agent，作为我们系统的“共享效用服务”，专门处理那些无需强大推理能力的、模式化的、“脏活累活”。

### 1.2. Agent 定位
- **名称**: `utility-agent`
- **模型**: 永久绑定 `Gemini-Flash` (或同等级别的其他高效模型)。
- **核心职责**: 接收一个明确、具体的指令和相应的上下文数据，然后返回一个结构化的结果。它**不**进行开放式对话或复杂的任务分解。
- **调用方式**: 主要通过 `sessions_spawn` 命令，由其他脚本、技能或主Agent进行调用。

## 2. Agent 的核心职责（v1.0）

`utility-agent` 将像一个“瑞士军刀”，提供一系列原子化的文本处理能力。初版将专注于以下几个核心“工具”：

- **文本摘要 (Summarization)**: 
    - **输入**: 一段长文本。
    - **指令**: "请将以下文本总结为3个要点。"
    - **输出**: 简洁的摘要。

- **格式转换 (Format Conversion)**:
    - **输入**: 一段JSON或CSV数据。
    - **指令**: "请将这段JSON转换为Markdown表格。"
    - **输出**: 格式化后的文本。

- **信息提取 (Information Extraction)**:
    - **输入**: 一篇新闻文章。
    - **指令**: "请从这篇文章中提取出人名、公司和关键日期。"
    - **输出**: 结构化的JSON对象。

## 3. 技术实现：`sessions_spawn` 详解

`sessions_spawn` 是我们与 `utility-agent` 交互的核心工具。它的工作流程如下：

1.  **发起方 (如 `briefing.sh` 脚本)** 调用 `openclaw sessions_spawn` 命令。
2.  在命令中，我们**精确地定义**所有需要的参数：
    *   `agentId`: 指定我们未来为 `utility-agent` 创建的专属ID。
    *   `model`: **强制指定**为 `openrouter/google/gemini-2.5-flash`。
    *   `task`: 传入一个包含了“上下文数据”和“明确指令”的、完整的任务描述。
    *   `runTimeoutSeconds`: 设置一个合理的运行超时，例如300秒，防止任务失控。
3.  OpenClaw Gateway 会创建一个**临时的、隔离的**会话，并在这个会话中运行 `utility-agent`。
4.  `utility-agent` 在那个隔离的环境中完成任务，然后将结果返回。
5.  我们的主脚本 `briefing.sh` 可以通过某种机制（例如，`sessions_spawn`会返回一个会话ID，我们可以轮询这个会话的结果）获取到处理结果。

**示例命令 (概念性)**：
```bash
# briefing.sh 脚本中的一行

# 准备任务描述
TASK_DESCRIPTION="上下文数据：${FETCHED_CONTENT}。我的指令是：请将以上文本总结为3个核心要点。"

# 调用子Agent
SUMMARY=$(openclaw sessions_spawn --agentId utility-agent --model "openrouter/google/gemini-2.5-flash" --task "${TASK_DESCRIPTION}")

# 将摘要追加到报告中
echo "$SUMMARY" >> $BRIEFING_FILE
```

## 4. 试点案例：改造 `daily-briefing` 技能 (v1.1)

我们将以“每日简报”作为第一个应用 `utility-agent` 的试点，来为我们的 “AI 技术动态” 栏目提供内容。

**改造后的 `briefing.sh` 脚本工作流程**:

1.  **获取信源 (不变)**: 脚本像以前一样，通过 `curl` 或 `web_search` 获取OpenClaw新闻和GitHub热门。

2.  **获取AI新闻**: 
    - 脚本通过 `tavily_search` (或其他搜索工具) 获取3-5篇最新的AI新闻的**URL列表**。

3.  **循环处理 & “外包”任务**: 
    - 脚本**循环**遍历这个URL列表。
    - 在每次循环中，它都会：
        1.  使用 `web_fetch` 获取该URL的全文内容。
        2.  **调用 `openclaw sessions_spawn`，将全文内容和“请总结这篇文章”的指令，作为一个任务，“外包”给 `utility-agent`**。
        3.  等待并获取 `utility-agent` 返回的摘要。
        4.  将这个摘要追加到我们的简报内容中。

4.  **生成并发送简报 (不变)**: 所有信息源都处理完毕后，脚本生成最终的简报并发送。

**这个新流程的好处**:
- **主次分明**: `briefing.sh` 变成了“项目经理”，只负责流程控制和数据流转。而真正的“AI计算”（摘要生成），则完全交给了专业的、低成本的“雇员”(`utility-agent`)。
- **成本可控**: 整个简报生成过程中，只有“摘要”这一步消耗了AI模型的费用，并且消耗的是最便宜的 `Gemini-Flash`。

## 5. 安全与资源考量

- **权限最小化**: 理论上，我们可以为 `utility-agent` 配置一个更严格的权限集，例如，不允许它访问文件系统，只允许它进行文本处理。这将在未来的版本中进行探索。
- **资源隔离**: `sessions_spawn` 创建的每一个会话都是临时的、用完即弃的。这能确保子Agent的任何意外错误或资源消耗，都不会影响到我们的主会话。
- **超时控制**: 我们必须为每一个 `spawn` 的任务设置一个合理的 `runTimeoutSeconds`，防止因为某个任务卡死，而导致子Agent进程的无限期积压。

---

## 6. 下一步行动计划

1.  **创建Agent ID**: 在 OpenClaw 的配置中，为 `utility-agent` 创建一个正式的 `agentId`。
2.  **编写原型脚本**: 创建一个简单的测试脚本，来演练一次完整的 `sessions_spawn` 调用流程，确保我们能成功地启动子Agent并获取其返回结果。
3.  **改造 `briefing.sh`**: 在原型验证成功后，正式按照上述流程，改造我们的“每日简报”脚本。

**下一步**: 等待您的批准，以启动 **“创建Agent ID”** 和 **“编写原型脚本”** 的工作。
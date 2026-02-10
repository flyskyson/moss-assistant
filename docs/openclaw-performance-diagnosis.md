# OpenClaw Agent系统性能诊断报告

**诊断日期**: 2026-02-09
**问题**: Agent响应极慢（>170秒），用户报告"经常崩溃"

## 问题症状

1. ❌ 通过Gateway调用Agent: >170秒超时
2. ❌ 使用--local模式调用Agent: 同样缓慢（>45秒未完成）
3. ✅ 直接调用DeepSeek API: <2秒正常响应
4. ❌ OpenRouter通过Agent: 同样缓慢（>3分钟未完成）

## 诊断结果

### 系统状态检查

| 检查项 | 状态 | 详情 |
|--------|------|------|
| Gateway服务 | ✅ 正常 | PID 64746, 端口18789 |
| 工作区大小 | ✅ 正常 | 53MB (合理范围) |
| 身份文件 | ✅ 正常 | 10KB |
| Ollama服务 | ✅ 运行中 | PID 11827, nomic-embed-text已安装 |
| 内存搜索配置 | ✅ 配置正确 | localhost:11434/v1 |
| 技能数量 | ⚠️  较多 | 15个技能ready |

### 性能瓶颈定位

**关键发现**:

```
直接API调用:  <2秒  ✅ 快速
   ↓
通过Agent调用: >170秒 ❌ 85倍延迟！
```

**延迟来源分析**:

1. **Gateway层**: 排除（--local模式同样慢）
2. **API提供商层**: 排除（直接调用快）
3. **Agent处理层**: ✅ **问题根源**

### 可能的延迟因素

1. **内存搜索系统**
   - 每次查询都调用Ollama embedding
   - 配置: `http://localhost:11434/v1` + `nomic-embed-text`
   - 可能原因: embedding模型推理慢

2. **技能初始化**
   - 15个已安装技能需要在每次调用时加载/检查
   - 某些技能可能有初始化开销

3. **身份文件处理**
   - IDENTITY.md (10KB) 可能包含复杂指令
   - Agent需要解析和应用这些指令

4. **其他处理流程**
   - 对话历史管理
   - 上下文构建
   - 提示词工程

## 根本原因

**OpenClaw Agent系统存在系统级性能问题，与API提供商无关。**

证据：
- DeepSeek官方API: 直接调用快，Agent调用慢 ❌
- OpenRouter: Agent调用同样慢 ❌
- --local模式: 绕过Gateway仍然慢 ❌

## 建议方案

### 方案A: 禁用内存搜索（快速测试）

**目的**: 验证内存搜索是否是性能瓶颈

**步骤**:
```bash
# 临时禁用内存搜索
openclaw config unset agents.defaults.memorySearch
openclaw gateway restart

# 测试Agent响应速度
time openclaw agent --agent main --message "你好"
```

**预期**:
- 如果速度提升到<10秒 → 内存搜索是瓶颈
- 如果仍然很慢 → 问题在其他地方

### 方案B: 简化Agent配置（中期方案）

**目的**: 减少Agent初始化开销

**步骤**:
1. 创建新的最小化Agent
2. 不加载额外技能
3. 简化IDENTITY.md
4. 禁用内存搜索

**配置示例**:
```json
{
  "agents": {
    "list": [{
      "id": "minimal-test",
      "workspace": "/tmp/MinimalAgent",
      "skills": []
    }]
  }
}
```

### 方案C: 降级OpenClaw版本（临时方案）

**目的**: 排除版本引入的性能回归

**步骤**:
```bash
npm list -g openclaw  # 检查当前版本
npm install -g openclaw@2026.2.5  # 降级到之前版本
```

### 方案D: 直接使用API（绕过方案）

**目的**: 实现快速响应，绕过Agent系统

**实现**:
```bash
# 创建简单的wrapper脚本
call_deepseek() {
    curl -s -X POST 'https://api.deepseek.com/v1/chat/completions' \
      -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
      -d "{\"model\":\"deepseek-chat\",\"messages\":[{\"role\":\"user\",\"content\":\"$1\"}]}" \
      | jq -r '.choices[0].message.content'
}
```

**优点**:
- 快速响应（<2秒）
- 稳定可靠
- 完全控制

**缺点**:
- 失去OpenClaw的高级功能（技能、内存、路由等）

### 方案E: 联系OpenClaw支持（根本解决）

**步骤**:
1. 收集诊断日志: `/tmp/openclaw/openclaw-2026-02-09.log`
2. 记录性能对比数据（API直接调用 vs Agent调用）
3. 提交issue到: https://github.com/openclaw
4. 包含系统信息: macOS 23.6.0, Node 24.13.0, OpenClaw 2026.2.6-3

## 测试建议暂停

**原因**:
用户要求测试的5个稳定性方案（模型回退、并发控制、重试配置、负载均衡、监控脚本）都是针对**API提供商层面**的优化。

但当前问题的根源在**OpenClaw Agent系统**，不在API提供商。

**证据**:
- DeepSeek官方API直接调用: ✅ 2秒
- DeepSeek通过Agent: ❌ 170秒
- OpenRouter通过Agent: ❌ >180秒

**结论**: 继续测试API层面优化无法解决根本问题。

## 推荐行动路径

### 立即行动（今天）
1. ✅ 测试方案A（禁用内存搜索）- 5分钟
2. 根据结果决定下一步

### 短期方案（本周）
- 如果方案A有效 → 优化内存搜索配置
- 如果方案A无效 → 尝试方案B（简化Agent）或方案D（直接API）

### 长期方案（本月）
- 执行方案E（联系OpenClaw支持）
- 考虑降级版本或等待修复

## 当前配置摘要

```json
{
  "model": {
    "primary": "openrouter/deepseek/deepseek-v3.2",
    "fallbacks": []
  },
  "timeoutSeconds": 120,
  "maxConcurrent": 2,
  "memorySearch": {
    "provider": "openai",
    "remote": {
      "baseUrl": "http://localhost:11434/v1",
      "apiKey": "ollama"
    },
    "model": "nomic-embed-text"
  }
}
```

---

**诊断状态**: ⚠️  Agent系统存在严重性能问题
**建议**: 优先测试方案A（禁用内存搜索），然后根据结果决定下一步
**测试状态**: 建议暂停API层面优化测试，直到Agent性能问题解决

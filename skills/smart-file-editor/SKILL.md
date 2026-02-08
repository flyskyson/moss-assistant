---
name: smart-file-editor
description: Intelligent file editor that automatically detects Chinese/emoji content and chooses the safest editing strategy (Edit vs Write). Prevents 30+ minute hangs caused by Gemini's tokenization issues.
---

# Smart File Editor

## Overview

This skill solves the critical file editing problem with Gemini 2.5 Flash/Pro models:
- **Problem**: Chinese characters and emoji cause Edit tool to fail (tokenization inconsistency)
- **Result**: 30+ minute hangs while Agent retries infinitely
- **Solution**: Auto-detect problematic content and use Write strategy instead

## Key Features

✅ **Content Detection**: Automatically detects Chinese, emoji, and complex formatting
✅ **Strategy Selection**: Chooses between Edit and Write based on file analysis
✅ **Timeout Protection**: 3-minute limit with automatic fallback
✅ **Error Recovery**: Switches strategies on failure without user intervention

## Usage

### When Agent Should Use This Skill

**Default Rule**: For any file editing task, first analyze the file:

```javascript
// Before editing, run:
./skills/smart-file-editor/analyze.sh /path/to/file

// Output will tell you:
// - SAFE_TO_EDIT: Use Edit tool
// - USE_WRITE_STRATEGY: Use Read + Write
// - REQUIRE_CLAUDE: Must use Claude Sonnet
```

### Detection Rules

**File Properties Checked**:
1. **Chinese characters**: `/[\u4e00-\u9fa5]/`
2. **Emoji**: `/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]/u`
3. **File size**: Line count and byte size
4. **Formatting complexity**: Nested markdown, code blocks, tables
5. **File type**: Core config files (IDENTITY.md, USER.md, etc.)

**Decision Matrix**:

| Condition | Strategy | Reason |
|-----------|----------|---------|
| Chinese detected | Write | Tokenization issues with Edit |
| Emoji detected | Write | Multi-byte characters cause mismatches |
| > 100 lines | Write | Large files = higher failure risk |
| Core config file | Write + Claude | Critical files need maximum reliability |
| < 50 lines, English only | Edit (optional) | Safe for simple cases |
| > 3 Edit failures | Write | Automatic fallback |

## Implementation

### Strategy 1: Edit Tool (Limited Use)

**When**:
- Files < 50 lines
- English-only content
- Simple formatting
- Single line or small range modifications

**Steps**:
```javascript
edit({
  filePath: "/path/to/file",
  oldString: "exact text to replace",
  newString: "new text"
})
```

**Risks**:
- String must match EXACTLY (including spaces, newlines)
- Fails with Chinese/emoji
- Can get stuck in retry loops

### Strategy 2: Write Tool (Preferred)

**When**:
- Any Chinese/emoji content
- Files > 50 lines
- Complex formatting
- Core configuration files

**Steps**:
```javascript
// 1. Read entire file
const content = read({ filePath: "/path/to/file" })

// 2. Modify in memory
let modified = content.replace(/search/g, "replace")

// 3. Write complete file
write({
  filePath: "/path/to/file",
  content: modified
})
```

**Advantages**:
- No string matching issues
- Works with any language
- More reliable and predictable
- No retry loops

## Core Config File Workflow

For IDENTITY.md, USER.md, SOUL.md, TASKS.md, HEARTBEAT.md:

**CRITICAL**: These files require special handling:

1. Read the file
2. Prepare modification proposal
3. **Get user approval**
4. Execute using Write strategy
5. Verify changes

**Never edit these files directly without user approval.**

## Timeout Protection

**Rules**:
1. **3-minute limit** for any editing operation
2. **3 Edit failures** → Switch to Write strategy
3. **No progress** → Report to user immediately

**Symptoms of failure**:
- Agent says "thinking" for > 2 minutes
- Agent repeatedly reads file without output
- Agent keeps retrying without progress

**What to do**:
1. Stop the task
2. Report the issue
3. Suggest using Claude Sonnet

## Model Selection

| Task | Recommended Model | Why |
|------|------------------|-----|
| **Core config files** | Claude Sonnet | Most reliable, proven |
| **Chinese/emoji files** | Claude Sonnet | No tokenization issues |
| **Files > 100 lines** | Claude Sonnet or Gemini Pro | Better error handling |
| **Simple English < 50 lines** | Gemini Flash | Fast, cost-effective |
| **Complex refactoring** | Claude Sonnet | Better planning |

**Evidence**: 2026-02-08 testing:
- index.md (130 lines, Chinese): Claude <1 min, Gemini Flash >30 min (failed)
- IDENTITY.md (305 lines): Gemini Flash 30+ min (completed after prompting)
- USER.md (287 lines): Gemini Flash completely stuck

## Agent Instructions

When MOSS receives a file editing task:

1. **Run analysis**:
   ```bash
   ./skills/smart-file-editor/analyze.sh "target_file"
   ```

2. **Follow recommendation**:
   - SAFE_TO_EDIT → Use Edit tool
   - USE_WRITE_STRATEGY → Use Read + Write
   - REQUIRE_CLAUDE → Tell user to switch models

3. **Monitor time**:
   - If > 3 minutes → STOP and report
   - If 3 Edit failures → Switch to Write

4. **Report issues**:
   - Tell user what went wrong
   - Suggest alternative (Claude Sonnet)
   - Document in memory file

## Troubleshooting

**Skill not working**:
- Check execute permissions: `chmod +x skills/smart-file-editor/*.sh`
- Verify Node.js is installed: `node --version`
- Test analysis: `./skills/smart-file-editor/analyze.sh test.txt`

**Analysis incorrect**:
- Check file encoding: `file -i filename`
- Verify line endings: `file filename`
- Report issues for improvement

**Edit still failing**:
- Use Write strategy
- Switch to Claude Sonnet
- Check AGENTS.md for detailed rules

## Version History

- **v1.0** (2026-02-08): Initial release with Chinese/emoji detection and strategy selection

## Related Documentation

- **AGENTS.md**: File Editing Tool Strategy section
- **IDENTITY.md**: Model dispatch strategy and file editing rules
- **memory/2026-02-08.md**: Deep research on Gemini file editing issues

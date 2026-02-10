---
name: tavily-search
description: Web search via Tavily API (AI-optimized for agents). Use for real-time information, facts, documentation, and current events. Works in China without VPN.
---

# Tavily Search

AI-optimized web search using Tavily API. Designed specifically for AI agents with automatic content extraction and summarization.

## Features

- ✅ **AI-optimized results**: Refined for LLM consumption
- ✅ **Works in China**: No VPN required
- ✅ **Automatic summarization**: Built-in answer synthesis
- ✅ **Content extraction**: Clean, structured output
- ✅ **Free tier**: 1000 searches/month

## Setup

API Key is pre-configured. To use your own key:

```bash
export TAVILY_API_KEY="your_api_key_here"
```

## Usage

**Basic search:**
```bash
./search.js "your search query"
```

**With result limit:**
```bash
./search.js "your search query" 5
```

## Output Format

```
--- Search Results for: "query" ---

📌 Summary: AI-generated answer summary

--- Result 1 ---
Title: Page Title
URL: https://example.com
Snippet: Brief content snippet...

--- Result 2 ---
...
```

## When to Use

- Searching for current events and news
- Looking up technical documentation
- Fact-checking and verification
- Retrieving real-time data
- Research and information gathering

## API Key

Get your free API key at: https://tavily.com
- Free tier: 1000 searches/month
- No credit card required

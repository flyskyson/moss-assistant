# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- API keys and endpoints
- Anything environment-specific

## 🔗 Web Search - Tavily API

**Location:** `/Users/lijian/clawd/skills/tavily-search/`

**API Key:** `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`

**Usage:**
```bash
./skills/tavily-search/search.js "search query" [max_results]
```

**Features:**
- AI-optimized search results
- Automatic summarization
- Content extraction
- Works in China (no VPN needed)
- Free tier: 1000 searches/month

**Get more API keys:** https://tavily.com

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

---
name: daily-briefing
description: Generate and deliver a daily AI & tech briefing. Fetches latest updates from OpenClaw and GitHub trending, compiles into a structured Markdown report. Use this when user asks for daily tech news, AI updates, or wants to set up automated briefings.
---

# Daily AI & Tech Briefing

## Overview

This skill generates a customized daily briefing covering:
- 🦞 **OpenClaw Updates**: Latest releases, blog posts, and announcements
- 🔥 **GitHub Trending**: Today's hottest repositories
- 🤖 **AI News**: Recent developments in AI/ML

## Usage

### Manual Execution

When you need an immediate briefing:

```
Generate a daily AI tech briefing for me
```

### Automated Delivery (Cron)

**Expression**: `0 10 * * *` (Every day at 10:00 AM)

**Setup Command**:
```bash
# Add to crontab
crontab -e

# Add this line:
0 10 * * * /Users/lijian/clawd/skills/daily-briefing/briefing.sh >> /Users/lijian/clawd/logs/daily-briefing.log 2>&1
```

## Implementation Notes

### Script Requirements

The briefing script (`briefing.sh`):
1. Uses `tavily-search` skill for web searches
2. Fetches GitHub trending page
3. Compiles Markdown report
4. Saves to workspace: `/Users/lijian/clawd/briefings/YYYY-MM-DD.md`
5. Can be integrated with notification channels

### Data Sources

- **OpenClaw**: https://openclaw.ai/blog
- **GitHub Trending**: https://github.com/trending
- **AI News**: Various tech blogs (via Tavily search)

### Customization

To customize briefing sources or timing:
1. Edit `briefing.sh`
2. Modify the `fetch_sections()` function
3. Update cron expression as needed

## Troubleshooting

**No briefing generated**:
- Check logs: `tail -f /Users/lijian/clawd/logs/daily-briefing.log`
- Verify tavily-search skill is installed: `openclaw skills list`
- Test manual execution: `./briefing.sh`

**Empty briefing**:
- Network connectivity issues
- Source websites may be down
- Check script output for errors

## Version History

- **v1.0** (2026-02-07): Initial release with OpenClaw and GitHub sources

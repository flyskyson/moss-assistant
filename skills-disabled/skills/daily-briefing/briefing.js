#!/usr/bin/env node

/**
 * Daily AI & Tech Briefing Script
 * Version: 3.0 (Correct Tavily SDK Usage)
 * Authors: MOSS & 飞天
 * Purpose: Generate daily AI/tech news briefing
 *
 * Usage: node briefing.js
 * Cron: 0 10 * * * node /Users/lijian/clawd/skills/daily-briefing/briefing.js
 */

const fs = require('fs');
const path = require('path');

// Configuration
const TAVILY_API_KEY = process.env.TAVILY_API_KEY || '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';
const OUTPUT_FILE = '/Users/lijian/clawd/outputs/daily-briefing/latest.md';

// Format search results
function formatResults(results) {
    if (!results || !results.results || results.results.length === 0) {
        return "No new updates found.\n";
    }

    return results.results.map((r, i) => {
        return `${i + 1}. **[${r.title}](${r.url})**\n   ${r.content ? r.content.slice(0, 150) + '...' : ''}\n`;
    }).join('\n');
}

// Main function
async function main() {
    // Initialize Tavily client
    let tavily;
    try {
        const module = await import('@tavily/core');
        tavily = module.tavily({ apiKey: TAVILY_API_KEY });
    } catch (error) {
        console.error('Failed to initialize Tavily client:', error.message);
        process.exit(1);
    }

    const startTime = new Date();
    console.log(`🚀 [${startTime.toISOString()}] Starting Daily Briefing generation...`);

    let briefingContent = `# 🤖 每日AI技术动态简报\n`;
    briefingContent += `**生成时间**: ${startTime.toISOString().slice(0, 10)} ${startTime.toTimeString().slice(0, 8)}\n\n`;

    try {
        // --- 1. Fetch OpenClaw News ---
        console.log('🔍 Fetching OpenClaw news...');
        const clawResults = await tavily.search('OpenClaw AI agent latest updates blog', { maxResults: 5 });
        briefingContent += `## 🦞 OpenClaw 最新动态\n\n${formatResults(clawResults)}\n\n`;

        // --- 2. Fetch AI Tech News ---
        console.log('🤖 Fetching AI tech news...');
        const aiResults = await tavily.search('latest AI technology news 2026', { maxResults: 5 });
        briefingContent += `## 🤖 AI 技术动态\n\n${formatResults(aiResults)}\n\n`;

        // --- 3. Fetch GitHub Trending (AI) ---
        console.log('🔥 Fetching GitHub trending...');
        const githubResults = await tavily.search('github trending artificial intelligence', { maxResults: 5 });
        briefingContent += `## 🔥 GitHub 热门项目\n\n${formatResults(githubResults)}\n\n`;

        // --- 4. Save to file ---
        const outputDir = path.dirname(OUTPUT_FILE);
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }
        fs.writeFileSync(OUTPUT_FILE, briefingContent);
        console.log(`💾 Saved to ${OUTPUT_FILE}`);

        // --- 5. Summary output ---
        console.log('✅ Daily Briefing generated successfully!');
        console.log(`📄 Content length: ${briefingContent.length} characters`);

        process.exit(0);

    } catch (error) {
        console.error('❌ Error generating briefing:', error);
        process.exit(1);
    }
}

// Run
main();
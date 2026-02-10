#!/usr/bin/env node

/**
 * AI-Generated Daily Briefing
 * Version: 1.0
 * 特点: 直接使用AI API生成简报，最简单最智能
 */

const https = require('https');

// 配置 - 使用你的DeepSeek API
const API_KEY = process.env.DEEPSEEK_API_KEY || '';
const API_URL = 'https://api.deepseek.com/v1/chat/completions';

async function callAI(prompt) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            model: 'deepseek-chat',
            messages: [
                {
                    role: 'system',
                    content: '你是一个专业的AI技术新闻编辑。擅长总结和提炼技术新闻要点。'
                },
                {
                    role: 'user',
                    content: prompt
                }
            ],
            temperature: 0.7,
            max_tokens: 2000
        });

        const options = {
            hostname: 'api.deepseek.com',
            path: '/v1/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${API_KEY}`
            }
        };

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    const response = JSON.parse(body);
                    resolve(response.choices[0].message.content);
                } catch (error) {
                    reject(error);
                }
            });
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

async function main() {
    console.log('🤖 使用AI生成今日简报...');

    const prompt = `
请生成一份"AI技术每日简报"，包含以下部分：

1. **今日AI头条** - 最重要的3条AI新闻
2. **OpenClaw动态** - OpenClaw/AI Agent相关动态
3. **技术前沿** - 最新的AI技术突破
4. **工具推荐** - 值得关注的AI工具或项目

要求：
- 每条新闻包含：标题 + 一句话摘要
- 使用中文
- 新闻要真实（基于你2025年的知识）
- 格式清晰，用Markdown

现在请生成简报：
`;

    try {
        const briefing = await callAI(prompt);

        const fs = require('fs');
        const path = require('path');

        const OUTPUT_FILE = '/Users/lijian/clawd/outputs/daily-briefing/latest.md';
        const outputDir = path.dirname(OUTPUT_FILE);

        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }

        const content = `# 🤖 每日AI技术动态简报\n\n` +
                       `**生成时间**: ${new Date().toLocaleString('zh-CN', {timeZone: 'Asia/Shanghai'})}\n\n` +
                       `**生成方式**: AI智能生成\n\n---\n\n` +
                       briefing;

        fs.writeFileSync(OUTPUT_FILE, content, 'utf8');

        console.log('✅ 简报生成成功!');
        console.log(`📄 保存位置: ${OUTPUT_FILE}`);
        console.log(`📊 内容长度: ${content.length} 字符`);

        console.log('\n📋 简报预览:');
        console.log('='.repeat(50));
        console.log(content.slice(0, 500));
        console.log('...');

    } catch (error) {
        console.error('❌ 错误:', error.message);
        process.exit(1);
    }
}

main();

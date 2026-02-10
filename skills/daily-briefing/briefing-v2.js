#!/usr/bin/env node

/**
 * Enhanced Daily Briefing - Using NewsAPI
 * Version: 2.0
 * 特点: 使用专业新闻API，内容质量高，分类清晰
 */

const https = require('https');

// 配置
const NEWS_API_KEY = process.env.NEWS_API_KEY || ''; // 需要申请免费的
const OUTPUT_FILE = '/Users/lijian/clawd/outputs/daily-briefing/latest.md';

// 备用方案：使用搜索引擎聚合
async function fetchWithFallback() {
    const sources = [
        // TechCrunch AI RSS
        'https://techcrunch.com/category/artificial-intelligence/feed/',
        // The Verge AI
        'https://www.theverge.com/ai-artificial-intelligence/rss/index.xml',
        // OpenClaw Blog
        'https://openclaw.ai/blog/rss.xml'
    ];

    let allNews = [];

    for (const source of sources) {
        try {
            const news = await fetchRSS(source);
            allNews = allNews.concat(news);
        } catch (error) {
            console.log(`警告: 无法抓取 ${source}`);
        }
    }

    return allNews;
}

// 简单的RSS解析
async function fetchRSS(url) {
    return new Promise((resolve, reject) => {
        https.get(url, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                // 简单的XML解析
                const items = data.match(/<item>([\s\S]*?)<\/item>/g) || [];
                const news = items.slice(0, 5).map(item => {
                    const title = item.match(/<title>(.*?)<\/title>/)?.[1] || '';
                    const link = item.match(/<link>(.*?)<\/link>/)?.[1] || '';
                    const description = item.match(/<description>(.*?)<\/description>/)?.[1] || '';
                    const pubDate = item.match(/<pubDate>(.*?)<\/pubDate>/)?.[1] || '';

                    return {
                        title: title.replace(/<!\[CDATA\[(.*?)\]\]>/, '$1'),
                        url: link,
                        content: description.replace(/<!\[CDATA\[(.*?)\]\]>/, '$1').replace(/<[^>]*>/g, ''),
                        date: pubDate
                    };
                });
                resolve(news);
            });
        }).on('error', reject);
    });
}

// 格式化输出
function formatBriefing(news) {
    let content = `# 🤖 每日AI技术动态简报\n\n`;
    content += `**生成时间**: ${new Date().toLocaleString('zh-CN', {timeZone: 'Asia/Shanghai'})}\n\n`;
    content += `**新闻数量**: ${news.length}\n\n---\n\n`;

    // 按来源分组
    const grouped = groupBySource(news);

    for (const [source, items] of Object.entries(grouped)) {
        content += `## 📰 ${source}\n\n`;
        items.forEach((item, index) => {
            content += `### ${index + 1}. ${item.title}\n\n`;
            content += `${item.content.slice(0, 200)}...\n\n`;
            content += `🔗 [阅读原文](${item.url})\n\n`;
            content += `📅 ${new Date(item.date).toLocaleDateString('zh-CN')}\n\n---\n\n`;
        });
    }

    return content;
}

// 按来源分组
function groupBySource(news) {
    const grouped = {};
    news.forEach(item => {
        const source = getSourceName(item.url);
        if (!grouped[source]) {
            grouped[source] = [];
        }
        grouped[source].push(item);
    });
    return grouped;
}

// 获取来源名称
function getSourceName(url) {
    if (url.includes('techcrunch')) return 'TechCrunch AI';
    if (url.includes('theverge')) return 'The Verge AI';
    if (url.includes('openclaw')) return 'OpenClaw 官方';
    return '其他来源';
}

// 主函数
async function main() {
    console.log('🚀 开始生成简报...');

    try {
        const news = await fetchWithFallback();
        console.log(`✅ 获取到 ${news.length} 条新闻`);

        const content = formatBriefing(news);

        const fs = require('fs');
        const path = require('path');

        const outputDir = path.dirname(OUTPUT_FILE);
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }

        fs.writeFileSync(OUTPUT_FILE, content, 'utf8');
        console.log(`✅ 简报已保存: ${OUTPUT_FILE}`);
        console.log(`📊 内容长度: ${content.length} 字符`);

        // 输出预览
        console.log('\n📋 简报预览:');
        console.log('='.repeat(50));
        console.log(content.split('\n').slice(0, 20).join('\n'));
        console.log('...');

    } catch (error) {
        console.error('❌ 错误:', error.message);
        process.exit(1);
    }
}

main();

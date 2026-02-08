#!/usr/bin/env node

const fetch = require('node-fetch');

const API_KEY = process.env.TAVILY_API_KEY || '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';
const API_URL = 'https://api.tavily.com/search';

async function search(query, maxResults = 10) {
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        api_key: API_KEY,
        query: query,
        search_depth: 'basic',
        max_results: maxResults,
        include_answer: true,
        include_raw_content: false,
      }),
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();

    // Format output
    console.log(`--- Search Results for: "${query}" ---\n`);

    if (data.answer) {
      console.log(`📌 Summary: ${data.answer}\n`);
    }

    data.results.forEach((result, index) => {
      console.log(`--- Result ${index + 1} ---`);
      console.log(`Title: ${result.title}`);
      console.log(`URL: ${result.url}`);
      console.log(`Snippet: ${result.content}\n`);
    });

    return data;
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

// CLI interface
const args = process.argv.slice(2);
if (args.length === 0) {
  console.log('Usage: ./search.js "<query>" [max_results]');
  console.log('Example: ./search.js "OpenClaw AI agent" 5');
  process.exit(1);
}

const query = args[0];
const maxResults = parseInt(args[1]) || 10;

search(query, maxResults);

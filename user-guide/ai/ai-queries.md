---
title: AI Queries
description: Ask questions about your data in plain English and get SQL queries generated automatically. No SQL knowledge required.
section: user-guide
category: ai
order: 1
toc: true
keywords:
  - AI
  - natural language
  - NL query
  - ask question
  - generate SQL
  - chat
---

DataReporter includes an AI-powered query assistant that lets you ask questions about your data in plain English. The AI generates SQL queries, explains what they do, and can execute them against your data source.

## Opening the AI Chat

Click **"AI"** in the top navigation bar to open the AI chat interface. The page has two panels:

- **Left panel** -- Conversation thread where you ask questions and see responses
- **Right panel** -- Generated SQL, explanations, and query results

## Asking Your First Question

1. Select a **data source** from the dropdown (shown when no conversation is active)
2. Type a question in the input field at the bottom, for example:
   - "Show me the top 10 customers by revenue this month"
   - "How many orders were placed last week?"
   - "What is the average order value by country?"
3. Press **Enter** or click the send button

The AI will analyze your database schema, generate a SQL query, and explain what it does.

## Understanding the Results

After asking a question, the right panel shows:

- **SQL Query** -- The generated SELECT statement. You can review it before executing.
- **Explanation** -- A plain-language description of what the query does and which tables it uses.
- **Tables Used** -- Which database tables the query references.

## Executing Queries

The AI generates queries but does not execute them automatically. To run a query:

1. Review the generated SQL in the right panel
2. Click **"Execute"** to run it against your data source
3. Results appear in a table below the SQL

> **Note:** For safety, the AI can only generate SELECT queries. It cannot create INSERT, UPDATE, DELETE, DROP, or any other data-modifying statements.

## Follow-up Questions

The AI remembers your conversation context. You can ask follow-up questions that build on previous ones:

- "Now break that down by month"
- "Add a filter for orders over $100"
- "Show me the same data but for last year"

Each response appears in the conversation thread. Click on any previous message to view its associated SQL and results in the right panel.

## Tips for Better Results

- **Be specific about metrics** -- "total revenue" is better than "how much money"
- **Mention time ranges** -- "last 30 days", "this quarter", "since January"
- **Name tables or entities when you know them** -- "from the orders table" helps the AI pick the right tables
- **Start simple, then refine** -- Ask a basic question first, then use follow-ups to add filters, grouping, or sorting

## Stopping a Query

If the AI is taking too long to respond, click the **Stop** button in the input area to cancel the request.

## Query Timeout

Executed queries have a maximum runtime of 2 minutes. If a query takes longer, it will time out and you will see an error message suggesting you simplify the query.

## Supported AI Providers

DataReporter supports multiple AI providers for query generation. Your administrator configures which providers are available. The supported providers are:

| Provider | Description |
|----------|-------------|
| **OpenAI** | GPT models (GPT-4o, GPT-4o-mini, GPT-4.1) |
| **Google Gemini** | Gemini models (Gemini 2.5 Flash, Gemini 2.5 Pro) |
| **Anthropic Claude** | Claude models (Claude Sonnet, Claude Haiku) |
| **Ollama** | Self-hosted open-source models (DeepSeek, Llama) |

> **Note:** If no AI providers are configured, you will see a message directing you to contact your administrator. See the [AI Configuration](/docs/open-source/admin-guide/ai-configuration/) guide for setup instructions.

## Security

- All generated queries are validated to ensure they are **read-only SELECT statements**
- Dangerous SQL patterns (injection attempts, file operations, timing attacks) are automatically blocked
- The AI only sees your database schema (table and column names), not your actual data
- Query results are subject to the same permissions as regular DataReporter queries

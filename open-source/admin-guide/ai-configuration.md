---
title: AI Configuration
description: Configure AI providers for natural language query generation in DataReporter. Supports OpenAI, Google Gemini, Anthropic Claude, and Ollama.
section: open-source
category: admin-guide
order: 10
toc: true
keywords:
  - AI
  - configuration
  - OpenAI
  - Gemini
  - Claude
  - Anthropic
  - Ollama
  - NL query
  - natural language
  - LLM
---

DataReporter's AI query feature allows users to ask questions about their data in plain English. As an administrator, you need to configure at least one AI provider before users can use this feature.

## Supported Providers

| Provider | API Key Required | Self-Hosted | Best For |
|----------|:---:|:---:|----------|
| **OpenAI** | Yes | No | General-purpose, widely used |
| **Google Gemini** | Yes | No | Fast responses, large context window |
| **Anthropic Claude** | Yes | No | Precise SQL generation, strong reasoning |
| **Ollama** | No | Yes | Privacy-sensitive environments, no external API calls |

## Configuration Methods

AI providers can be configured in two ways. Settings configured via the Admin UI take precedence over environment variables.

### Method 1: Admin UI (Recommended)

1. Log in as an administrator
2. Go to **Settings > General**
3. Scroll down to the **AI Query Settings** section
4. Set your preferred **Default Provider** and **Default Model**
5. Enter API keys for the providers you want to enable
6. Click **Save**

API keys are stored encrypted in the database and are masked in the UI after saving (only the last 4 characters are visible).

> **Tip:** Leave a field blank to fall back to the environment variable value. This lets you set a base configuration via environment variables and override per-organization via the UI.

### Method 2: Environment Variables

Add these variables to your `.env` file or container environment:

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key | (empty) |
| `GEMINI_API_KEY` | Google Gemini API key | (empty) |
| `ANTHROPIC_API_KEY` | Anthropic Claude API key | (empty) |
| `OLLAMA_API_URL` | Ollama server URL | `http://ollama:11434` |
| `AI_PROVIDER` | Default AI provider (`openai`, `gemini`, `anthropic`, `ollama`) | (auto-detect) |
| `AI_MODEL` | Default model override | (provider default) |
| `AI_QUERY_TIMEOUT` | Maximum time in seconds for AI API calls | `60` |
| `AI_MAX_RESULT_ROWS` | Maximum rows returned from AI-generated queries | `10000` |
| `AI_SHOW_FAILED_SQL` | Show the generated SQL even when validation fails | `false` |

## Provider Setup

### OpenAI

1. Create an account at [platform.openai.com](https://platform.openai.com)
2. Go to API Keys and create a new key
3. Set `OPENAI_API_KEY` in your environment or enter it in the Admin UI

**Available models:** `gpt-4o`, `gpt-4o-mini`, `gpt-4.1-mini`, `gpt-4.1`

Default model: `gpt-4o-mini`

### Google Gemini

1. Go to [aistudio.google.com](https://aistudio.google.com)
2. Create an API key
3. Set `GEMINI_API_KEY` in your environment or enter it in the Admin UI

**Available models:** `gemini-2.5-flash`, `gemini-2.5-pro`

Default model: `gemini-2.5-flash`

> **Note:** The `google-genai` Python package must be installed. It is included in the default DataReporter Docker image.

### Anthropic Claude

1. Create an account at [console.anthropic.com](https://console.anthropic.com)
2. Go to API Keys and create a new key
3. Set `ANTHROPIC_API_KEY` in your environment or enter it in the Admin UI

**Available models:** `claude-sonnet-4-20250514`, `claude-haiku-4-5-20251001`

Default model: `claude-sonnet-4-20250514`

### Ollama (Self-Hosted)

Ollama lets you run open-source AI models locally without sending data to external APIs.

1. Install Ollama on a server accessible from your DataReporter instance ([ollama.com](https://ollama.com))
2. Pull a model: `ollama pull deepseek-r1:7b`
3. Set `OLLAMA_API_URL` to your Ollama server address (e.g., `http://ollama-host:11434`)

**Recommended models:** `deepseek-r1:7b`, `llama3:8b`, `codellama:13b`

Default model: `deepseek-r1:7b`

> **Note:** Ollama is always shown as available if a URL is configured, since it does not require an API key. Make sure the Ollama server is running and accessible.

## Choosing a Default Provider

If no default provider is set, DataReporter auto-detects the first available provider (based on which API keys are configured). To set a specific default:

- **Admin UI:** Select from the "Default Provider" dropdown in Settings > General
- **Environment:** Set `AI_PROVIDER=gemini` (or `openai`, `anthropic`, `ollama`)

## Choosing a Default Model

Each provider has a sensible default model. To override:

- **Admin UI:** Enter the model name in the "Default Model" field
- **Environment:** Set `AI_MODEL=gpt-4o`

Leave blank to use the provider's default model.

## Security Considerations

- **SQL validation:** All AI-generated queries are validated to ensure they are read-only SELECT statements. INSERT, UPDATE, DELETE, DROP, and other dangerous statements are automatically rejected.
- **Injection protection:** The validator blocks SQL injection patterns including multi-statement execution, file operations (INTO OUTFILE), and timing attacks (SLEEP, BENCHMARK).
- **Schema-only access:** The AI receives only table and column names from the database schema. It does not have access to actual data rows.
- **Permission enforcement:** Users can only query data sources they have been granted access to. The AI feature respects DataReporter's existing permission model.
- **API key storage:** Keys configured via the Admin UI are stored in the database and masked when displayed. They are never exposed to non-admin users or included in API responses.
- **Result limits:** Query results are capped at `AI_MAX_RESULT_ROWS` (default 10,000) to prevent accidentally loading massive datasets.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "AI provider not configured" message | Set at least one API key via Admin UI or environment variables |
| "No schema available" error | Go to Settings > Data Sources, click your data source, and click "Refresh Schema" |
| Timeout errors | Increase `AI_QUERY_TIMEOUT` or use a faster model (e.g., `gpt-4o-mini` instead of `gpt-4o`) |
| Poor query quality | Try a more capable model, or be more specific in your questions. Include table names if you know them. |
| Ollama connection refused | Verify the Ollama server is running and the URL is correct. Check network/firewall rules between containers. |

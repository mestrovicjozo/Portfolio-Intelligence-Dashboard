# Portfolio Intelligence Dashboard

AI-powered portfolio tracking with news sentiment analysis and natural language Q&A.

## Quick Start

```bash
git clone https://github.com/mestrovicjozo/Portfolio-Intelligence-Dashboard.git
cd Portfolio-Intelligence-Dashboard
cp backend/.env.example backend/.env
# Edit backend/.env with your API keys (see below)
docker compose up -d
```

Access at: **http://localhost:3000**

## Required API Keys

| Service | Purpose | Free Tier | Get Key |
|---------|---------|-----------|---------|
| **Gemini** | AI features (sentiment, Q&A, insights) | 60 req/min | [Google AI Studio](https://aistudio.google.com/app/apikey) |
| **Finnhub** | Stock prices | 60 calls/min | [finnhub.io](https://finnhub.io/register) |
| **Jina AI** | Embeddings for semantic search | 1M tokens/month | [jina.ai](https://jina.ai/embeddings/) |
| **Alpha Vantage** | News articles | 25 req/day | [alphavantage.co](https://www.alphavantage.co/support/#api-key) |

**Optional:**
- **Serper** - Web search for research feature ([serper.dev](https://serper.dev/))

## Test Data

After starting the app, seed a sample portfolio with tech stocks:

```bash
docker compose exec backend python -m backend.scripts.seed_sample_data
```

This creates a "Sample Portfolio" with AAPL, MSFT, GOOGL, NVDA, and AMZN positions.

To remove the sample data:
```bash
docker compose exec backend python -m backend.scripts.seed_sample_data --remove
```

## Features

- **Dashboard** - Track positions with real-time P&L, top gainers/losers
- **News** - Aggregated financial news with AI sentiment analysis
- **Ask AI** - Natural language questions about your portfolio
- **Roboadvisor** - AI-powered portfolio recommendations

## Tech Stack

- **Backend:** FastAPI, PostgreSQL, ChromaDB
- **Frontend:** React, Vite, TanStack Query
- **AI:** Google Gemini, Jina Embeddings

## URLs

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| API | http://localhost:8000 |
| API Docs | http://localhost:8000/api/docs |

---

Built with [Claude Code](https://claude.ai/claude-code)

# Portfolio Intelligence Dashboard

An AI-powered portfolio tracking and analysis system that combines stock market data, news sentiment analysis, and natural language question-answering to help investors manage and understand their portfolios.

## Features

- **Multi-Portfolio Management**: Create and switch between multiple portfolios
- **Position Tracking**: Track shares, cost basis, and real-time profit/loss
- **News Aggregation**: Automatically fetch and organize relevant financial news
- **AI Sentiment Analysis**: Analyze news sentiment using Google Gemini
- **Stock-Specific Insights**: Get AI-generated insights for individual stocks
- **Natural Language Q&A**: Ask questions about your portfolio and get AI-generated answers
- **Semantic Search**: Find relevant news articles using vector similarity search
- **Interactive Dashboard**: Modern React UI with real-time portfolio metrics

## Tech Stack

### Backend
- FastAPI (Python web framework)
- PostgreSQL (Relational database)
- ChromaDB (Vector database for embeddings)
- Google Gemini (LLM for AI features)
- Alpha Vantage API (Stock data and news)

### Frontend
- React + Vite
- TanStack Query (Data fetching)
- Lucide React (Icons)
- Recharts (Visualization)

## Prerequisites

- Python 3.11+
- Node.js 18+
- PostgreSQL 14+
- Docker & Docker Compose (recommended)

## API Keys Required

1. **Alpha Vantage**: [Get API Key](https://www.alphavantage.co/support/#api-key)
2. **Google Gemini**: [Get API Key](https://makersuite.google.com/app/apikey)

## Quick Start

### Using Docker (Recommended)

1. **Clone and configure**
```bash
git clone https://github.com/mestrovicjozo/Portfolio-Intelligence-Dashboard.git
cd Portfolio-Intelligence-Dashboard
cd backend
cp .env.example .env
```

2. **Add your API keys to `backend/.env`**
```env
ALPHA_VANTAGE_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
```

3. **Start the application**
```bash
cd ..
docker-compose up -d
```

4. **Access the app**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/api/docs

### Manual Setup

See detailed setup instructions in the [documentation](docs/SETUP.md) (coming soon).

## Project Structure

```
Portfolio-Intelligence-Dashboard/
├── backend/
│   ├── app/
│   │   ├── api/routes/      # API endpoints
│   │   ├── models/          # Database models
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── services/        # Business logic
│   │   └── main.py
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/           # Page components
│   │   └── services/        # API client
│   └── package.json
├── docker-compose.yml
└── README.md
```

## Key Features

### Multi-Portfolio Support
- Create unlimited portfolios
- Switch between portfolios instantly
- Track separate strategies or accounts

### Position Tracking
- Add positions with shares and cost basis
- Real-time profit/loss calculations
- Day-over-day change tracking
- Top gainers/losers display

### Stock Actions
Click any stock to:
- View related news articles
- Get AI-generated insights
- Ask specific questions
- Analyze sentiment trends

### AI-Powered Analysis
- Semantic search across news articles
- Context-aware question answering
- Automatic sentiment scoring
- Stock-specific insights generation

## Documentation

Full documentation will be added after initial setup and testing.

## License

MIT License

## Built With

[Claude Code](https://claude.com/claude-code)

---

For detailed setup instructions, API documentation, and troubleshooting, please refer to the docs folder (coming soon).

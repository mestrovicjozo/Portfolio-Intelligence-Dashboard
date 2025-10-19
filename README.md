# Portfolio Intelligence Dashboard

An AI-powered portfolio tracking and analysis system that combines stock market data, news sentiment analysis, and natural language question-answering to help investors understand their portfolios.

## Features

- **Portfolio Management**: Track multiple stocks with real-time price data
- **News Aggregation**: Automatically fetch and organize relevant financial news
- **AI Sentiment Analysis**: Analyze news sentiment using Google Gemini
- **Natural Language Q&A**: Ask questions about your portfolio and get AI-generated insights
- **Semantic Search**: Find relevant news articles using vector similarity search
- **Interactive Dashboard**: Modern React UI for easy portfolio monitoring

## Tech Stack

### Backend
- **FastAPI**: Modern Python web framework
- **PostgreSQL**: Relational database for structured data
- **ChromaDB**: Vector database for news embeddings
- **Google Gemini Flash**: LLM for embeddings and sentiment analysis
- **Alpha Vantage API**: Stock prices and financial news data

### Frontend
- **React**: UI framework
- **Vite**: Build tool and dev server
- **TanStack Query**: Data fetching and caching
- **Lucide React**: Icon library
- **Recharts**: Data visualization

## Prerequisites

- Python 3.11+
- Node.js 18+
- PostgreSQL 14+
- Docker and Docker Compose (optional, for containerized setup)

## API Keys Required

You'll need to obtain the following API keys:

1. **Alpha Vantage API Key**: Get it from [Alpha Vantage](https://www.alphavantage.co/support/#api-key)
2. **Google Gemini API Key**: Get it from [Google AI Studio](https://makersuite.google.com/app/apikey)

## Setup Instructions

### Option 1: Docker Setup (Recommended)

1. **Clone the repository**
```bash
git clone https://github.com/mestrovicjozo/Portfolio-Intelligence-Dashboard.git
cd Portfolio-Intelligence-Dashboard
```

2. **Configure environment variables**
```bash
cd backend
cp .env.example .env
```

Edit `backend/.env` and add your API keys:
```env
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key_here
GEMINI_API_KEY=your_gemini_api_key_here
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/portfolio_intelligence
CHROMA_PERSIST_DIR=/app/data/chroma
```

3. **Start the application**
```bash
cd ..
docker-compose up -d
```

4. **Access the application**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/api/docs

### Option 2: Manual Setup

#### Backend Setup

1. **Create and activate virtual environment**
```bash
cd backend
python -m venv venv

# On Windows
venv\Scripts\activate

# On macOS/Linux
source venv/bin/activate
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure environment variables**
```bash
cp .env.example .env
```

Edit `.env` with your API keys and database connection:
```env
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_key_here
GEMINI_API_KEY=your_gemini_api_key_here
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/portfolio_intelligence
CHROMA_PERSIST_DIR=../data/chroma
```

4. **Create PostgreSQL database**
```bash
# Using psql
createdb portfolio_intelligence

# Or using PostgreSQL client
CREATE DATABASE portfolio_intelligence;
```

5. **Run the backend**
```bash
python -m uvicorn backend.app.main:app --reload
```

The API will be available at http://localhost:8000

#### Frontend Setup

1. **Install dependencies**
```bash
cd frontend
npm install
```

2. **Start the development server**
```bash
npm run dev
```

The frontend will be available at http://localhost:3000

## Usage Guide

### 1. Add Stocks to Your Portfolio

1. Open the dashboard at http://localhost:3000
2. Click the "Add Stock" button
3. Enter a stock symbol (e.g., AAPL, MSFT, TSLA)
4. The system will automatically fetch company information

### 2. Refresh Stock Prices

- Click on a stock card to view details
- Use the refresh button to update prices from Alpha Vantage
- Price changes and percentages are calculated automatically

### 3. Fetch and Analyze News

1. Navigate to the News page
2. Click "Refresh News" to fetch the latest articles for your portfolio
3. The system will:
   - Fetch news from Alpha Vantage
   - Generate embeddings using Gemini
   - Analyze sentiment for each article
   - Store articles in both PostgreSQL and ChromaDB

### 4. Ask Questions

1. Navigate to the "Ask AI" page
2. Type a question like:
   - "Why are my stocks moving today?"
   - "What's the sentiment around my tech stocks?"
   - "Summarize recent news for AAPL"
3. The AI will:
   - Generate an embedding for your question
   - Search for relevant articles using semantic similarity
   - Generate a comprehensive answer using Gemini

## Project Structure

```
Portfolio-Intelligence-Dashboard/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/        # API endpoints
│   │   ├── core/              # Configuration
│   │   ├── db/                # Database setup
│   │   ├── models/            # SQLAlchemy models
│   │   ├── schemas/           # Pydantic schemas
│   │   ├── services/          # Business logic
│   │   └── main.py            # FastAPI application
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── pages/             # Page components
│   │   ├── services/          # API client
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── package.json
│   └── Dockerfile
├── data/
│   ├── chroma/                # ChromaDB storage
│   └── postgres/              # PostgreSQL data
├── docker-compose.yml
└── README.md
```

## API Endpoints

### Stocks
- `GET /api/stocks` - List all stocks in portfolio
- `POST /api/stocks` - Add a stock to portfolio
- `GET /api/stocks/{symbol}` - Get stock details
- `DELETE /api/stocks/{symbol}` - Remove stock from portfolio
- `POST /api/stocks/{symbol}/refresh` - Refresh stock price data

### News
- `GET /api/news` - List news articles
- `POST /api/news/refresh` - Fetch latest news
- `GET /api/news/{article_id}` - Get article details
- `POST /api/news/{article_id}/analyze-sentiment` - Re-analyze sentiment

### Query
- `POST /api/query/ask` - Ask a question (RAG-powered)
- `GET /api/query/portfolio-summary` - Get portfolio summary
- `GET /api/query/sentiment-analysis/{symbol}` - Get sentiment trends

## Database Schema

### PostgreSQL Tables

**stocks**
- id, symbol, name, sector, added_at

**stock_prices**
- id, stock_id, date, open, close, high, low, volume

**news_articles**
- id, title, source, url, published_at, summary, sentiment_score, created_at

**article_stocks** (many-to-many)
- id, article_id, stock_id

### ChromaDB Collection

**news_embeddings**
- Document: Article title + summary
- Embedding: Gemini-generated vector (768 dimensions)
- Metadata: title, source, published_at, sentiment_score, stocks

## Architecture

### RAG (Retrieval-Augmented Generation) System

1. **Ingestion**: News articles are embedded using Gemini and stored in ChromaDB
2. **Retrieval**: User questions are embedded and similar articles are found via vector search
3. **Generation**: Relevant articles are provided as context to Gemini for answer generation

### Sentiment Analysis

- Gemini analyzes each article's text
- Returns a score from -1.0 (negative) to 1.0 (positive)
- Scores are stored in PostgreSQL for trend analysis

## Development

### Running Tests
```bash
cd backend
pytest

cd frontend
npm test
```

### Database Migrations

```bash
cd backend
alembic revision --autogenerate -m "Description"
alembic upgrade head
```

### Building for Production

```bash
# Backend
cd backend
docker build -t portfolio-backend .

# Frontend
cd frontend
npm run build
```

## Environment Variables

### Backend (.env)

| Variable | Description | Required |
|----------|-------------|----------|
| ALPHA_VANTAGE_API_KEY | Alpha Vantage API key | Yes |
| GEMINI_API_KEY | Google Gemini API key | Yes |
| DATABASE_URL | PostgreSQL connection string | Yes |
| CHROMA_PERSIST_DIR | ChromaDB storage path | Yes |
| APP_ENV | development/production | No |
| DEBUG | Enable debug mode | No |
| LOG_LEVEL | Logging level (INFO/DEBUG/ERROR) | No |
| ALLOWED_ORIGINS | CORS allowed origins | No |

### Frontend (.env)

| Variable | Description | Required |
|----------|-------------|----------|
| VITE_API_URL | Backend API URL | No (defaults to http://localhost:8000/api) |

## Troubleshooting

### Alpha Vantage API Limits
- Free tier: 25 requests/day
- If you hit the limit, wait 24 hours or upgrade to a paid plan
- The app caches data to minimize API calls

### Gemini API Errors
- Ensure your API key is valid
- Check you haven't exceeded quota
- Gemini Flash has higher rate limits than Gemini Pro

### Database Connection Issues
- Verify PostgreSQL is running: `pg_isready`
- Check DATABASE_URL is correct
- Ensure database exists: `createdb portfolio_intelligence`

### ChromaDB Issues
- Ensure the CHROMA_PERSIST_DIR path exists and is writable
- Clear ChromaDB: Delete the `data/chroma` directory

## Future Enhancements

- [ ] User authentication and multi-user support
- [ ] Portfolio position tracking (shares owned, cost basis)
- [ ] Real-time price updates via WebSocket
- [ ] Advanced charting and technical indicators
- [ ] Email/SMS alerts for price movements
- [ ] PDF report generation
- [ ] Integration with brokerage APIs
- [ ] Mobile app

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Acknowledgments

- [Alpha Vantage](https://www.alphavantage.co/) for financial data API
- [Google Gemini](https://deepmind.google/technologies/gemini/) for AI capabilities
- [ChromaDB](https://www.trychroma.com/) for vector database
- [FastAPI](https://fastapi.tiangolo.com/) for the backend framework
- [React](https://react.dev/) for the frontend framework

## Support

For issues, questions, or contributions, please open an issue on GitHub.

---

Built with Claude Code

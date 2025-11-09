from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Dict, Any
from datetime import datetime, timedelta

from backend.app.db.base import get_db
from backend.app.models import NewsArticle, Stock, ArticleStock, StockPrice
from backend.app.schemas.query import QueryRequest, QueryResponse, PortfolioSummary
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService

router = APIRouter()
gemini_service = GeminiService()
vector_store = VectorStoreService()


@router.post("/ask", response_model=QueryResponse)
def ask_question(query: QueryRequest, db: Session = Depends(get_db)):
    """
    Answer a natural language question about the portfolio using RAG.

    The system will:
    1. Generate an embedding for the question
    2. Search for relevant articles in the vector store
    3. Retrieve full article details from PostgreSQL
    4. Use Gemini to generate an answer based on the context
    """
    try:
        # Check if question is finance-related first
        if not gemini_service.is_finance_related(query.question):
            return QueryResponse(
                answer="I'm sorry, but I can only answer questions related to finance, stocks, investing, and your portfolio. Please ask a question about financial markets, companies, or your investments.",
                sources=[]
            )

        # Generate query embedding
        query_embedding = gemini_service.generate_query_embedding(query.question)

        # Search vector store for relevant articles
        similar_articles = vector_store.search_similar(
            query_embedding=query_embedding,
            n_results=query.context_limit
        )

        if not similar_articles:
            return QueryResponse(
                answer="I don't have enough information to answer that question. Try refreshing the news data or adding more stocks to your portfolio.",
                sources=[]
            )

        # Retrieve full article details from database
        article_ids = [article['article_id'] for article in similar_articles]
        articles = db.query(NewsArticle).filter(NewsArticle.id.in_(article_ids)).all()

        # Build context for Gemini
        context = []
        for article in articles:
            stock_symbols = [as_.stock.symbol for as_ in article.stocks]
            context.append({
                "title": article.title,
                "source": article.source,
                "published_at": str(article.published_at) if article.published_at else None,
                "summary": article.summary,
                "sentiment_score": article.sentiment_score,
                "stocks": stock_symbols,
                "url": article.url
            })

        # Generate answer using Gemini (with context)
        answer = gemini_service.answer_question(
            question=query.question,
            context=context
        )

        # Format sources for response
        sources = [{
            "id": article["id"] if isinstance(article, dict) and "id" in article else idx,
            "title": ctx["title"],
            "source": ctx["source"],
            "url": ctx["url"],
            "published_at": ctx["published_at"],
            "stocks": ctx["stocks"]
        } for idx, ctx in enumerate(context)]

        return QueryResponse(
            answer=answer,
            sources=sources,
            confidence=0.85  # Could be calculated based on similarity scores
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing query: {str(e)}"
        )


@router.get("/portfolio-summary", response_model=PortfolioSummary)
def get_portfolio_summary(db: Session = Depends(get_db)):
    """Get a comprehensive summary of the portfolio."""
    stocks = db.query(Stock).all()

    if not stocks:
        return PortfolioSummary(
            total_stocks=0,
            top_gainers=[],
            top_losers=[]
        )

    # Calculate portfolio metrics
    stock_performances = []

    for stock in stocks:
        # Get latest two prices
        latest_prices = db.query(StockPrice).filter(
            StockPrice.stock_id == stock.id
        ).order_by(StockPrice.date.desc()).limit(2).all()

        if len(latest_prices) >= 2:
            current = latest_prices[0]
            previous = latest_prices[1]

            change = current.close - previous.close
            change_percent = (change / previous.close) * 100

            stock_performances.append({
                "symbol": stock.symbol,
                "name": stock.name,
                "price": current.close,
                "change": round(change, 2),
                "change_percent": round(change_percent, 2)
            })

    # Sort by performance
    stock_performances.sort(key=lambda x: x["change_percent"], reverse=True)

    top_gainers = stock_performances[:5]
    top_losers = stock_performances[-5:][::-1]  # Reverse to show worst first

    # Calculate average sentiment
    avg_sentiment = db.query(func.avg(NewsArticle.sentiment_score)).join(
        ArticleStock
    ).filter(
        ArticleStock.stock_id.in_([s.id for s in stocks])
    ).scalar()

    # Calculate total portfolio value and change (placeholder - would need position sizes)
    total_value = sum(sp["price"] for sp in stock_performances) if stock_performances else None
    total_change = sum(sp["change"] for sp in stock_performances) if stock_performances else None

    return PortfolioSummary(
        total_stocks=len(stocks),
        total_value=round(total_value, 2) if total_value else None,
        total_change=round(total_change, 2) if total_change else None,
        total_change_percent=round((total_change / (total_value - total_change)) * 100, 2) if total_value and total_change else None,
        sentiment_average=round(avg_sentiment, 3) if avg_sentiment else None,
        top_gainers=top_gainers,
        top_losers=top_losers
    )


@router.get("/sentiment-analysis/{symbol}", response_model=dict)
def get_stock_sentiment(symbol: str, days: int = 7, db: Session = Depends(get_db)):
    """Get sentiment analysis for a specific stock over time."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()

    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Get articles from the last N days
    cutoff_date = datetime.now() - timedelta(days=days)

    articles = db.query(NewsArticle).join(ArticleStock).filter(
        ArticleStock.stock_id == stock.id,
        NewsArticle.published_at >= cutoff_date
    ).order_by(NewsArticle.published_at.desc()).all()

    if not articles:
        return {
            "symbol": symbol,
            "period_days": days,
            "article_count": 0,
            "average_sentiment": None,
            "sentiment_trend": []
        }

    # Calculate average sentiment
    sentiments = [a.sentiment_score for a in articles if a.sentiment_score is not None]
    avg_sentiment = sum(sentiments) / len(sentiments) if sentiments else None

    # Group by date for trend
    sentiment_by_date = {}
    for article in articles:
        if article.published_at and article.sentiment_score is not None:
            date_key = article.published_at.date()
            if date_key not in sentiment_by_date:
                sentiment_by_date[date_key] = []
            sentiment_by_date[date_key].append(article.sentiment_score)

    sentiment_trend = [
        {
            "date": str(date),
            "average_sentiment": round(sum(scores) / len(scores), 3),
            "article_count": len(scores)
        }
        for date, scores in sorted(sentiment_by_date.items())
    ]

    return {
        "symbol": symbol,
        "period_days": days,
        "article_count": len(articles),
        "average_sentiment": round(avg_sentiment, 3) if avg_sentiment else None,
        "sentiment_trend": sentiment_trend
    }

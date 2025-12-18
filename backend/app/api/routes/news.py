from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
import asyncio

from backend.app.db.base import get_db
from backend.app.models import NewsArticle, Stock, ArticleStock
from backend.app.schemas.news_article import NewsArticle as NewsArticleSchema, NewsArticleWithStocks
from backend.app.services.news_collector import NewsCollectorService
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService

router = APIRouter()
news_collector = NewsCollectorService()
gemini_service = GeminiService()
vector_store = VectorStoreService()


@router.get("/", response_model=List[NewsArticleWithStocks])
def list_news(
    limit: int = 50,
    stock_symbol: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get news articles, optionally filtered by stock symbol."""
    query = db.query(NewsArticle)

    if stock_symbol:
        # Filter by stock symbol
        stock = db.query(Stock).filter(Stock.symbol == stock_symbol.upper()).first()
        if stock:
            query = query.join(ArticleStock).filter(ArticleStock.stock_id == stock.id)

    articles = query.order_by(NewsArticle.published_at.desc()).limit(limit).all()

    # Add stock symbols to each article
    result = []
    for article in articles:
        article_dict = NewsArticleSchema.from_orm(article).dict()
        article_dict["stock_symbols"] = [
            as_.stock.symbol for as_ in article.stocks
        ]
        result.append(NewsArticleWithStocks(**article_dict))

    return result


@router.post("/refresh", response_model=dict)
async def refresh_news(background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """Fetch ALL news from ActuallyFreeAPI and associate with portfolio stocks."""
    stocks = db.query(Stock).all()

    if not stocks:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No stocks in portfolio. Add stocks first."
        )

    # Create a set of portfolio tickers for quick lookup
    portfolio_tickers = {stock.symbol.upper() for stock in stocks}
    stock_map = {stock.symbol.upper(): stock for stock in stocks}

    try:
        new_count = 0
        updated_count = 0
        skipped_count = 0

        # Fetch recent articles from ActuallyFreeAPI from last 30 days
        start_date = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
        articles = await news_collector.fetch_from_actually_free_api(
            ticker=None,  # Get all articles
            limit=100,  # Max per page
            start_date=start_date  # Only get articles from last 30 days
        )

        for item in articles:
            try:
                # Extract tickers from article (handle None case)
                article_tickers = item.get("tickers") or []

                # Find which tickers are in our portfolio
                relevant_tickers = []
                if article_tickers:
                    relevant_tickers = [t.upper() for t in article_tickers if t.upper() in portfolio_tickers]

                # If no tickers specified, check if title/summary mentions our stocks
                if not relevant_tickers:
                    title = item.get("title", "").upper()
                    summary = item.get("summary", "").upper()

                    # Check if any of our stock symbols appear in title or summary
                    for ticker in portfolio_tickers:
                        if ticker in title or ticker in summary:
                            relevant_tickers.append(ticker)
                            break

                # Skip only if no relevance found
                if not relevant_tickers:
                    skipped_count += 1
                    continue

                # Check if article already exists by URL
                existing = db.query(NewsArticle).filter(
                    NewsArticle.url == item.get("url")
                ).first()

                if existing:
                    continue

                # Use Gemini to analyze sentiment from title and summary
                sentiment_score = 0.0  # Default neutral
                title = item.get("title", "")
                summary = item.get("summary", "")

                if title:
                    try:
                        # Analyze sentiment using Gemini
                        content = f"{title}. {summary}" if summary else title
                        sentiment_result = gemini_service.analyze_sentiment(content)
                        sentiment_score = sentiment_result["score"]
                    except Exception as e:
                        print(f"Error analyzing sentiment: {e}")
                        sentiment_score = 0.0

                # Create new article
                article = NewsArticle(
                    title=title,
                    source=item.get("source", "Unknown"),
                    url=item.get("url"),
                    published_at=item.get("published_at") or datetime.now(),
                    summary=item.get("summary", title),
                    sentiment_score=sentiment_score
                )
                db.add(article)
                db.flush()

                # Link article to all relevant stocks in portfolio
                for ticker in relevant_tickers:
                    stock = stock_map[ticker]
                    article_stock = ArticleStock(
                        article_id=article.id,
                        stock_id=stock.id
                    )
                    db.add(article_stock)

                # Add to vector store for semantic search
                try:
                    embedding = gemini_service.generate_embedding(title)
                    vector_store.add_article(
                        article_id=article.id,
                        content=title,
                        embedding=embedding,
                        metadata={
                            "title": title,
                            "source": item.get("source", "Unknown"),
                            "published_at": str(article.published_at),
                            "sentiment_score": sentiment_score,
                            "stocks": relevant_tickers
                        }
                    )
                except Exception as e:
                    print(f"Error adding to vector store: {e}")

                new_count += 1

            except Exception as e:
                print(f"Error processing article: {e}")
                continue

        db.commit()

        return {
            "message": "News refresh completed",
            "total_fetched": len(articles),
            "new_articles": new_count,
            "updated_articles": updated_count,
            "skipped": skipped_count
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error refreshing news: {str(e)}"
        )


@router.get("/{article_id}", response_model=NewsArticleWithStocks)
def get_article(article_id: int, db: Session = Depends(get_db)):
    """Get a specific news article by ID."""
    article = db.query(NewsArticle).filter(NewsArticle.id == article_id).first()

    if not article:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Article {article_id} not found"
        )

    article_dict = NewsArticleSchema.from_orm(article).dict()
    article_dict["stock_symbols"] = [as_.stock.symbol for as_ in article.stocks]

    return NewsArticleWithStocks(**article_dict)


@router.post("/{article_id}/analyze-sentiment", response_model=dict)
def analyze_article_sentiment(article_id: int, db: Session = Depends(get_db)):
    """Re-analyze sentiment for a specific article using Gemini."""
    article = db.query(NewsArticle).filter(NewsArticle.id == article_id).first()

    if not article:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Article {article_id} not found"
        )

    try:
        content = f"{article.title}. {article.summary or ''}"
        sentiment = gemini_service.analyze_sentiment(content)

        # Update article sentiment
        article.sentiment_score = sentiment["score"]
        db.commit()

        return {
            "article_id": article_id,
            "sentiment": sentiment
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error analyzing sentiment: {str(e)}"
        )

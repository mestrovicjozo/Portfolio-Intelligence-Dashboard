from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta

from backend.app.db.base import get_db
from backend.app.models import NewsArticle, Stock, ArticleStock
from backend.app.schemas.news_article import NewsArticle as NewsArticleSchema, NewsArticleWithStocks
from backend.app.services.alpha_vantage import AlphaVantageService
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService

router = APIRouter()
av_service = AlphaVantageService()
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
    """Fetch and process latest news for all stocks in portfolio."""
    stocks = db.query(Stock).all()

    if not stocks:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No stocks in portfolio. Add stocks first."
        )

    # Fetch news for all stocks
    ticker_list = ",".join([stock.symbol for stock in stocks])

    try:
        # Get news from Alpha Vantage
        news_items = av_service.get_news_sentiment(tickers=ticker_list, limit=50)

        new_count = 0
        updated_count = 0

        for item in news_items:
            # Check if article already exists
            existing = db.query(NewsArticle).filter(
                NewsArticle.url == item["url"]
            ).first()

            # Determine which stocks are related to this article
            related_stocks = []
            for stock in stocks:
                if stock.symbol in item.get("ticker_sentiment", {}):
                    related_stocks.append(stock)

            if not related_stocks:
                continue

            # Create or update article
            if existing:
                # Update sentiment if changed
                if existing.sentiment_score != item["overall_sentiment_score"]:
                    existing.sentiment_score = item["overall_sentiment_score"]
                    updated_count += 1
            else:
                # Create new article
                article = NewsArticle(
                    title=item["title"],
                    source=item["source"],
                    url=item["url"],
                    published_at=item["published_at"],
                    summary=item["summary"],
                    sentiment_score=item["overall_sentiment_score"]
                )
                db.add(article)
                db.flush()  # Get article ID

                # Link to stocks
                for stock in related_stocks:
                    article_stock = ArticleStock(
                        article_id=article.id,
                        stock_id=stock.id
                    )
                    db.add(article_stock)

                # Generate embedding and add to vector store in background
                content = f"{item['title']}. {item['summary']}"
                try:
                    embedding = gemini_service.generate_embedding(content)
                    vector_store.add_article(
                        article_id=article.id,
                        content=content,
                        embedding=embedding,
                        metadata={
                            "title": item["title"],
                            "source": item["source"],
                            "published_at": str(item["published_at"]),
                            "sentiment_score": item["overall_sentiment_score"],
                            "stocks": [s.symbol for s in related_stocks]
                        }
                    )
                except Exception as e:
                    print(f"Error adding to vector store: {e}")

                new_count += 1

        db.commit()

        return {
            "message": "News refresh completed",
            "new_articles": new_count,
            "updated_articles": updated_count
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

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import asyncio
import uuid
import threading

from backend.app.db.base import get_db, SessionLocal
from backend.app.models import NewsArticle, Stock, ArticleStock
from backend.app.schemas.news_article import NewsArticle as NewsArticleSchema, NewsArticleWithStocks
from backend.app.services.news_collector import NewsCollectorService
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService

router = APIRouter()
news_collector = NewsCollectorService()
gemini_service = GeminiService()
vector_store = VectorStoreService()

# In-memory job status store (for simplicity; use Redis in production)
_refresh_jobs: Dict[str, Dict[str, Any]] = {}


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


async def _do_refresh_news(job_id: str, portfolio_tickers: set, stock_ids: Dict[str, int]):
    """Background task to refresh news articles."""
    print(f"[NEWS REFRESH] Starting job {job_id} with tickers: {portfolio_tickers}")
    db = SessionLocal()

    try:
        _refresh_jobs[job_id]["status"] = "running"
        _refresh_jobs[job_id]["message"] = "Fetching articles..."

        new_count = 0
        updated_count = 0
        skipped_count = 0
        already_exists_count = 0

        # Fetch recent articles from ActuallyFreeAPI from last 30 days
        start_date = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
        print(f"[NEWS REFRESH] Fetching articles since {start_date}...")

        articles = await news_collector.fetch_from_actually_free_api(
            ticker=None,  # Get all articles
            limit=100,  # Max per page
            start_date=start_date  # Only get articles from last 30 days
        )

        print(f"[NEWS REFRESH] Fetched {len(articles)} articles from API")

        total_articles = len(articles)
        _refresh_jobs[job_id]["total_fetched"] = total_articles
        _refresh_jobs[job_id]["message"] = f"Processing {total_articles} articles..."

        for i, item in enumerate(articles):
            try:
                # Update progress
                _refresh_jobs[job_id]["progress"] = int((i / max(total_articles, 1)) * 100)
                _refresh_jobs[job_id]["processed"] = i

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
                    already_exists_count += 1
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
                    stock = db.query(Stock).filter(Stock.symbol == ticker).first()
                    if stock:
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
                _refresh_jobs[job_id]["new_articles"] = new_count

            except Exception as e:
                print(f"Error processing article: {e}")
                continue

        db.commit()

        print(f"[NEWS REFRESH] Completed - New: {new_count}, Already exists: {already_exists_count}, Skipped (not relevant): {skipped_count}")

        _refresh_jobs[job_id]["status"] = "completed"
        _refresh_jobs[job_id]["progress"] = 100
        _refresh_jobs[job_id]["processed"] = total_articles
        _refresh_jobs[job_id]["new_articles"] = new_count
        _refresh_jobs[job_id]["updated_articles"] = updated_count
        _refresh_jobs[job_id]["skipped"] = skipped_count
        _refresh_jobs[job_id]["already_exists"] = already_exists_count
        _refresh_jobs[job_id]["message"] = f"Found {new_count} new articles ({already_exists_count} already in database)"
        _refresh_jobs[job_id]["completed_at"] = datetime.now().isoformat()

    except Exception as e:
        import traceback
        print(f"[NEWS REFRESH] ERROR: {str(e)}")
        print(traceback.format_exc())
        _refresh_jobs[job_id]["status"] = "failed"
        _refresh_jobs[job_id]["message"] = f"Error: {str(e)}"
        _refresh_jobs[job_id]["error"] = str(e)
        db.rollback()
    finally:
        db.close()


def _run_async_refresh(job_id: str, portfolio_tickers: set, stock_ids: Dict[str, int]):
    """Run the async refresh in a new event loop (for threading)."""
    print(f"[NEWS REFRESH] Thread started for job {job_id}")
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        loop.run_until_complete(_do_refresh_news(job_id, portfolio_tickers, stock_ids))
    except Exception as e:
        import traceback
        print(f"[NEWS REFRESH] Thread error: {str(e)}")
        print(traceback.format_exc())
        _refresh_jobs[job_id]["status"] = "failed"
        _refresh_jobs[job_id]["message"] = f"Error: {str(e)}"
        _refresh_jobs[job_id]["error"] = str(e)
    finally:
        loop.close()
        print(f"[NEWS REFRESH] Thread finished for job {job_id}")


@router.post("/refresh", response_model=dict)
async def refresh_news(background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """Start a background job to fetch news from ActuallyFreeAPI.

    Returns immediately with a job_id that can be used to poll for status.
    """
    stocks = db.query(Stock).all()

    if not stocks:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No stocks in portfolio. Add stocks first."
        )

    # Create a set of portfolio tickers for quick lookup
    portfolio_tickers = {stock.symbol.upper() for stock in stocks}
    stock_ids = {stock.symbol.upper(): stock.id for stock in stocks}

    # Generate a unique job ID
    job_id = str(uuid.uuid4())

    # Initialize job status
    _refresh_jobs[job_id] = {
        "job_id": job_id,
        "status": "pending",
        "progress": 0,
        "processed": 0,
        "total_fetched": 0,
        "new_articles": 0,
        "updated_articles": 0,
        "skipped": 0,
        "message": "Starting news refresh...",
        "started_at": datetime.now().isoformat(),
        "completed_at": None,
        "error": None
    }

    # Start background task in a separate thread to avoid blocking
    thread = threading.Thread(
        target=_run_async_refresh,
        args=(job_id, portfolio_tickers, stock_ids)
    )
    thread.start()

    return {
        "job_id": job_id,
        "status": "pending",
        "message": "News refresh job started. Poll /api/news/refresh/status/{job_id} for progress."
    }


@router.get("/refresh/status/{job_id}", response_model=dict)
def get_refresh_status(job_id: str):
    """Get the status of a news refresh job."""
    if job_id not in _refresh_jobs:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Job {job_id} not found"
        )

    job = _refresh_jobs[job_id]

    # Clean up completed jobs older than 10 minutes
    if job["status"] in ["completed", "failed"] and job.get("completed_at"):
        completed_at = datetime.fromisoformat(job["completed_at"])
        if datetime.now() - completed_at > timedelta(minutes=10):
            del _refresh_jobs[job_id]
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Job {job_id} expired"
            )

    return job


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

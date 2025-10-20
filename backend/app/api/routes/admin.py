"""
Admin routes for monitoring and managing the application.

Includes endpoints for:
- Scheduler status and job monitoring
- Data collection statistics
- System health checks
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import Dict, Any
from datetime import datetime, timedelta
import pytz

from backend.app.db.base import get_db
from backend.app.models import Stock, StockPrice, NewsArticle, Position, Portfolio
from backend.app.services.scheduler import scheduler_service
from backend.app.core.config import settings

router = APIRouter()


@router.get("/scheduler/status", response_model=Dict[str, Any])
def get_scheduler_status():
    """
    Get scheduler status and information about scheduled jobs.

    Returns:
        - is_running: Whether scheduler is active
        - timezone: Scheduler timezone
        - jobs: List of registered jobs with next run times
        - recent_history: Last 10 job executions
        - statistics: Success/failure counts
    """
    try:
        status = scheduler_service.get_status()
        return status
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting scheduler status: {str(e)}")


@router.get("/collection-stats", response_model=Dict[str, Any])
def get_collection_stats(db: Session = Depends(get_db)):
    """
    Get statistics about collected data.

    Returns:
        - Stock price statistics (count, date range, stocks tracked)
        - News article statistics (count, date range, sources)
        - Recent collection activity
        - Database size information
    """
    try:
        tz = pytz.timezone(settings.SCHEDULER_TIMEZONE)
        now = datetime.now(tz)

        # Stock price statistics
        total_prices = db.query(func.count(StockPrice.id)).scalar()

        price_date_range = db.query(
            func.min(StockPrice.date).label('min_date'),
            func.max(StockPrice.date).label('max_date')
        ).first()

        stocks_with_prices = db.query(func.count(func.distinct(StockPrice.stock_id))).scalar()
        total_stocks = db.query(func.count(Stock.id)).scalar()

        # Recent price data (last 7 days)
        seven_days_ago = (now - timedelta(days=7)).date()
        recent_prices = db.query(func.count(StockPrice.id)).filter(
            StockPrice.date >= seven_days_ago
        ).scalar()

        # News article statistics
        total_articles = db.query(func.count(NewsArticle.id)).scalar()

        article_date_range = db.query(
            func.min(NewsArticle.published_at).label('min_date'),
            func.max(NewsArticle.published_at).label('max_date')
        ).first()

        # Recent news (last 24 hours)
        yesterday = now - timedelta(days=1)
        recent_articles = db.query(func.count(NewsArticle.id)).filter(
            NewsArticle.published_at >= yesterday
        ).scalar()

        # News sources count
        sources = db.query(func.count(func.distinct(NewsArticle.source))).scalar()

        # Average sentiment
        avg_sentiment = db.query(func.avg(NewsArticle.sentiment_score)).filter(
            NewsArticle.sentiment_score.isnot(None)
        ).scalar()

        return {
            "timestamp": now.isoformat(),
            "stock_prices": {
                "total_records": total_prices,
                "date_range": {
                    "earliest": price_date_range.min_date.isoformat() if price_date_range.min_date else None,
                    "latest": price_date_range.max_date.isoformat() if price_date_range.max_date else None
                },
                "stocks_tracked": stocks_with_prices,
                "total_stocks": total_stocks,
                "recent_7_days": recent_prices
            },
            "news_articles": {
                "total_articles": total_articles,
                "date_range": {
                    "earliest": article_date_range.min_date.isoformat() if article_date_range.min_date else None,
                    "latest": article_date_range.max_date.isoformat() if article_date_range.max_date else None
                },
                "sources_count": sources,
                "recent_24_hours": recent_articles,
                "average_sentiment": float(avg_sentiment) if avg_sentiment else None
            },
            "data_quality": {
                "stocks_with_prices_percentage": round((stocks_with_prices / total_stocks * 100), 2) if total_stocks > 0 else 0,
                "avg_prices_per_stock": round(total_prices / stocks_with_prices, 2) if stocks_with_prices > 0 else 0
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting collection stats: {str(e)}")


@router.post("/scheduler/trigger/{job_id}")
def trigger_job_manually(job_id: str):
    """
    Manually trigger a scheduled job for testing.

    Available job IDs:
    - daily_price_collection
    - daily_news_collection
    - weekly_data_export
    - monthly_database_backup
    """
    try:
        job = scheduler_service.scheduler.get_job(job_id)
        if not job:
            raise HTTPException(status_code=404, detail=f"Job '{job_id}' not found")

        # Trigger job immediately
        job.modify(next_run_time=datetime.now(pytz.timezone(settings.SCHEDULER_TIMEZONE)))

        return {
            "message": f"Job '{job_id}' triggered successfully",
            "job_name": job.name,
            "next_run_time": job.next_run_time.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error triggering job: {str(e)}")


@router.post("/reset-data")
def reset_data(
    keep_stocks: bool = True,
    keep_portfolios: bool = False,
    db: Session = Depends(get_db)
):
    """
    Reset/delete collected data from the database.

    This endpoint is useful for fresh imports from Trading212 or cleaning test data.

    Args:
        keep_stocks: If True, keeps stock symbols but deletes prices and articles (default: True)
        keep_portfolios: If True, keeps portfolio structures but deletes positions (default: False)

    Returns:
        Summary of deleted records
    """
    try:
        deleted_counts = {
            "positions": 0,
            "stock_prices": 0,
            "news_articles": 0,
            "stocks": 0,
            "portfolios": 0
        }

        # Delete positions (this will cascade to delete position-related data)
        positions_deleted = db.query(Position).delete()
        deleted_counts["positions"] = positions_deleted

        # Delete stock prices
        prices_deleted = db.query(StockPrice).delete()
        deleted_counts["stock_prices"] = prices_deleted

        # Delete news articles
        articles_deleted = db.query(NewsArticle).delete()
        deleted_counts["news_articles"] = articles_deleted

        # Optionally delete stocks
        if not keep_stocks:
            stocks_deleted = db.query(Stock).delete()
            deleted_counts["stocks"] = stocks_deleted

        # Optionally delete portfolios
        if not keep_portfolios:
            portfolios_deleted = db.query(Portfolio).delete()
            deleted_counts["portfolios"] = portfolios_deleted

        db.commit()

        return {
            "success": True,
            "message": "Data reset completed successfully",
            "deleted_counts": deleted_counts,
            "settings": {
                "kept_stocks": keep_stocks,
                "kept_portfolios": keep_portfolios
            },
            "next_steps": [
                "Import fresh data from Trading212 CSV",
                "Trigger price collection: POST /admin/scheduler/trigger/daily_price_collection",
                "Trigger news collection: POST /admin/scheduler/trigger/daily_news_collection"
            ]
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error resetting data: {str(e)}")

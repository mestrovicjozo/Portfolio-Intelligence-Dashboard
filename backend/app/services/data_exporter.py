"""
Data export and backup service for ML/analytics use.

Features:
- Weekly CSV/JSON exports of stock prices and news
- Monthly PostgreSQL database dumps
- Automatic old file cleanup (configurable retention)
- ML-ready combined dataset format
"""

import os
import json
import csv
import subprocess
import logging
from typing import Dict, Any, List
from datetime import datetime, timedelta
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from backend.app.core.config import settings
from backend.app.models import Stock, StockPrice, NewsArticle, ArticleStock

logger = logging.getLogger(__name__)


class DataExporterService:
    """Service for exporting data to various formats."""

    def __init__(self):
        self.export_dir = Path(settings.EXPORT_DIR)
        self.backup_dir = Path(settings.BACKUP_DIR)

        # Ensure directories exist
        self.export_dir.mkdir(parents=True, exist_ok=True)
        self.backup_dir.mkdir(parents=True, exist_ok=True)

    def export_stock_prices_csv(self, db, timestamp_str: str) -> Dict[str, Any]:
        """
        Export all stock prices to CSV.

        Args:
            db: Database session
            timestamp_str: Timestamp string for filename

        Returns:
            Export result dictionary
        """
        filename = f"stock_prices_{timestamp_str}.csv"
        filepath = self.export_dir / filename

        try:
            # Query all prices with stock symbols
            prices = db.query(
                Stock.symbol,
                StockPrice.date,
                StockPrice.open,
                StockPrice.high,
                StockPrice.low,
                StockPrice.close,
                StockPrice.volume
            ).join(Stock).order_by(Stock.symbol, StockPrice.date).all()

            # Write to CSV
            with open(filepath, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['symbol', 'date', 'open', 'high', 'low', 'close', 'volume'])

                for price in prices:
                    writer.writerow([
                        price.symbol,
                        price.date.isoformat(),
                        price.open,
                        price.high,
                        price.low,
                        price.close,
                        price.volume
                    ])

            logger.info(f"Exported {len(prices)} price records to {filename}")
            return {
                "status": "success",
                "filename": filename,
                "records": len(prices),
                "size_bytes": os.path.getsize(filepath)
            }

        except Exception as e:
            logger.error(f"Error exporting stock prices to CSV: {e}")
            return {
                "status": "error",
                "error": str(e),
                "records": 0
            }

    def export_news_articles_csv(self, db, timestamp_str: str) -> Dict[str, Any]:
        """
        Export all news articles to CSV.

        Args:
            db: Database session
            timestamp_str: Timestamp string for filename

        Returns:
            Export result dictionary
        """
        filename = f"news_articles_{timestamp_str}.csv"
        filepath = self.export_dir / filename

        try:
            # Query all articles
            articles = db.query(NewsArticle).order_by(NewsArticle.published_at.desc()).all()

            # Write to CSV
            with open(filepath, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(['id', 'title', 'source', 'url', 'published_at', 'sentiment_score', 'summary', 'related_stocks'])

                for article in articles:
                    # Get related stock symbols
                    stock_symbols = [as_.stock.symbol for as_ in article.stocks]

                    writer.writerow([
                        article.id,
                        article.title,
                        article.source,
                        article.url,
                        article.published_at.isoformat() if article.published_at else '',
                        article.sentiment_score if article.sentiment_score is not None else '',
                        article.summary or '',
                        ','.join(stock_symbols)
                    ])

            logger.info(f"Exported {len(articles)} news articles to {filename}")
            return {
                "status": "success",
                "filename": filename,
                "records": len(articles),
                "size_bytes": os.path.getsize(filepath)
            }

        except Exception as e:
            logger.error(f"Error exporting news articles to CSV: {e}")
            return {
                "status": "error",
                "error": str(e),
                "records": 0
            }

    def export_combined_dataset_json(self, db, timestamp_str: str) -> Dict[str, Any]:
        """
        Export ML-ready combined dataset in JSON format.

        Includes:
        - Stock prices with technical indicators
        - News articles with sentiment
        - Stock-news associations

        Args:
            db: Database session
            timestamp_str: Timestamp string for filename

        Returns:
            Export result dictionary
        """
        filename = f"combined_dataset_{timestamp_str}.json"
        filepath = self.export_dir / filename

        try:
            dataset = {
                "metadata": {
                    "export_date": datetime.now().isoformat(),
                    "description": "Portfolio Intelligence ML Dataset",
                    "version": "1.0"
                },
                "stocks": [],
                "news_articles": []
            }

            # Export stocks with prices
            stocks = db.query(Stock).all()
            for stock in stocks:
                prices = db.query(StockPrice).filter(
                    StockPrice.stock_id == stock.id
                ).order_by(StockPrice.date.desc()).all()

                stock_data = {
                    "symbol": stock.symbol,
                    "name": stock.name,
                    "sector": stock.sector,
                    "industry": stock.industry,
                    "prices": [
                        {
                            "date": p.date.isoformat(),
                            "open": float(p.open),
                            "high": float(p.high),
                            "low": float(p.low),
                            "close": float(p.close),
                            "volume": int(p.volume)
                        } for p in prices
                    ]
                }
                dataset["stocks"].append(stock_data)

            # Export news articles
            articles = db.query(NewsArticle).order_by(NewsArticle.published_at.desc()).all()
            for article in articles:
                stock_symbols = [as_.stock.symbol for as_ in article.stocks]

                article_data = {
                    "id": article.id,
                    "title": article.title,
                    "source": article.source,
                    "url": article.url,
                    "published_at": article.published_at.isoformat() if article.published_at else None,
                    "summary": article.summary,
                    "sentiment_score": float(article.sentiment_score) if article.sentiment_score is not None else None,
                    "related_stocks": stock_symbols
                }
                dataset["news_articles"].append(article_data)

            dataset["metadata"]["total_stocks"] = len(stocks)
            dataset["metadata"]["total_articles"] = len(articles)
            dataset["metadata"]["total_price_records"] = sum(len(s["prices"]) for s in dataset["stocks"])

            # Write to JSON
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(dataset, f, indent=2)

            logger.info(f"Exported combined dataset to {filename}")
            return {
                "status": "success",
                "filename": filename,
                "stocks": len(stocks),
                "articles": len(articles),
                "size_bytes": os.path.getsize(filepath)
            }

        except Exception as e:
            logger.error(f"Error exporting combined dataset to JSON: {e}")
            return {
                "status": "error",
                "error": str(e),
                "stocks": 0,
                "articles": 0
            }

    def cleanup_old_exports(self, retention_days: int = None) -> Dict[str, Any]:
        """
        Remove export files older than retention period.

        Args:
            retention_days: Days to keep files (default from settings)

        Returns:
            Cleanup result dictionary
        """
        if retention_days is None:
            retention_days = settings.EXPORT_RETENTION_DAYS

        cutoff_date = datetime.now() - timedelta(days=retention_days)
        deleted_count = 0
        deleted_size = 0

        try:
            for file in self.export_dir.iterdir():
                if file.is_file():
                    file_mtime = datetime.fromtimestamp(file.stat().st_mtime)
                    if file_mtime < cutoff_date:
                        file_size = file.stat().st_size
                        file.unlink()
                        deleted_count += 1
                        deleted_size += file_size
                        logger.info(f"Deleted old export: {file.name}")

            logger.info(f"Cleanup: Deleted {deleted_count} files ({deleted_size} bytes)")
            return {
                "status": "success",
                "deleted_count": deleted_count,
                "deleted_size_bytes": deleted_size
            }

        except Exception as e:
            logger.error(f"Error cleaning up old exports: {e}")
            return {
                "status": "error",
                "error": str(e),
                "deleted_count": 0
            }


async def export_all_data() -> Dict[str, Any]:
    """
    Main function to export all data (weekly job).
    Called by the scheduler.

    Returns:
        Dictionary with export statistics
    """
    logger.info("=== Starting Data Export ===")

    # Create database session
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    db = Session()

    try:
        exporter = DataExporterService()
        timestamp_str = datetime.now().strftime("%Y-%m-%d")

        # Export stock prices to CSV
        logger.info("Exporting stock prices to CSV...")
        prices_result = exporter.export_stock_prices_csv(db, timestamp_str)

        # Export news articles to CSV
        logger.info("Exporting news articles to CSV...")
        news_result = exporter.export_news_articles_csv(db, timestamp_str)

        # Export combined dataset to JSON
        logger.info("Exporting combined dataset to JSON...")
        combined_result = exporter.export_combined_dataset_json(db, timestamp_str)

        # Cleanup old exports
        logger.info("Cleaning up old exports...")
        cleanup_result = exporter.cleanup_old_exports()

        result = {
            "status": "success",
            "timestamp": datetime.now().isoformat(),
            "exports": {
                "stock_prices": prices_result,
                "news_articles": news_result,
                "combined_dataset": combined_result
            },
            "cleanup": cleanup_result
        }

        logger.info("=== Data Export Complete ===")
        return result

    except Exception as e:
        logger.error(f"Fatal error in data export: {e}")
        return {
            "status": "error",
            "error": str(e)
        }
    finally:
        db.close()


async def backup_database() -> Dict[str, Any]:
    """
    Create PostgreSQL database backup (monthly job).
    Called by the scheduler.

    Returns:
        Dictionary with backup statistics
    """
    logger.info("=== Starting Database Backup ===")

    try:
        backup_dir = Path(settings.BACKUP_DIR)
        backup_dir.mkdir(parents=True, exist_ok=True)

        timestamp_str = datetime.now().strftime("%Y-%m")
        filename = f"portfolio_db_{timestamp_str}.sql"
        filepath = backup_dir / filename

        # Parse database URL
        db_url = settings.DATABASE_URL
        # Format: postgresql://user:password@host:port/database

        if db_url.startswith("postgresql://"):
            parts = db_url.replace("postgresql://", "").split("@")
            if len(parts) == 2:
                user_pass = parts[0].split(":")
                host_db = parts[1].split("/")

                user = user_pass[0]
                password = user_pass[1] if len(user_pass) > 1 else ""
                host_port = host_db[0].split(":")
                host = host_port[0]
                port = host_port[1] if len(host_port) > 1 else "5432"
                database = host_db[1]

                # Use pg_dump command
                env = os.environ.copy()
                if password:
                    env["PGPASSWORD"] = password

                cmd = [
                    "pg_dump",
                    "-h", host,
                    "-p", port,
                    "-U", user,
                    "-d", database,
                    "-f", str(filepath)
                ]

                logger.info(f"Running pg_dump to {filename}")
                result = subprocess.run(cmd, env=env, capture_output=True, text=True)

                if result.returncode == 0:
                    size = os.path.getsize(filepath)
                    logger.info(f"Database backup created: {filename} ({size} bytes)")
                    return {
                        "status": "success",
                        "filename": filename,
                        "size_bytes": size
                    }
                else:
                    logger.error(f"pg_dump failed: {result.stderr}")
                    return {
                        "status": "error",
                        "error": result.stderr
                    }

        logger.warning("Could not parse database URL for backup")
        return {
            "status": "skipped",
            "reason": "invalid_database_url"
        }

    except Exception as e:
        logger.error(f"Fatal error in database backup: {e}")
        return {
            "status": "error",
            "error": str(e)
        }

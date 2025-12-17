"""
Fetch news articles from Alpha Vantage API for portfolio stocks.

Usage:
    python fetch_alpha_vantage_news.py [--target-count 50]
"""

import sys
import os
import logging
from pathlib import Path
from typing import List, Dict, Any

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime

from backend.app.core.config import settings
from backend.app.models import Stock, NewsArticle, ArticleStock
from backend.app.services.alpha_vantage import AlphaVantageService
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Fetch news from Alpha Vantage")
    parser.add_argument("--target-count", type=int, default=50, help="Target number of articles")
    args = parser.parse_args()

    logger.info("=== Alpha Vantage News Collection ===")
    logger.info(f"Target: {args.target_count} articles")

    # Create database connection
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    db = Session()

    try:
        # Get all stocks
        stocks = db.query(Stock).all()

        if not stocks:
            logger.error("No stocks found in portfolio!")
            return

        tickers = [stock.symbol for stock in stocks]
        logger.info(f"Fetching news for {len(tickers)} stocks: {', '.join(tickers)}")

        # Initialize services
        alpha_vantage = AlphaVantageService()
        gemini_service = GeminiService()
        vector_store = VectorStoreService()

        # Fetch news for each stock individually to get better coverage
        all_articles = []
        articles_per_stock = max(3, args.target_count // len(stocks))

        for stock in stocks:
            logger.info(f"Fetching {articles_per_stock} articles for {stock.symbol}...")
            try:
                articles = alpha_vantage.get_news_sentiment(
                    tickers=stock.symbol,
                    limit=articles_per_stock
                )

                # Normalize format
                for article in articles:
                    # Extract ticker list from ticker_sentiment
                    ticker_sentiment = article.get("ticker_sentiment", {})
                    ticker_list = list(ticker_sentiment.keys()) if ticker_sentiment else []

                    all_articles.append({
                        "title": article.get("title"),
                        "url": article.get("url"),
                        "published_at": article.get("published_at"),
                        "source": article.get("source"),
                        "summary": article.get("summary"),
                        "tickers": ticker_list,
                        "sentiment_score": article.get("overall_sentiment_score"),
                    })

                logger.info(f"  Retrieved {len(articles)} articles for {stock.symbol}")

            except Exception as e:
                logger.error(f"Error fetching news for {stock.symbol}: {e}")
                continue

        logger.info(f"Total articles fetched: {len(all_articles)}")

        # Deduplicate by URL
        seen_urls = set()
        unique_articles = []
        for article in all_articles:
            url = article.get("url")
            if url and url not in seen_urls:
                seen_urls.add(url)
                unique_articles.append(article)

        logger.info(f"Unique articles after deduplication: {len(unique_articles)}")

        # Store articles in database
        new_count = 0
        updated_count = 0
        skipped_count = 0

        for idx, article_data in enumerate(unique_articles, 1):
            try:
                if idx % 10 == 0:
                    logger.info(f"Progress: {idx}/{len(unique_articles)} processed")

                # Check if article exists
                existing = db.query(NewsArticle).filter(
                    NewsArticle.url == article_data["url"]
                ).first()

                if existing:
                    skipped_count += 1
                    continue

                # Find related stocks
                related_stocks = []
                article_tickers = article_data.get("tickers") or []

                for stock in stocks:
                    if article_tickers and stock.symbol in article_tickers:
                        related_stocks.append(stock)

                if not related_stocks:
                    skipped_count += 1
                    continue

                # Use existing sentiment score or generate new one
                sentiment_score = article_data.get("sentiment_score")
                if sentiment_score is None:
                    try:
                        content = f"{article_data['title']}. {article_data['summary']}"
                        sentiment_result = gemini_service.analyze_sentiment(content)
                        sentiment_score = sentiment_result.get("score", 0.0)
                    except Exception as e:
                        logger.warning(f"Error generating sentiment: {e}")
                        sentiment_score = 0.0
                else:
                    sentiment_score = float(sentiment_score)

                # Parse published date
                published_at = article_data.get("published_at")
                if isinstance(published_at, str):
                    try:
                        # Alpha Vantage format: YYYYMMDDTHHMMSS
                        published_at = datetime.strptime(published_at, "%Y%m%dT%H%M%S")
                    except:
                        published_at = datetime.now()
                elif not published_at:
                    published_at = datetime.now()

                # Create article
                article = NewsArticle(
                    title=article_data["title"][:500],  # Limit to DB field size
                    source=article_data["source"][:100] if article_data.get("source") else "Alpha Vantage",
                    url=article_data["url"],
                    published_at=published_at,
                    summary=article_data["summary"][:1000] if article_data.get("summary") else "",
                    sentiment_score=sentiment_score
                )
                db.add(article)
                db.flush()

                # Link to stocks
                for stock in related_stocks:
                    article_stock = ArticleStock(
                        article_id=article.id,
                        stock_id=stock.id
                    )
                    db.add(article_stock)

                # Generate and store embedding
                try:
                    content = f"{article_data['title']}. {article_data.get('summary', '')}"
                    embedding = gemini_service.generate_embedding(content)

                    vector_store.add_article(
                        article_id=article.id,
                        content=content,
                        embedding=embedding,
                        metadata={
                            "title": article_data["title"],
                            "source": article_data.get("source", "Alpha Vantage"),
                            "published_at": str(published_at),
                            "sentiment_score": sentiment_score,
                            "stocks": [s.symbol for s in related_stocks]
                        }
                    )
                except Exception as e:
                    logger.warning(f"Error adding to vector store: {e}")

                new_count += 1

                # Commit in batches
                if new_count % 10 == 0:
                    db.commit()

            except Exception as e:
                logger.error(f"Error processing article '{article_data.get('title', 'Unknown')}': {e}")
                db.rollback()
                continue

        # Final commit
        db.commit()

        logger.info("=== Collection Complete ===")
        logger.info(f"New articles: {new_count}")
        logger.info(f"Skipped (existing/no tickers): {skipped_count}")
        logger.info(f"Total articles in DB: {db.query(NewsArticle).count()}")

    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    main()

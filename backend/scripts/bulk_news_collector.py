"""
Bulk News Collection Script for ActuallyFreeAPI

This script fetches 500+ relevant articles from ActuallyFreeAPI database
for portfolio stocks and stores them with sentiment analysis and vector embeddings
for RAG flow demonstration.

Usage:
    python bulk_news_collector.py [--target-count 500] [--max-pages 10]
"""

import asyncio
import aiohttp
import sys
import os
import logging
from datetime import datetime, timedelta
from typing import List, Dict, Any, Set
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.app.core.config import settings
from backend.app.models import Stock, NewsArticle, ArticleStock
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class BulkNewsCollector:
    """Collector for fetching large volumes of news articles."""

    def __init__(self):
        self.actually_free_api_base = "https://actually-free-api.vercel.app/api"
        self.gemini_service = GeminiService()
        self.vector_store = VectorStoreService()
        self.seen_urls: Set[str] = set()

    async def fetch_bulk_articles(
        self,
        tickers: List[str],
        target_count: int = 500,
        max_pages_per_ticker: int = 10,
        days_back: int = 30
    ) -> List[Dict[str, Any]]:
        """
        Fetch bulk articles from ActuallyFreeAPI.

        Args:
            tickers: List of stock tickers
            target_count: Target number of unique articles
            max_pages_per_ticker: Maximum pages to fetch per ticker
            days_back: How many days back to fetch

        Returns:
            List of normalized article dictionaries
        """
        all_articles = []
        start_date = (datetime.now() - timedelta(days=days_back)).strftime("%Y-%m-%d")

        logger.info(f"Target: {target_count} articles from {len(tickers)} tickers")
        logger.info(f"Fetching articles from {start_date} onwards")

        async with aiohttp.ClientSession() as session:
            # First, try fetching without ticker filter to get broader coverage
            logger.info("Fetching general market news (no ticker filter)...")
            articles = await self._fetch_pages(
                session=session,
                ticker=None,
                start_date=start_date,
                max_pages=max_pages_per_ticker,
                limit=100
            )
            all_articles.extend(articles)
            logger.info(f"General news: {len(articles)} articles fetched")

            # If we haven't reached target, fetch per ticker
            if len(all_articles) < target_count:
                for ticker in tickers:
                    if len(all_articles) >= target_count:
                        logger.info(f"Reached target count of {target_count}")
                        break

                    logger.info(f"Fetching news for {ticker}...")
                    articles = await self._fetch_pages(
                        session=session,
                        ticker=ticker,
                        start_date=start_date,
                        max_pages=max_pages_per_ticker,
                        limit=100
                    )
                    all_articles.extend(articles)
                    logger.info(f"{ticker}: {len(articles)} articles")

                    # Small delay between ticker requests
                    await asyncio.sleep(0.5)

        # Deduplicate by URL
        unique_articles = self._deduplicate_articles(all_articles)
        logger.info(f"Total unique articles: {len(unique_articles)}")

        return unique_articles

    async def _fetch_pages(
        self,
        session: aiohttp.ClientSession,
        ticker: str = None,
        start_date: str = None,
        max_pages: int = 10,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Fetch multiple pages for a ticker or general news."""
        articles = []

        for page in range(1, max_pages + 1):
            try:
                params = {
                    "limit": limit,
                    "page": page
                }

                if ticker:
                    params["ticker"] = ticker

                if start_date:
                    params["startDate"] = start_date

                url = f"{self.actually_free_api_base}/news"

                async with session.get(
                    url,
                    params=params,
                    timeout=aiohttp.ClientTimeout(total=30)
                ) as response:
                    if response.status != 200:
                        logger.warning(f"Page {page} returned status {response.status}")
                        break

                    data = await response.json()
                    page_articles = data.get("data", [])

                    if not page_articles:
                        logger.info(f"No more articles at page {page}")
                        break

                    # Normalize articles
                    for article in page_articles:
                        normalized = self._normalize_article(article)
                        if normalized:
                            articles.append(normalized)

                    # Check pagination
                    pagination = data.get("pagination", {})
                    has_next = pagination.get("hasNextPage", False)

                    if not has_next:
                        break

                    # Small delay between pages
                    await asyncio.sleep(0.3)

            except Exception as e:
                logger.error(f"Error fetching page {page}: {e}")
                break

        return articles

    def _normalize_article(self, article: Dict[str, Any]) -> Dict[str, Any]:
        """Normalize article format from ActuallyFreeAPI."""
        try:
            url = article.get("link")
            if not url or url in self.seen_urls:
                return None

            self.seen_urls.add(url)

            # Parse published date
            pub_date = article.get("pub_date")
            published_at = None
            if pub_date:
                try:
                    published_at = datetime.fromisoformat(pub_date.replace("Z", "+00:00"))
                except:
                    pass

            # Handle summary safely
            summary = article.get("description") or article.get("content") or article.get("title") or ""
            if summary and len(summary) > 500:
                summary = summary[:500]

            return {
                "title": article.get("title") or "No title",
                "url": url,
                "published_at": published_at or datetime.now(),
                "source": article.get("source") or "Unknown",
                "summary": summary,
                "tickers": article.get("tickers") or [],
                "raw_content": article.get("content")
            }
        except Exception as e:
            logger.warning(f"Error normalizing article: {e}")
            return None

    def _deduplicate_articles(self, articles: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Remove duplicate articles by URL."""
        seen = set()
        unique = []

        for article in articles:
            url = article.get("url")
            if url and url not in seen:
                seen.add(url)
                unique.append(article)

        return unique

    def process_sentiment(self, article: Dict[str, Any]) -> float:
        """Generate sentiment score using Gemini."""
        try:
            content = f"{article.get('title', '')}. {article.get('summary', '')}"
            if not content.strip():
                return 0.0

            sentiment_result = self.gemini_service.analyze_sentiment(content)
            return sentiment_result.get("score", 0.0)
        except Exception as e:
            logger.warning(f"Error generating sentiment: {e}")
            return 0.0

    def generate_embedding(self, content: str) -> List[float]:
        """Generate vector embedding using Gemini."""
        try:
            return self.gemini_service.generate_embedding(content)
        except Exception as e:
            logger.warning(f"Error generating embedding: {e}")
            return None


async def main():
    """Main execution function."""
    import argparse

    parser = argparse.ArgumentParser(description="Bulk collect news articles for RAG")
    parser.add_argument("--target-count", type=int, default=500, help="Target number of articles")
    parser.add_argument("--max-pages", type=int, default=10, help="Max pages per ticker")
    parser.add_argument("--days-back", type=int, default=30, help="Days to look back")
    args = parser.parse_args()

    logger.info("=== Bulk News Collection Started ===")
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
            logger.info("Please add stocks to your portfolio first.")
            return

        tickers = [stock.symbol for stock in stocks]
        logger.info(f"Portfolio stocks: {', '.join(tickers)}")

        # Initialize collector
        collector = BulkNewsCollector()

        # Fetch articles
        articles = await collector.fetch_bulk_articles(
            tickers=tickers,
            target_count=args.target_count,
            max_pages_per_ticker=args.max_pages,
            days_back=args.days_back
        )

        logger.info(f"Fetched {len(articles)} unique articles")

        if len(articles) < args.target_count:
            logger.warning(f"Only fetched {len(articles)} articles (target was {args.target_count})")

        # Process and store articles
        new_count = 0
        updated_count = 0
        error_count = 0
        skipped_count = 0

        logger.info("Processing articles...")

        for idx, article_data in enumerate(articles, 1):
            try:
                if idx % 50 == 0:
                    logger.info(f"Progress: {idx}/{len(articles)} articles processed")

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

                # Only associate articles that have explicit ticker matches
                for stock in stocks:
                    if article_tickers and stock.symbol in article_tickers:
                        related_stocks.append(stock)

                # Skip articles with no related stocks
                if not related_stocks:
                    skipped_count += 1
                    continue

                # Generate sentiment
                sentiment_score = collector.process_sentiment(article_data)

                # Create article
                article = NewsArticle(
                    title=article_data["title"],
                    source=article_data["source"],
                    url=article_data["url"],
                    published_at=article_data["published_at"] or datetime.now(),
                    summary=article_data["summary"],
                    sentiment_score=sentiment_score
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

                # Generate and store embedding
                try:
                    content = f"{article_data['title']}. {article_data['summary']}"
                    embedding = collector.generate_embedding(content)

                    if embedding:
                        collector.vector_store.add_article(
                            article_id=article.id,
                            content=content,
                            embedding=embedding,
                            metadata={
                                "title": article_data["title"],
                                "source": article_data["source"],
                                "published_at": str(article_data["published_at"]),
                                "sentiment_score": sentiment_score,
                                "stocks": [s.symbol for s in related_stocks]
                            }
                        )
                except Exception as e:
                    logger.warning(f"Error adding to vector store: {e}")

                new_count += 1

                # Commit in batches
                if new_count % 50 == 0:
                    db.commit()
                    logger.info(f"Committed {new_count} articles so far...")

            except Exception as e:
                logger.error(f"Error processing article '{article_data.get('title', 'Unknown')}': {e}")
                error_count += 1
                db.rollback()
                continue

        # Final commit
        db.commit()

        # Summary
        logger.info("=== Bulk Collection Complete ===")
        logger.info(f"New articles added: {new_count}")
        logger.info(f"Skipped (existing/no tickers): {skipped_count}")
        logger.info(f"Errors: {error_count}")
        logger.info(f"Total articles in DB: {db.query(NewsArticle).count()}")

        if new_count >= args.target_count * 0.8:  # 80% of target
            logger.info(f"✓ Successfully collected {new_count} articles for RAG flow!")
        else:
            logger.warning(f"Only collected {new_count} articles (target was {args.target_count})")

    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        db.rollback()
    finally:
        db.close()
        logger.info("Database connection closed")


if __name__ == "__main__":
    asyncio.run(main())

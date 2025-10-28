"""
News collection service for automated daily news gathering.

Fetches news from multiple sources:
1. ActuallyFreeAPI (primary - free, no rate limits)
2. Alpha Vantage News Sentiment (secondary - for additional coverage)

Features:
- Automatic deduplication by URL
- Ticker extraction and association
- Sentiment analysis using Gemini
- Vector embeddings for semantic search
- Handles pagination for comprehensive coverage
"""

import asyncio
import aiohttp
import requests
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from backend.app.core.config import settings
from backend.app.models import Stock, NewsArticle, ArticleStock
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService
from backend.app.services.alpha_vantage import AlphaVantageService

logger = logging.getLogger(__name__)


class NewsCollectorService:
    """Service for collecting news from multiple sources."""

    def __init__(self):
        self.actually_free_api_base = "https://actually-free-api.vercel.app/api"
        self.gemini_service = GeminiService()
        self.vector_store = VectorStoreService()
        self.alpha_vantage = AlphaVantageService()

    async def fetch_from_actually_free_api(
        self,
        ticker: Optional[str] = None,
        limit: int = 50,
        start_date: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Fetch news from ActuallyFreeAPI.

        Args:
            ticker: Stock ticker to filter by
            limit: Number of articles to fetch per page
            start_date: ISO 8601 date string for filtering

        Returns:
            List of news articles
        """
        all_articles = []

        try:
            params = {
                "limit": min(limit, 100),  # Max 100 per request
                "page": 1
            }

            if ticker:
                params["ticker"] = ticker

            if start_date:
                params["startDate"] = start_date

            async with aiohttp.ClientSession() as session:
                # Fetch first page
                url = f"{self.actually_free_api_base}/news"
                async with session.get(url, params=params, timeout=aiohttp.ClientTimeout(total=30)) as response:
                    if response.status != 200:
                        logger.warning(f"ActuallyFreeAPI returned status {response.status}")
                        return []

                    data = await response.json()
                    articles = data.get("data", [])
                    all_articles.extend(articles)

                    logger.info(f"Fetched {len(articles)} articles from ActuallyFreeAPI (page 1)")

                    # Check if there are more pages
                    pagination = data.get("pagination", {})
                    has_next = pagination.get("hasNextPage", False)
                    total_pages = pagination.get("totalPages", 3)

                    # Fetch ALL pages to get complete dataset
                    page = 2
                    max_pages = min(total_pages, 50)  # Cap at 50 pages to be safe (5000 articles)
                    while has_next and page <= max_pages:
                        params["page"] = page
                        async with session.get(url, params=params, timeout=aiohttp.ClientTimeout(total=30)) as page_response:
                            if page_response.status == 200:
                                page_data = await page_response.json()
                                page_articles = page_data.get("data", [])
                                all_articles.extend(page_articles)

                                logger.info(f"Fetched {len(page_articles)} articles from ActuallyFreeAPI (page {page})")

                                pagination = page_data.get("pagination", {})
                                has_next = pagination.get("hasNextPage", False)
                                page += 1

                                # Small delay to be respectful
                                await asyncio.sleep(0.5)
                            else:
                                break

            # Normalize article format
            normalized_articles = []
            for article in all_articles:
                normalized_articles.append({
                    "title": article.get("title"),
                    "url": article.get("link"),
                    "published_at": datetime.fromisoformat(article.get("pub_date").replace("Z", "+00:00")) if article.get("pub_date") else None,
                    "source": article.get("source"),
                    "summary": article.get("description") or article.get("content", "")[:500],
                    "tickers": article.get("tickers", []),
                    "raw_content": article.get("content")
                })

            logger.info(f"ActuallyFreeAPI: Total {len(normalized_articles)} articles fetched")
            return normalized_articles

        except Exception as e:
            logger.error(f"Error fetching from ActuallyFreeAPI: {e}")
            return []

    def fetch_from_alpha_vantage(self, tickers: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Fetch news from Alpha Vantage News Sentiment API.

        Args:
            tickers: Comma-separated list of tickers
            limit: Number of articles

        Returns:
            List of news articles
        """
        try:
            articles = self.alpha_vantage.get_news_sentiment(
                tickers=tickers,
                limit=limit
            )

            # Normalize format
            normalized_articles = []
            for article in articles:
                # Extract ticker list from ticker_sentiment
                ticker_list = list(article.get("ticker_sentiment", {}).keys())

                normalized_articles.append({
                    "title": article.get("title"),
                    "url": article.get("url"),
                    "published_at": article.get("published_at"),
                    "source": article.get("source"),
                    "summary": article.get("summary"),
                    "tickers": ticker_list,
                    "sentiment_score": article.get("overall_sentiment_score"),
                    "raw_content": article.get("summary")
                })

            logger.info(f"Alpha Vantage: Fetched {len(normalized_articles)} articles")
            return normalized_articles

        except Exception as e:
            logger.error(f"Error fetching from Alpha Vantage: {e}")
            return []

    def deduplicate_articles(self, articles: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Remove duplicate articles by URL."""
        seen_urls = set()
        unique_articles = []

        for article in articles:
            url = article.get("url")
            if url and url not in seen_urls:
                seen_urls.add(url)
                unique_articles.append(article)

        logger.info(f"Deduplication: {len(articles)} -> {len(unique_articles)} articles")
        return unique_articles

    def process_article_sentiment(self, article: Dict[str, Any]) -> float:
        """
        Process article sentiment using Gemini if not already present.

        Args:
            article: Article dictionary

        Returns:
            Sentiment score (-1.0 to 1.0)
        """
        # If sentiment already provided (e.g., from Alpha Vantage), use it
        if article.get("sentiment_score") is not None:
            return float(article["sentiment_score"])

        # Otherwise, generate sentiment using Gemini
        try:
            content = f"{article.get('title', '')}. {article.get('summary', '')}"
            sentiment_result = self.gemini_service.analyze_sentiment(content)
            return sentiment_result["score"]
        except Exception as e:
            logger.warning(f"Error generating sentiment for article: {e}")
            return 0.0  # Neutral


async def collect_all_news() -> Dict[str, Any]:
    """
    Main function to collect news for all portfolio stocks.
    Called by the scheduler.

    Returns:
        Dictionary with collection statistics
    """
    logger.info("=== Starting News Collection ===")

    # Create database session
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    db = Session()

    try:
        # Get all stocks in portfolio
        stocks = db.query(Stock).all()

        if not stocks:
            logger.warning("No stocks in portfolio - skipping news collection")
            return {
                "status": "skipped",
                "reason": "no_stocks",
                "new_articles": 0,
                "updated_articles": 0
            }

        logger.info(f"Collecting news for {len(stocks)} stocks")

        collector = NewsCollectorService()
        all_articles = []

        # Fetch from ActuallyFreeAPI for each stock
        for stock in stocks:
            logger.info(f"Fetching news for {stock.symbol} from ActuallyFreeAPI")
            # Get articles from last 7 days
            start_date = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")
            articles = await collector.fetch_from_actually_free_api(
                ticker=stock.symbol,
                limit=20,
                start_date=start_date
            )
            all_articles.extend(articles)

            # Small delay between requests
            await asyncio.sleep(0.5)

        # Also fetch from Alpha Vantage for comprehensive coverage
        ticker_list = ",".join([s.symbol for s in stocks[:10]])  # Max 10 tickers
        logger.info(f"Fetching news from Alpha Vantage for tickers: {ticker_list}")
        av_articles = collector.fetch_from_alpha_vantage(ticker_list, limit=50)
        all_articles.extend(av_articles)

        # Deduplicate
        unique_articles = collector.deduplicate_articles(all_articles)
        logger.info(f"Processing {len(unique_articles)} unique articles")

        new_count = 0
        updated_count = 0
        error_count = 0

        for article_data in unique_articles:
            try:
                # Check if article already exists
                existing = db.query(NewsArticle).filter(
                    NewsArticle.url == article_data["url"]
                ).first()

                # Find related stocks based on tickers
                related_stocks = []
                for stock in stocks:
                    if stock.symbol in article_data.get("tickers", []):
                        related_stocks.append(stock)

                # Skip if no related stocks
                if not related_stocks:
                    continue

                # Process sentiment
                sentiment_score = collector.process_article_sentiment(article_data)

                if existing:
                    # Update sentiment if changed
                    if existing.sentiment_score != sentiment_score:
                        existing.sentiment_score = sentiment_score
                        updated_count += 1
                else:
                    # Create new article
                    article = NewsArticle(
                        title=article_data["title"],
                        source=article_data["source"],
                        url=article_data["url"],
                        published_at=article_data["published_at"],
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

                    # Generate embedding and add to vector store
                    try:
                        content = f"{article_data['title']}. {article_data['summary']}"
                        embedding = collector.gemini_service.generate_embedding(content)
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

            except Exception as e:
                logger.error(f"Error processing article '{article_data.get('title', 'Unknown')}': {e}")
                error_count += 1

        # Commit all changes
        db.commit()

        result = {
            "status": "success",
            "timestamp": datetime.now().isoformat(),
            "stocks_tracked": len(stocks),
            "articles_fetched": len(all_articles),
            "unique_articles": len(unique_articles),
            "new_articles": new_count,
            "updated_articles": updated_count,
            "errors": error_count
        }

        logger.info(f"=== News Collection Complete ===")
        logger.info(f"New: {new_count}, Updated: {updated_count}, Errors: {error_count}")

        return result

    except Exception as e:
        db.rollback()
        logger.error(f"Fatal error in news collection: {e}")
        return {
            "status": "error",
            "error": str(e),
            "new_articles": 0,
            "updated_articles": 0
        }
    finally:
        db.close()

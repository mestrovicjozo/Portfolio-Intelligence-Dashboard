"""
Script to re-analyze sentiment for all news articles that are missing sentiment scores.
"""

import sys
import os
from pathlib import Path

# When running in Docker, imports are from 'backend.app'
# When running locally, add backend directory to Python path
if os.path.exists('/app/backend'):
    # Running in Docker container
    from backend.app.db.base import SessionLocal
    from backend.app.models import NewsArticle
    from backend.app.services.gemini_service import GeminiService
else:
    # Running locally
    backend_dir = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(backend_dir))
    from app.db.base import SessionLocal
    from app.models import NewsArticle
    from app.services.gemini_service import GeminiService

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def fix_sentiment():
    """Re-analyze sentiment for all news articles."""
    db = SessionLocal()
    gemini_service = GeminiService()

    try:
        # Get all articles with null or zero sentiment
        articles = db.query(NewsArticle).filter(
            (NewsArticle.sentiment_score == None) | (NewsArticle.sentiment_score == 0.0)
        ).all()

        logger.info(f"Found {len(articles)} articles to process")

        processed = 0
        errors = 0

        for article in articles:
            try:
                # Analyze sentiment
                content = f"{article.title}. {article.summary or ''}"
                sentiment_result = gemini_service.analyze_sentiment(content)

                # Update article
                article.sentiment_score = sentiment_result["score"]

                logger.info(f"Article {article.id}: '{article.title[:50]}...' -> {sentiment_result['score']} ({sentiment_result['label']})")

                processed += 1

                # Commit every 10 articles
                if processed % 10 == 0:
                    db.commit()
                    logger.info(f"Progress: {processed}/{len(articles)}")

            except Exception as e:
                logger.error(f"Error processing article {article.id}: {e}")
                errors += 1
                continue

        # Final commit
        db.commit()

        logger.info(f"\n=== Summary ===")
        logger.info(f"Total processed: {processed}")
        logger.info(f"Errors: {errors}")

    except Exception as e:
        logger.error(f"Fatal error: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    fix_sentiment()

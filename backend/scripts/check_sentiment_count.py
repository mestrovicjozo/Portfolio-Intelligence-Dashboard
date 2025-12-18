"""Check how many articles have sentiment scores."""
import sys
import os
from pathlib import Path

# When running in Docker, imports are from 'backend.app'
# When running locally, add backend directory to Python path
if os.path.exists('/app/backend'):
    # Running in Docker container
    from backend.app.db.base import SessionLocal
    from backend.app.models import NewsArticle
else:
    # Running locally
    backend_dir = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(backend_dir))
    from app.db.base import SessionLocal
    from app.models import NewsArticle

db = SessionLocal()
try:
    # Count articles with sentiment
    count = db.query(NewsArticle).filter(
        NewsArticle.sentiment_score.isnot(None),
        NewsArticle.sentiment_score != 0.0
    ).count()

    print(f"Articles with sentiment: {count}")

    # Show some examples
    articles = db.query(NewsArticle).filter(
        NewsArticle.sentiment_score.isnot(None),
        NewsArticle.sentiment_score != 0.0
    ).limit(5).all()

    print("\nSample articles:")
    for article in articles:
        print(f"  - {article.title[:60]}... (sentiment: {article.sentiment_score})")

finally:
    db.close()

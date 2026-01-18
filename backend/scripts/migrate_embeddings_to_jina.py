"""
Script to migrate embeddings from Gemini (768d) to Jina AI (1024d).

This script:
1. Clears the existing ChromaDB collection
2. Re-embeds all news articles using Jina AI
3. Stores new embeddings in ChromaDB

Run with: python -m backend.scripts.migrate_embeddings_to_jina

IMPORTANT: This requires JINA_API_KEY to be set in .env
"""

import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import logging
from tqdm import tqdm

from backend.app.core.config import settings
from backend.app.models import NewsArticle, ArticleStock
from backend.app.services.vector_store import VectorStoreService
from backend.app.services.jina_embedding_service import JinaEmbeddingService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def migrate_embeddings(batch_size: int = 50, dry_run: bool = False):
    """
    Migrate all article embeddings to Jina AI.

    Args:
        batch_size: Number of articles to process in each batch
        dry_run: If True, only preview what would be done
    """
    # Check Jina API key
    if not settings.JINA_API_KEY:
        print("ERROR: JINA_API_KEY not set in .env")
        print("Please add: JINA_API_KEY=your_api_key_here")
        return

    # Initialize services
    jina = JinaEmbeddingService(settings.JINA_API_KEY)
    vector_store = VectorStoreService()

    # Create database session
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    db = Session()

    try:
        # Get all articles
        articles = db.query(NewsArticle).all()
        total = len(articles)

        print(f"\nFound {total} articles to re-embed")
        print(f"Current vector store count: {vector_store.get_article_count()}")
        print(f"Jina model: {jina.model} ({jina.dimension} dimensions)")

        if dry_run:
            print("\n[DRY RUN] Would migrate embeddings for all articles")
            return

        # Confirm
        confirm = input("\nProceed with migration? This will clear existing embeddings. (yes/no): ")
        if confirm.lower() != "yes":
            print("Aborted.")
            return

        # Clear existing embeddings
        print("\nClearing existing ChromaDB collection...")
        vector_store.clear_all()

        # Process in batches
        print(f"\nRe-embedding articles in batches of {batch_size}...")
        success_count = 0
        error_count = 0

        for i in tqdm(range(0, total, batch_size), desc="Processing batches"):
            batch = articles[i:i + batch_size]

            # Prepare texts for batch embedding
            texts = []
            article_data = []

            for article in batch:
                # Create content for embedding (NewsArticle has title and summary, not content)
                content = f"{article.title}\n\n{article.summary or ''}"
                content = content[:8000]  # Limit length

                texts.append(content)

                # Get related stock symbols
                stock_relations = db.query(ArticleStock).filter(
                    ArticleStock.article_id == article.id
                ).all()
                stock_symbols = [r.stock.symbol for r in stock_relations if r.stock]

                article_data.append({
                    'id': article.id,
                    'content': content,
                    'metadata': {
                        'title': article.title,
                        'source': article.source,
                        'published_at': article.published_at.isoformat() if article.published_at else None,
                        'sentiment_score': float(article.sentiment_score) if article.sentiment_score else None,
                        'stocks': stock_symbols
                    }
                })

            try:
                # Generate batch embeddings
                embeddings = jina.generate_embeddings_batch(texts)

                # Add to vector store
                vector_store.add_articles_batch(article_data, embeddings)
                success_count += len(batch)

            except Exception as e:
                logger.error(f"Error processing batch {i // batch_size}: {e}")
                error_count += len(batch)

                # Try individual embedding as fallback
                for j, article in enumerate(batch):
                    try:
                        embedding = jina.generate_embedding(texts[j])
                        vector_store.add_article(
                            article_data[j]['id'],
                            article_data[j]['content'],
                            embedding,
                            article_data[j]['metadata']
                        )
                        success_count += 1
                        error_count -= 1
                    except Exception as e2:
                        logger.error(f"Error embedding article {article.id}: {e2}")

        # Summary
        print(f"\n=== Migration Complete ===")
        print(f"Success: {success_count}")
        print(f"Errors: {error_count}")
        print(f"New vector store count: {vector_store.get_article_count()}")

    except Exception as e:
        logger.error(f"Migration failed: {e}")
        raise
    finally:
        db.close()


def check_embedding_dimension():
    """Check current embedding dimension in ChromaDB."""
    vector_store = VectorStoreService()

    count = vector_store.get_article_count()
    print(f"Vector store article count: {count}")

    if count > 0:
        # Try to get a sample to check dimension
        try:
            # Make a test query with small embedding
            test_embedding = [0.0] * 768  # Gemini dimension
            results = vector_store.search_similar(test_embedding, n_results=1)
            print("Current embedding dimension: 768 (Gemini)")
        except Exception:
            try:
                test_embedding = [0.0] * 1024  # Jina dimension
                results = vector_store.search_similar(test_embedding, n_results=1)
                print("Current embedding dimension: 1024 (Jina)")
            except Exception as e:
                print(f"Could not determine dimension: {e}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Migrate embeddings to Jina AI")
    parser.add_argument("--batch-size", type=int, default=50, help="Batch size for processing")
    parser.add_argument("--dry-run", action="store_true", help="Preview without making changes")
    parser.add_argument("--check", action="store_true", help="Check current embedding status")

    args = parser.parse_args()

    if args.check:
        check_embedding_dimension()
    else:
        migrate_embeddings(batch_size=args.batch_size, dry_run=args.dry_run)

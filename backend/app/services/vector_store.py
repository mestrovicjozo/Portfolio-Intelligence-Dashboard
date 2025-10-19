import chromadb
from chromadb.config import Settings
from typing import List, Dict, Any, Optional
import logging
from backend.app.core.config import settings as app_settings

logger = logging.getLogger(__name__)


class VectorStoreService:
    """Service for managing ChromaDB vector store for news articles."""

    def __init__(self):
        # Initialize ChromaDB client with persistent storage
        self.client = chromadb.PersistentClient(
            path=app_settings.CHROMA_PERSIST_DIR,
            settings=Settings(anonymized_telemetry=False)
        )

        # Get or create collection for news articles
        self.collection = self.client.get_or_create_collection(
            name="news_embeddings",
            metadata={"description": "Financial news article embeddings"}
        )

    def add_article(self,
                   article_id: int,
                   content: str,
                   embedding: List[float],
                   metadata: Dict[str, Any]) -> None:
        """
        Add an article to the vector store.

        Args:
            article_id: Unique article ID
            content: Article text content
            embedding: Embedding vector
            metadata: Additional metadata (stocks, published_at, sentiment, etc.)
        """
        try:
            # ChromaDB requires string IDs
            doc_id = f"article_{article_id}"

            # Ensure metadata values are valid types for ChromaDB
            clean_metadata = {}
            for key, value in metadata.items():
                if isinstance(value, (str, int, float, bool)):
                    clean_metadata[key] = value
                elif isinstance(value, list):
                    # Convert lists to comma-separated strings
                    clean_metadata[key] = ",".join(str(v) for v in value)
                elif value is not None:
                    clean_metadata[key] = str(value)

            self.collection.add(
                ids=[doc_id],
                embeddings=[embedding],
                documents=[content],
                metadatas=[clean_metadata]
            )

            logger.info(f"Added article {article_id} to vector store")
        except Exception as e:
            logger.error(f"Error adding article to vector store: {e}")
            raise

    def add_articles_batch(self,
                          articles: List[Dict[str, Any]],
                          embeddings: List[List[float]]) -> None:
        """
        Add multiple articles to the vector store in batch.

        Args:
            articles: List of article dicts with id, content, and metadata
            embeddings: List of embedding vectors
        """
        if len(articles) != len(embeddings):
            raise ValueError("Number of articles must match number of embeddings")

        try:
            ids = [f"article_{article['id']}" for article in articles]
            documents = [article['content'] for article in articles]
            metadatas = []

            for article in articles:
                metadata = article.get('metadata', {})
                clean_metadata = {}
                for key, value in metadata.items():
                    if isinstance(value, (str, int, float, bool)):
                        clean_metadata[key] = value
                    elif isinstance(value, list):
                        clean_metadata[key] = ",".join(str(v) for v in value)
                    elif value is not None:
                        clean_metadata[key] = str(value)
                metadatas.append(clean_metadata)

            self.collection.add(
                ids=ids,
                embeddings=embeddings,
                documents=documents,
                metadatas=metadatas
            )

            logger.info(f"Added {len(articles)} articles to vector store in batch")
        except Exception as e:
            logger.error(f"Error adding articles batch to vector store: {e}")
            raise

    def search_similar(self,
                      query_embedding: List[float],
                      n_results: int = 5,
                      filter_metadata: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """
        Search for similar articles using embedding similarity.

        Args:
            query_embedding: Query embedding vector
            n_results: Number of results to return
            filter_metadata: Optional metadata filters

        Returns:
            List of similar articles with metadata and scores
        """
        try:
            where = filter_metadata if filter_metadata else None

            results = self.collection.query(
                query_embeddings=[query_embedding],
                n_results=n_results,
                where=where
            )

            # Format results
            articles = []
            if results['ids'] and len(results['ids'][0]) > 0:
                for idx in range(len(results['ids'][0])):
                    article_id = results['ids'][0][idx].replace("article_", "")
                    document = results['documents'][0][idx] if results['documents'] else ""
                    metadata = results['metadatas'][0][idx] if results['metadatas'] else {}
                    distance = results['distances'][0][idx] if results.get('distances') else 0

                    # Parse comma-separated stock symbols back to list
                    if 'stocks' in metadata and isinstance(metadata['stocks'], str):
                        metadata['stocks'] = metadata['stocks'].split(',')

                    articles.append({
                        'article_id': int(article_id),
                        'content': document,
                        'metadata': metadata,
                        'similarity_score': 1 - distance  # Convert distance to similarity
                    })

            return articles
        except Exception as e:
            logger.error(f"Error searching vector store: {e}")
            return []

    def delete_article(self, article_id: int) -> None:
        """Delete an article from the vector store."""
        try:
            doc_id = f"article_{article_id}"
            self.collection.delete(ids=[doc_id])
            logger.info(f"Deleted article {article_id} from vector store")
        except Exception as e:
            logger.error(f"Error deleting article from vector store: {e}")
            raise

    def get_article_count(self) -> int:
        """Get total number of articles in the vector store."""
        try:
            return self.collection.count()
        except Exception as e:
            logger.error(f"Error getting article count: {e}")
            return 0

    def clear_all(self) -> None:
        """Clear all articles from the vector store."""
        try:
            # Delete the collection and recreate it
            self.client.delete_collection("news_embeddings")
            self.collection = self.client.get_or_create_collection(
                name="news_embeddings",
                metadata={"description": "Financial news article embeddings"}
            )
            logger.info("Cleared all articles from vector store")
        except Exception as e:
            logger.error(f"Error clearing vector store: {e}")
            raise

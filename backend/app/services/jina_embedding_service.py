"""
Jina AI Embedding Service - Cost-optimized embeddings for vector search.

Replaces Gemini embeddings for cost optimization while keeping Gemini for:
- Sentiment analysis
- Q&A generation
- Roboadvisor signals

Jina AI advantages:
- Free tier: 1M tokens/month
- Specialized retrieval embeddings (passage vs query)
- 1024 dimensions (vs Gemini's 768)
"""

import requests
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)


class JinaEmbeddingService:
    """
    Jina AI embedding service for document and query embeddings.

    Uses jina-embeddings-v3 model with 1024 dimensions.
    Supports different task types for optimal retrieval:
    - retrieval.passage: For documents/articles being indexed
    - retrieval.query: For search queries
    """

    def __init__(self, api_key: str, model: str = "jina-embeddings-v3"):
        """
        Initialize Jina embedding service.

        Args:
            api_key: Jina AI API key
            model: Embedding model to use (default: jina-embeddings-v3)
        """
        self.api_key = api_key
        self.model = model
        self.base_url = "https://api.jina.ai/v1/embeddings"
        self.dimension = 1024  # jina-embeddings-v3 dimension

    def _make_request(
        self,
        texts: List[str],
        task: str = "retrieval.passage"
    ) -> List[List[float]]:
        """
        Make embedding request to Jina AI API.

        Args:
            texts: List of texts to embed
            task: Task type (retrieval.passage or retrieval.query)

        Returns:
            List of embedding vectors
        """
        if not self.api_key:
            raise ValueError("Jina API key not configured")

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        payload = {
            "model": self.model,
            "input": texts,
            "task": task
        }

        try:
            response = requests.post(
                self.base_url,
                headers=headers,
                json=payload,
                timeout=30
            )

            if response.status_code == 401:
                raise ValueError("Invalid Jina API key")
            elif response.status_code == 429:
                raise Exception("Jina API rate limit exceeded")
            elif response.status_code != 200:
                error_detail = response.json().get("detail", response.text)
                raise Exception(f"Jina API error: {error_detail}")

            data = response.json()
            embeddings = [item["embedding"] for item in data["data"]]

            logger.debug(f"Generated {len(embeddings)} embeddings using Jina AI")
            return embeddings

        except requests.exceptions.RequestException as e:
            logger.error(f"Jina API request failed: {e}")
            raise

    def generate_embedding(self, text: str) -> List[float]:
        """
        Generate embedding for a document/passage.

        Uses retrieval.passage task for optimal document indexing.

        Args:
            text: Document text to embed

        Returns:
            Embedding vector (1024 dimensions)
        """
        if not text or not text.strip():
            raise ValueError("Empty text cannot be embedded")

        embeddings = self._make_request([text], task="retrieval.passage")
        return embeddings[0]

    def generate_query_embedding(self, query: str) -> List[float]:
        """
        Generate embedding for a search query.

        Uses retrieval.query task for optimal query-document matching.

        Args:
            query: Search query text

        Returns:
            Query embedding vector (1024 dimensions)
        """
        if not query or not query.strip():
            raise ValueError("Empty query cannot be embedded")

        embeddings = self._make_request([query], task="retrieval.query")
        return embeddings[0]

    def generate_embeddings_batch(
        self,
        texts: List[str],
        task: str = "retrieval.passage"
    ) -> List[List[float]]:
        """
        Generate embeddings for multiple texts in batch.

        More efficient than individual calls for multiple documents.

        Args:
            texts: List of texts to embed
            task: Task type (retrieval.passage or retrieval.query)

        Returns:
            List of embedding vectors
        """
        if not texts:
            return []

        # Filter out empty texts
        valid_texts = [t for t in texts if t and t.strip()]

        if not valid_texts:
            raise ValueError("No valid texts to embed")

        # Jina AI has batch limits, process in chunks of 100
        batch_size = 100
        all_embeddings = []

        for i in range(0, len(valid_texts), batch_size):
            batch = valid_texts[i:i + batch_size]
            embeddings = self._make_request(batch, task=task)
            all_embeddings.extend(embeddings)

            logger.debug(f"Processed batch {i // batch_size + 1}, total: {len(all_embeddings)}")

        return all_embeddings

    def get_embedding_dimension(self) -> int:
        """Get the embedding dimension for this model."""
        return self.dimension

    def health_check(self) -> bool:
        """
        Check if Jina AI API is accessible.

        Returns:
            True if API is healthy
        """
        try:
            # Make a minimal request
            self._make_request(["test"], task="retrieval.passage")
            return True
        except Exception as e:
            logger.warning(f"Jina AI health check failed: {e}")
            return False


# Singleton instance will be created in config or when needed
_jina_service: Optional[JinaEmbeddingService] = None


def get_jina_service(api_key: str = None) -> JinaEmbeddingService:
    """
    Get or create Jina embedding service instance.

    Args:
        api_key: Optional API key (uses cached instance if not provided)

    Returns:
        JinaEmbeddingService instance
    """
    global _jina_service

    if api_key:
        _jina_service = JinaEmbeddingService(api_key)
    elif _jina_service is None:
        from backend.app.core.config import settings
        if hasattr(settings, 'JINA_API_KEY') and settings.JINA_API_KEY:
            _jina_service = JinaEmbeddingService(settings.JINA_API_KEY)
        else:
            raise ValueError("JINA_API_KEY not configured")

    return _jina_service

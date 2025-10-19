import google.generativeai as genai
from typing import List, Dict, Any, Optional
import logging
from backend.app.core.config import settings

logger = logging.getLogger(__name__)


class GeminiService:
    """Service for interacting with Google Gemini API."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.GEMINI_API_KEY
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel(settings.GEMINI_MODEL)

    def generate_embedding(self, text: str) -> List[float]:
        """
        Generate embedding vector for text using Gemini.

        Args:
            text: Input text to embed

        Returns:
            List of floats representing the embedding vector
        """
        try:
            result = genai.embed_content(
                model="models/text-embedding-004",
                content=text,
                task_type="retrieval_document"
            )
            return result['embedding']
        except Exception as e:
            logger.error(f"Error generating embedding: {e}")
            raise

    def generate_query_embedding(self, query: str) -> List[float]:
        """
        Generate embedding vector for search query.

        Args:
            query: Search query text

        Returns:
            List of floats representing the embedding vector
        """
        try:
            result = genai.embed_content(
                model="models/text-embedding-004",
                content=query,
                task_type="retrieval_query"
            )
            return result['embedding']
        except Exception as e:
            logger.error(f"Error generating query embedding: {e}")
            raise

    def analyze_sentiment(self, text: str) -> Dict[str, Any]:
        """
        Analyze sentiment of text using Gemini.

        Args:
            text: Text to analyze

        Returns:
            Dict with sentiment score (-1 to 1), label, and confidence
        """
        prompt = f"""Analyze the sentiment of the following financial news article or text.
Provide a sentiment score from -1.0 (very negative) to 1.0 (very positive), where 0 is neutral.
Also provide a label (positive, neutral, or negative) and a confidence score (0 to 1).

Respond ONLY with a JSON object in this exact format:
{{"score": <float between -1 and 1>, "label": "<positive/neutral/negative>", "confidence": <float between 0 and 1>}}

Text to analyze:
{text}
"""

        try:
            response = self.model.generate_content(prompt)
            result_text = response.text.strip()

            # Parse JSON response
            import json
            # Remove markdown code blocks if present
            if result_text.startswith("```"):
                result_text = result_text.split("```")[1]
                if result_text.startswith("json"):
                    result_text = result_text[4:]
                result_text = result_text.strip()

            sentiment = json.loads(result_text)

            # Validate and normalize
            score = max(-1.0, min(1.0, float(sentiment.get("score", 0))))
            label = sentiment.get("label", "neutral").lower()
            confidence = max(0.0, min(1.0, float(sentiment.get("confidence", 0.5))))

            return {
                "score": score,
                "label": label,
                "confidence": confidence
            }
        except Exception as e:
            logger.error(f"Error analyzing sentiment: {e}")
            # Return neutral sentiment on error
            return {
                "score": 0.0,
                "label": "neutral",
                "confidence": 0.0
            }

    def is_finance_related(self, question: str) -> bool:
        """
        Check if a question is related to finance, stocks, or investing.

        Args:
            question: User's question

        Returns:
            True if finance-related, False otherwise
        """
        prompt = f"""Determine if the following question is related to finance, stocks, investing, markets, economy, or business.

Question: {question}

Respond with ONLY "YES" or "NO".
- YES if the question is about finance, stocks, companies, investing, markets, economy, business, trading, or portfolio management
- NO if the question is about weather, sports, entertainment, general knowledge, or any non-financial topic

Response:"""

        try:
            response = self.model.generate_content(prompt)
            result = response.text.strip().upper()
            return result == "YES"
        except Exception as e:
            logger.error(f"Error checking question relevance: {e}")
            # Default to allowing the question if check fails
            return True

    def answer_question(self, question: str, context: List[Dict[str, Any]]) -> str:
        """
        Answer a question based on provided context using Gemini.

        Args:
            question: User's question
            context: List of relevant articles/documents with metadata

        Returns:
            Generated answer string
        """
        # Check if question is finance-related
        if not self.is_finance_related(question):
            return "I'm sorry, but I can only answer questions related to finance, stocks, investing, and your portfolio. Please ask a question about financial markets, companies, or your investments."

        # Build context string from articles
        context_str = ""
        for idx, item in enumerate(context, 1):
            context_str += f"\n--- Article {idx} ---\n"
            context_str += f"Title: {item.get('title', 'N/A')}\n"
            context_str += f"Source: {item.get('source', 'N/A')}\n"
            context_str += f"Published: {item.get('published_at', 'N/A')}\n"
            context_str += f"Summary: {item.get('summary', 'N/A')}\n"
            context_str += f"Sentiment: {item.get('sentiment_score', 'N/A')}\n"
            if item.get('stocks'):
                context_str += f"Related Stocks: {', '.join(item.get('stocks', []))}\n"

        prompt = f"""You are a financial analyst assistant helping investors understand their portfolio.
Answer the following question based on the provided news articles and context.

IMPORTANT: Only answer questions related to finance, stocks, markets, and investing.
If asked about non-financial topics, politely decline.

Question: {question}

Context from recent news articles:
{context_str}

Instructions:
- Provide a clear, concise answer based on the context
- If the context doesn't contain enough information, say so
- Include specific details from the articles when relevant
- Mention sentiment trends if applicable
- Be objective and factual
- Only answer finance-related questions

Answer:
"""

        try:
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            logger.error(f"Error generating answer: {e}")
            return "I apologize, but I encountered an error while processing your question. Please try again."

    def summarize_text(self, text: str, max_length: int = 200) -> str:
        """
        Generate a concise summary of text.

        Args:
            text: Text to summarize
            max_length: Maximum length of summary in words

        Returns:
            Summary string
        """
        prompt = f"""Summarize the following text in {max_length} words or less.
Focus on the key financial information and market impact.

Text:
{text}

Summary:
"""

        try:
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            logger.error(f"Error summarizing text: {e}")
            return text[:500] + "..." if len(text) > 500 else text

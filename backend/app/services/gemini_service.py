import google.generativeai as genai
from typing import List, Dict, Any, Optional
import logging
import json
from backend.app.core.config import settings

logger = logging.getLogger(__name__)

# Lazy import to avoid circular dependency
_jina_service = None


def _get_jina_service():
    """Get Jina service instance lazily."""
    global _jina_service
    if _jina_service is None:
        try:
            from backend.app.services.jina_embedding_service import get_jina_service
            _jina_service = get_jina_service()
        except Exception as e:
            logger.warning(f"Jina AI not available, falling back to Gemini embeddings: {e}")
            _jina_service = False  # Mark as unavailable
    return _jina_service if _jina_service else None


class GeminiService:
    """
    Service for interacting with Google Gemini API.

    Architecture:
    - Embeddings: Delegated to Jina AI (cost optimization)
    - Sentiment Analysis: Gemini
    - Q&A Generation: Gemini
    - Roboadvisor Signals: Gemini
    """

    def __init__(self, api_key: Optional[str] = None, use_jina_embeddings: bool = True):
        self.api_key = api_key or settings.GEMINI_API_KEY
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel(settings.GEMINI_MODEL)
        self._use_jina = use_jina_embeddings

    def generate_embedding(self, text: str) -> List[float]:
        """
        Generate embedding vector for text.

        Delegates to Jina AI for cost optimization if available.

        Args:
            text: Input text to embed

        Returns:
            List of floats representing the embedding vector
        """
        # Try Jina AI first (cost optimization)
        if self._use_jina:
            jina = _get_jina_service()
            if jina:
                try:
                    return jina.generate_embedding(text)
                except Exception as e:
                    logger.warning(f"Jina embedding failed, falling back to Gemini: {e}")

        # Fallback to Gemini
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

        Delegates to Jina AI for cost optimization if available.

        Args:
            query: Search query text

        Returns:
            List of floats representing the embedding vector
        """
        # Try Jina AI first
        if self._use_jina:
            jina = _get_jina_service()
            if jina:
                try:
                    return jina.generate_query_embedding(query)
                except Exception as e:
                    logger.warning(f"Jina query embedding failed, falling back to Gemini: {e}")

        # Fallback to Gemini
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

    def generate_embeddings_batch(self, texts: List[str]) -> List[List[float]]:
        """
        Generate embeddings for multiple texts in batch.

        More efficient for multiple documents.

        Args:
            texts: List of texts to embed

        Returns:
            List of embedding vectors
        """
        if self._use_jina:
            jina = _get_jina_service()
            if jina:
                try:
                    return jina.generate_embeddings_batch(texts)
                except Exception as e:
                    logger.warning(f"Jina batch embedding failed, falling back to sequential: {e}")

        # Fallback to sequential Gemini calls
        embeddings = []
        for text in texts:
            emb = self.generate_embedding(text)
            embeddings.append(emb)
        return embeddings

    def analyze_sentiment(self, text: str) -> Dict[str, Any]:
        """
        Analyze sentiment of financial text using Gemini with enhanced financial context.

        Args:
            text: Text to analyze (news article, earnings report, etc.)

        Returns:
            Dict with sentiment score (-1 to 1), label, confidence, and reasoning
        """
        prompt = f"""You are a financial sentiment analysis expert. Analyze the sentiment of the following financial text.

IMPORTANT CONTEXT FOR FINANCIAL SENTIMENT:
- Positive indicators: revenue growth, earnings beat, positive guidance, partnerships, expansion, innovation
- Negative indicators: revenue miss, layoffs, regulatory issues, lawsuits, debt concerns, competition threats
- Neutral: routine announcements, balanced reports, forward-looking statements without clear direction

Consider:
1. **Market impact**: How will this affect stock price?
2. **Investor confidence**: Will this attract or repel investors?
3. **Company fundamentals**: Does this strengthen or weaken the business?
4. **Risk factors**: Are there hidden concerns or opportunities?

EXAMPLES:
- "Company reports Q3 revenue up 25% YoY, beating analyst expectations" → score: 0.75 (positive)
- "CEO announces restructuring plan, 500 jobs to be cut" → score: -0.3 (slightly negative, could be seen as cost-cutting)
- "Company maintains quarterly dividend at $0.50 per share" → score: 0.1 (neutral to slightly positive)
- "SEC opens investigation into accounting practices" → score: -0.85 (very negative)

Provide a sentiment score from -1.0 (very negative for investors) to 1.0 (very positive for investors), where 0 is neutral.
Also provide a label (positive, neutral, or negative), confidence score (0 to 1), and brief reasoning.

Respond ONLY with a JSON object in this exact format:
{{"score": <float between -1 and 1>, "label": "<positive/neutral/negative>", "confidence": <float between 0 and 1>, "reasoning": "<brief explanation>"}}

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
            reasoning = sentiment.get("reasoning", "")

            return {
                "score": score,
                "label": label,
                "confidence": confidence,
                "reasoning": reasoning
            }
        except Exception as e:
            logger.error(f"Error analyzing sentiment: {e}")
            # Return neutral sentiment on error
            return {
                "score": 0.0,
                "label": "neutral",
                "confidence": 0.0,
                "reasoning": "Error during analysis"
            }

    def analyze_sentiment_batch(self, texts: List[str]) -> List[Dict[str, Any]]:
        """
        Analyze sentiment for multiple texts in batch.

        Args:
            texts: List of texts to analyze

        Returns:
            List of sentiment dictionaries
        """
        results = []
        for text in texts:
            result = self.analyze_sentiment(text)
            results.append(result)
        return results

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

        Note: Finance-related validation should be done before calling this method
        """
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

            # FALLBACK: Generate intelligent answer from context when API unavailable
            if context and len(context) > 0:
                # Analyze sentiment and topics
                stocks_mentioned = set()
                sentiments = []
                positive_news = []
                negative_news = []
                neutral_news = []

                for item in context:
                    stocks_mentioned.update(item.get('stocks', []))
                    sentiment = item.get('sentiment_score')
                    if sentiment is not None:
                        sentiments.append(sentiment)
                        if sentiment > 0.2:
                            positive_news.append(item.get('title'))
                        elif sentiment < -0.2:
                            negative_news.append(item.get('title'))
                        else:
                            neutral_news.append(item.get('title'))

                # Generate contextual answer
                answer_parts = []

                # Opening based on question
                if stocks_mentioned:
                    stocks_str = ', '.join(sorted(stocks_mentioned))
                    answer_parts.append(f"Based on {len(context)} recent articles, here's what's happening with {stocks_str}:")
                else:
                    answer_parts.append(f"Based on {len(context)} recent articles:")

                # Sentiment analysis
                if sentiments:
                    avg_sentiment = sum(sentiments) / len(sentiments)
                    if avg_sentiment > 0.3:
                        answer_parts.append(f"\n**Overall Sentiment: Positive** (average {avg_sentiment:.2f})")
                        answer_parts.append(f"The news coverage is predominantly positive, with {len(positive_news)} positive developments.")
                    elif avg_sentiment < -0.3:
                        answer_parts.append(f"\n**Overall Sentiment: Negative** (average {avg_sentiment:.2f})")
                        answer_parts.append(f"Recent news shows concerns, with {len(negative_news)} negative stories emerging.")
                    else:
                        answer_parts.append(f"\n**Overall Sentiment: Mixed/Neutral** (average {avg_sentiment:.2f})")
                        answer_parts.append(f"The news is balanced with {len(positive_news)} positive and {len(negative_news)} negative developments.")

                # Key headlines
                answer_parts.append("\n**Key Headlines:**")
                for idx, item in enumerate(context[:3], 1):
                    title = item.get('title', 'N/A')
                    sentiment = item.get('sentiment_score')
                    sentiment_emoji = "📈" if sentiment and sentiment > 0.2 else "📉" if sentiment and sentiment < -0.2 else "➡️"
                    answer_parts.append(f"{idx}. {sentiment_emoji} {title}")

                # Conclusion
                if len(positive_news) > len(negative_news):
                    answer_parts.append("\nThe recent developments appear favorable for these stocks.")
                elif len(negative_news) > len(positive_news):
                    answer_parts.append("\nInvestors should monitor these concerns closely.")
                else:
                    answer_parts.append("\nThe market sentiment remains balanced - continued monitoring recommended.")

                return "\n".join(answer_parts)

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

    def generate_trading_signal(
        self,
        symbol: str,
        risk_data: Dict[str, Any],
        sentiment_data: Dict[str, Any],
        price_trend: Dict[str, Any],
        news_context: Optional[List[Dict[str, Any]]] = None
    ) -> Dict[str, Any]:
        """
        Generate AI-powered trading signal for a stock.

        Uses risk metrics, sentiment analysis, and price trends to generate
        buy/sell/hold recommendations with confidence scores.

        Args:
            symbol: Stock ticker symbol
            risk_data: Risk scores (volatility, beta, overall risk)
            sentiment_data: News sentiment analysis
            price_trend: Price movement data (returns, momentum)
            news_context: Optional recent news articles

        Returns:
            Dict with action, confidence, reasoning, and supporting data
        """
        # Build context for analysis
        news_str = ""
        if news_context:
            for idx, article in enumerate(news_context[:5], 1):
                news_str += f"\n{idx}. {article.get('title', 'N/A')} (Sentiment: {article.get('sentiment_score', 'N/A')})"

        prompt = f"""You are an expert financial analyst providing trading recommendations.
Analyze the following data for {symbol} and provide a trading signal.

RISK METRICS:
- Overall Risk Score: {risk_data.get('overall_risk', 'N/A')}/100
- Volatility Score: {risk_data.get('volatility_score', 'N/A')}/100
- Beta: {risk_data.get('beta', 'N/A')}
- Sentiment Risk: {risk_data.get('sentiment_risk', 'N/A')}/100

SENTIMENT DATA:
- Average Score: {sentiment_data.get('average_score', 'N/A')} (-1 to 1)
- Trend: {sentiment_data.get('trend', 'N/A')}
- Article Count: {sentiment_data.get('article_count', 'N/A')}

PRICE TRENDS:
- 7-Day Return: {price_trend.get('return_7d', 'N/A')}%
- 30-Day Return: {price_trend.get('return_30d', 'N/A')}%
- Momentum: {price_trend.get('momentum', 'N/A')}

RECENT NEWS:{news_str if news_str else ' No recent news available'}

Based on this analysis, provide a trading recommendation.

IMPORTANT GUIDELINES:
1. Consider both risk and opportunity
2. Higher volatility = lower confidence
3. Negative sentiment trends warrant caution
4. Strong momentum can support trend continuation
5. Be conservative with high-risk stocks

Respond ONLY with a JSON object in this exact format:
{{"action": "<BUY/SELL/HOLD>", "confidence": <float 0-1>, "reasoning": "<2-3 sentence explanation>", "key_factors": ["<factor1>", "<factor2>", "<factor3>"], "risk_level": "<low/medium/high>", "time_horizon": "<short/medium/long>"}}
"""

        try:
            response = self.model.generate_content(prompt)
            result_text = response.text.strip()

            # Parse JSON response
            if result_text.startswith("```"):
                result_text = result_text.split("```")[1]
                if result_text.startswith("json"):
                    result_text = result_text[4:]
                result_text = result_text.strip()

            signal = json.loads(result_text)

            # Validate and normalize
            action = signal.get("action", "HOLD").upper()
            if action not in ["BUY", "SELL", "HOLD"]:
                action = "HOLD"

            confidence = max(0.0, min(1.0, float(signal.get("confidence", 0.5))))

            return {
                "symbol": symbol,
                "action": action,
                "confidence": confidence,
                "reasoning": signal.get("reasoning", ""),
                "key_factors": signal.get("key_factors", []),
                "risk_level": signal.get("risk_level", "medium"),
                "time_horizon": signal.get("time_horizon", "medium"),
                "generated_at": None  # Will be set by caller
            }

        except Exception as e:
            logger.error(f"Error generating trading signal for {symbol}: {e}")
            return {
                "symbol": symbol,
                "action": "HOLD",
                "confidence": 0.0,
                "reasoning": "Unable to generate signal due to analysis error",
                "key_factors": [],
                "risk_level": "unknown",
                "time_horizon": "unknown",
                "error": str(e)
            }

    def generate_portfolio_analysis(
        self,
        portfolio_data: Dict[str, Any],
        risk_scores: List[Dict[str, Any]],
        allocation_drift: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Generate comprehensive portfolio analysis and recommendations.

        Args:
            portfolio_data: Portfolio summary (total value, positions)
            risk_scores: Risk scores for each position
            allocation_drift: Current vs target allocation

        Returns:
            Dict with analysis, recommendations, and action items
        """
        # Build position summary
        positions_str = ""
        for score in risk_scores[:10]:  # Limit to top 10
            positions_str += f"\n- {score.get('symbol')}: Risk={score.get('overall_risk', 'N/A')}/100, Weight={score.get('weight', 'N/A')}%"

        # Build drift summary
        drift_str = ""
        for symbol, drift in list(allocation_drift.items())[:10]:
            drift_str += f"\n- {symbol}: Drift={drift.get('drift', 0):+.1f}%"

        prompt = f"""You are a professional portfolio advisor analyzing a client's investment portfolio.

PORTFOLIO SUMMARY:
- Total Value: ${portfolio_data.get('total_value', 0):,.2f}
- Number of Positions: {portfolio_data.get('position_count', 0)}
- Average Risk Score: {portfolio_data.get('average_risk', 'N/A')}/100

POSITION RISK SCORES:{positions_str if positions_str else ' No positions'}

ALLOCATION DRIFT (vs targets):{drift_str if drift_str else ' No drift data'}

Provide a comprehensive portfolio analysis with actionable recommendations.

Respond ONLY with a JSON object in this exact format:
{{
    "overall_health": "<excellent/good/fair/poor>",
    "risk_assessment": "<conservative/moderate/aggressive>",
    "summary": "<2-3 sentence portfolio summary>",
    "key_concerns": ["<concern1>", "<concern2>"],
    "opportunities": ["<opportunity1>", "<opportunity2>"],
    "recommendations": [
        {{"priority": "high", "action": "<specific action>", "reasoning": "<why>"}},
        {{"priority": "medium", "action": "<specific action>", "reasoning": "<why>"}}
    ],
    "rebalancing_needed": <true/false>,
    "suggested_actions": ["<action1>", "<action2>"]
}}
"""

        try:
            response = self.model.generate_content(prompt)
            result_text = response.text.strip()

            if result_text.startswith("```"):
                result_text = result_text.split("```")[1]
                if result_text.startswith("json"):
                    result_text = result_text[4:]
                result_text = result_text.strip()

            analysis = json.loads(result_text)
            return analysis

        except Exception as e:
            logger.error(f"Error generating portfolio analysis: {e}")
            return {
                "overall_health": "unknown",
                "risk_assessment": "unknown",
                "summary": "Unable to generate analysis due to error",
                "key_concerns": [],
                "opportunities": [],
                "recommendations": [],
                "rebalancing_needed": False,
                "suggested_actions": [],
                "error": str(e)
            }

    def get_embedding_service_info(self) -> Dict[str, Any]:
        """
        Get information about the current embedding service.

        Returns:
            Dict with embedding service details
        """
        jina = _get_jina_service() if self._use_jina else None

        if jina:
            return {
                "service": "jina",
                "model": jina.model,
                "dimension": jina.dimension,
                "status": "active"
            }
        else:
            return {
                "service": "gemini",
                "model": "text-embedding-004",
                "dimension": 768,
                "status": "active",
                "note": "Jina AI not configured, using Gemini fallback"
            }

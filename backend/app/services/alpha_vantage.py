import requests
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import logging
from backend.app.core.config import settings

logger = logging.getLogger(__name__)


class AlphaVantageService:
    """Service for interacting with Alpha Vantage API."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.ALPHA_VANTAGE_API_KEY
        self.base_url = settings.ALPHA_VANTAGE_BASE_URL

    def _make_request(self, params: Dict[str, str]) -> Dict[str, Any]:
        """Make request to Alpha Vantage API."""
        params["apikey"] = self.api_key

        try:
            response = requests.get(self.base_url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            # Check for API error messages
            if "Error Message" in data:
                raise ValueError(f"Alpha Vantage API error: {data['Error Message']}")
            if "Note" in data:
                logger.warning(f"Alpha Vantage API note: {data['Note']}")

            return data
        except requests.exceptions.RequestException as e:
            logger.error(f"Alpha Vantage API request failed: {e}")
            raise

    def get_quote(self, symbol: str) -> Optional[Dict[str, Any]]:
        """Get current quote for a stock symbol."""
        params = {
            "function": "GLOBAL_QUOTE",
            "symbol": symbol
        }

        data = self._make_request(params)
        quote = data.get("Global Quote", {})

        if not quote:
            return None

        return {
            "symbol": quote.get("01. symbol"),
            "price": float(quote.get("05. price", 0)),
            "change": float(quote.get("09. change", 0)),
            "change_percent": quote.get("10. change percent", "0%").rstrip("%"),
            "volume": int(quote.get("06. volume", 0)),
            "latest_trading_day": quote.get("07. latest trading day")
        }

    def get_daily_prices(self, symbol: str, outputsize: str = "compact") -> List[Dict[str, Any]]:
        """
        Get daily price data for a stock.

        Args:
            symbol: Stock ticker symbol
            outputsize: 'compact' (last 100 days) or 'full' (20+ years)
        """
        params = {
            "function": "TIME_SERIES_DAILY",
            "symbol": symbol,
            "outputsize": outputsize
        }

        data = self._make_request(params)
        time_series = data.get("Time Series (Daily)", {})

        prices = []
        for date_str, values in time_series.items():
            prices.append({
                "date": datetime.strptime(date_str, "%Y-%m-%d").date(),
                "open": float(values["1. open"]),
                "high": float(values["2. high"]),
                "low": float(values["3. low"]),
                "close": float(values["4. close"]),
                "volume": int(values["5. volume"])
            })

        return sorted(prices, key=lambda x: x["date"], reverse=True)

    def get_company_overview(self, symbol: str) -> Optional[Dict[str, Any]]:
        """Get company overview including sector, industry, etc."""
        params = {
            "function": "OVERVIEW",
            "symbol": symbol
        }

        data = self._make_request(params)

        if not data or "Symbol" not in data:
            return None

        return {
            "symbol": data.get("Symbol"),
            "name": data.get("Name"),
            "sector": data.get("Sector"),
            "industry": data.get("Industry"),
            "description": data.get("Description"),
            "market_cap": data.get("MarketCapitalization"),
            "pe_ratio": data.get("PERatio")
        }

    def get_news_sentiment(self,
                          tickers: Optional[str] = None,
                          topics: Optional[str] = None,
                          time_from: Optional[str] = None,
                          limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get news and sentiment data.

        Args:
            tickers: Comma-separated list of stock symbols (e.g., "AAPL,MSFT")
            topics: Topics to filter by (e.g., "technology")
            time_from: Start time in YYYYMMDDTHHMM format
            limit: Number of articles to return (max 1000)
        """
        params = {
            "function": "NEWS_SENTIMENT",
            "limit": str(limit)
        }

        if tickers:
            params["tickers"] = tickers
        if topics:
            params["topics"] = topics
        if time_from:
            params["time_from"] = time_from

        data = self._make_request(params)
        feed = data.get("feed", [])

        articles = []
        for item in feed:
            # Extract ticker-specific sentiment if available
            ticker_sentiment = {}
            if tickers and "ticker_sentiment" in item:
                for ts in item["ticker_sentiment"]:
                    ticker = ts.get("ticker")
                    if ticker:
                        ticker_sentiment[ticker] = {
                            "relevance_score": float(ts.get("relevance_score", 0)),
                            "ticker_sentiment_score": float(ts.get("ticker_sentiment_score", 0)),
                            "ticker_sentiment_label": ts.get("ticker_sentiment_label")
                        }

            articles.append({
                "title": item.get("title"),
                "url": item.get("url"),
                "published_at": datetime.strptime(item.get("time_published"), "%Y%m%dT%H%M%S") if item.get("time_published") else None,
                "source": item.get("source"),
                "summary": item.get("summary"),
                "overall_sentiment_score": float(item.get("overall_sentiment_score", 0)),
                "overall_sentiment_label": item.get("overall_sentiment_label"),
                "ticker_sentiment": ticker_sentiment,
                "topics": [t.get("topic") for t in item.get("topics", [])]
            })

        return articles

    def search_symbol(self, keywords: str) -> List[Dict[str, str]]:
        """Search for stock symbols by company name or keywords."""
        params = {
            "function": "SYMBOL_SEARCH",
            "keywords": keywords
        }

        data = self._make_request(params)
        matches = data.get("bestMatches", [])

        return [{
            "symbol": match.get("1. symbol"),
            "name": match.get("2. name"),
            "type": match.get("3. type"),
            "region": match.get("4. region"),
            "currency": match.get("8. currency")
        } for match in matches]

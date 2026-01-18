"""
Serper Google Search API service for enhanced financial research.

Provides access to Google Search results for:
- Company news and updates
- SEC filings
- Analyst reports
- Competitor analysis
"""

import requests
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import logging
import time
from functools import lru_cache

logger = logging.getLogger(__name__)


class SerperService:
    """
    Service for interacting with Serper Google Search API.

    Features:
    - Financial news search
    - SEC filings lookup
    - Analyst reports discovery
    - Rate limiting and caching
    """

    def __init__(self, api_key: str, cache_ttl: int = 3600):
        """
        Initialize Serper service.

        Args:
            api_key: Serper API key
            cache_ttl: Cache TTL in seconds (default 1 hour)
        """
        self.api_key = api_key
        self.base_url = "https://google.serper.dev"
        self.cache_ttl = cache_ttl
        self._cache: Dict[str, Dict[str, Any]] = {}
        self._last_request_time = 0
        self._min_request_interval = 0.5  # 500ms between requests

    def _rate_limit(self):
        """Enforce rate limiting between requests."""
        elapsed = time.time() - self._last_request_time
        if elapsed < self._min_request_interval:
            time.sleep(self._min_request_interval - elapsed)
        self._last_request_time = time.time()

    def _get_cached(self, cache_key: str) -> Optional[Dict[str, Any]]:
        """Get cached result if valid."""
        if cache_key in self._cache:
            entry = self._cache[cache_key]
            if time.time() < entry["expires_at"]:
                logger.debug(f"Cache hit for: {cache_key}")
                return entry["data"]
            else:
                del self._cache[cache_key]
        return None

    def _set_cached(self, cache_key: str, data: Dict[str, Any]):
        """Cache result with TTL."""
        self._cache[cache_key] = {
            "data": data,
            "expires_at": time.time() + self.cache_ttl
        }

    def _make_request(
        self,
        endpoint: str,
        payload: Dict[str, Any],
        use_cache: bool = True
    ) -> Dict[str, Any]:
        """
        Make request to Serper API.

        Args:
            endpoint: API endpoint (e.g., /search, /news)
            payload: Request payload
            use_cache: Whether to use caching

        Returns:
            API response data
        """
        if not self.api_key:
            raise ValueError("Serper API key not configured")

        # Check cache
        cache_key = f"{endpoint}:{str(payload)}"
        if use_cache:
            cached = self._get_cached(cache_key)
            if cached:
                return cached

        # Rate limit
        self._rate_limit()

        headers = {
            "X-API-KEY": self.api_key,
            "Content-Type": "application/json"
        }

        try:
            response = requests.post(
                f"{self.base_url}{endpoint}",
                headers=headers,
                json=payload,
                timeout=30
            )

            if response.status_code == 401:
                raise ValueError("Invalid Serper API key")
            elif response.status_code == 429:
                raise Exception("Serper API rate limit exceeded")
            elif response.status_code != 200:
                raise Exception(f"Serper API error: {response.text}")

            data = response.json()

            # Cache result
            if use_cache:
                self._set_cached(cache_key, data)

            return data

        except requests.exceptions.RequestException as e:
            logger.error(f"Serper API request failed: {e}")
            raise

    def search(
        self,
        query: str,
        num_results: int = 10,
        search_type: str = "search"
    ) -> List[Dict[str, Any]]:
        """
        Perform a general Google search.

        Args:
            query: Search query
            num_results: Number of results to return
            search_type: Type of search (search, news, images)

        Returns:
            List of search results
        """
        payload = {
            "q": query,
            "num": min(num_results, 100)
        }

        endpoint = f"/{search_type}"
        data = self._make_request(endpoint, payload)

        if search_type == "news":
            return data.get("news", [])
        else:
            return data.get("organic", [])

    def search_stock_news(
        self,
        symbol: str,
        company_name: Optional[str] = None,
        days_back: int = 7
    ) -> List[Dict[str, Any]]:
        """
        Search for recent news about a stock.

        Args:
            symbol: Stock ticker symbol
            company_name: Optional company name for better results
            days_back: How many days back to search

        Returns:
            List of news articles
        """
        # Build search query
        if company_name:
            query = f"{company_name} {symbol} stock news"
        else:
            query = f"{symbol} stock news"

        results = self.search(query, num_results=20, search_type="news")

        # Filter and format results
        formatted = []
        for item in results:
            formatted.append({
                "title": item.get("title", ""),
                "link": item.get("link", ""),
                "snippet": item.get("snippet", ""),
                "source": item.get("source", ""),
                "date": item.get("date", ""),
                "symbol": symbol,
                "search_type": "stock_news"
            })

        logger.info(f"Found {len(formatted)} news articles for {symbol}")
        return formatted

    def search_sec_filings(
        self,
        symbol: str,
        company_name: Optional[str] = None,
        filing_type: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for SEC filings for a company.

        Args:
            symbol: Stock ticker symbol
            company_name: Optional company name
            filing_type: Optional specific filing type (10-K, 10-Q, 8-K)

        Returns:
            List of SEC filing results
        """
        # Build search query
        company = company_name or symbol
        if filing_type:
            query = f"site:sec.gov {company} {filing_type} filing"
        else:
            query = f"site:sec.gov {company} SEC filing 10-K 10-Q"

        results = self.search(query, num_results=20)

        # Format results
        formatted = []
        for item in results:
            link = item.get("link", "")
            # Only include SEC.gov links
            if "sec.gov" in link:
                formatted.append({
                    "title": item.get("title", ""),
                    "link": link,
                    "snippet": item.get("snippet", ""),
                    "symbol": symbol,
                    "search_type": "sec_filing",
                    "filing_type": self._detect_filing_type(item.get("title", ""))
                })

        logger.info(f"Found {len(formatted)} SEC filings for {symbol}")
        return formatted

    def search_analyst_reports(
        self,
        symbol: str,
        company_name: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for analyst reports and ratings.

        Args:
            symbol: Stock ticker symbol
            company_name: Optional company name

        Returns:
            List of analyst report results
        """
        company = company_name or symbol
        query = f"{company} {symbol} analyst rating price target upgrade downgrade"

        results = self.search(query, num_results=20, search_type="news")

        # Filter for analyst-related content
        keywords = ["analyst", "rating", "upgrade", "downgrade", "price target", "buy", "sell", "hold"]
        formatted = []

        for item in results:
            title = item.get("title", "").lower()
            snippet = item.get("snippet", "").lower()

            # Check if content is analyst-related
            if any(kw in title or kw in snippet for kw in keywords):
                formatted.append({
                    "title": item.get("title", ""),
                    "link": item.get("link", ""),
                    "snippet": item.get("snippet", ""),
                    "source": item.get("source", ""),
                    "date": item.get("date", ""),
                    "symbol": symbol,
                    "search_type": "analyst_report"
                })

        logger.info(f"Found {len(formatted)} analyst reports for {symbol}")
        return formatted

    def search_competitors(
        self,
        symbol: str,
        company_name: str,
        sector: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for competitor information.

        Args:
            symbol: Stock ticker symbol
            company_name: Company name
            sector: Optional sector for better filtering

        Returns:
            List of competitor-related results
        """
        if sector:
            query = f"{company_name} competitors {sector} industry comparison"
        else:
            query = f"{company_name} competitors market share comparison"

        results = self.search(query, num_results=15)

        formatted = []
        for item in results:
            formatted.append({
                "title": item.get("title", ""),
                "link": item.get("link", ""),
                "snippet": item.get("snippet", ""),
                "symbol": symbol,
                "search_type": "competitor_analysis"
            })

        logger.info(f"Found {len(formatted)} competitor results for {symbol}")
        return formatted

    def comprehensive_research(
        self,
        symbol: str,
        company_name: Optional[str] = None
    ) -> Dict[str, List[Dict[str, Any]]]:
        """
        Perform comprehensive research on a stock.

        Combines multiple search types for complete research.

        Args:
            symbol: Stock ticker symbol
            company_name: Optional company name

        Returns:
            Dict with results from all search types
        """
        results = {
            "news": self.search_stock_news(symbol, company_name),
            "sec_filings": self.search_sec_filings(symbol, company_name),
            "analyst_reports": self.search_analyst_reports(symbol, company_name),
            "symbol": symbol,
            "company_name": company_name,
            "timestamp": datetime.now().isoformat()
        }

        return results

    def _detect_filing_type(self, title: str) -> str:
        """Detect SEC filing type from title."""
        title_lower = title.lower()
        if "10-k" in title_lower:
            return "10-K"
        elif "10-q" in title_lower:
            return "10-Q"
        elif "8-k" in title_lower:
            return "8-K"
        elif "def 14a" in title_lower or "proxy" in title_lower:
            return "DEF 14A"
        elif "s-1" in title_lower:
            return "S-1"
        else:
            return "Other"

    def clear_cache(self):
        """Clear all cached results."""
        self._cache.clear()
        logger.info("Serper cache cleared")

    def health_check(self) -> bool:
        """
        Check if Serper API is accessible.

        Returns:
            True if API is healthy
        """
        try:
            self.search("test", num_results=1)
            return True
        except Exception as e:
            logger.warning(f"Serper health check failed: {e}")
            return False


# Singleton instance
_serper_service: Optional[SerperService] = None


def get_serper_service(api_key: str = None) -> SerperService:
    """
    Get or create Serper service instance.

    Args:
        api_key: Optional API key

    Returns:
        SerperService instance
    """
    global _serper_service

    if api_key:
        _serper_service = SerperService(api_key)
    elif _serper_service is None:
        from backend.app.core.config import settings
        if hasattr(settings, 'SERPER_API_KEY') and settings.SERPER_API_KEY:
            _serper_service = SerperService(settings.SERPER_API_KEY)
        else:
            raise ValueError("SERPER_API_KEY not configured")

    return _serper_service

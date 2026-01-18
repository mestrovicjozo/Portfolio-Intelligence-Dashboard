"""
Unified price service that orchestrates caching and batch fetching.

Provides a single interface for getting stock prices efficiently.
"""

from typing import List, Dict, Any, Optional
from datetime import date
import logging

from backend.app.services.price_cache import price_cache
from backend.app.services.batch_price_service import batch_price_service

logger = logging.getLogger(__name__)


class UnifiedPriceService:
    """
    Unified service for stock price operations.

    Flow:
    1. Check cache for requested symbols
    2. Batch fetch missing symbols
    3. Update cache with new data
    4. Return combined results
    """

    def __init__(self, cache_ttl: int = 60):
        """
        Initialize unified price service.

        Args:
            cache_ttl: Cache TTL in seconds (default 60)
        """
        self._cache = price_cache
        self._batch_service = batch_price_service
        self._cache.ttl = cache_ttl

    def get_current_prices(
        self,
        symbols: List[str],
        force_refresh: bool = False
    ) -> Dict[str, Dict[str, Any]]:
        """
        Get current prices for multiple symbols with caching.

        Args:
            symbols: List of stock ticker symbols
            force_refresh: If True, bypass cache and fetch fresh data

        Returns:
            Dict mapping symbols to their current price data
        """
        if not symbols:
            return {}

        symbols = [s.upper() for s in symbols]
        result = {}
        symbols_to_fetch = []

        # Step 1: Check cache (unless force refresh)
        if not force_refresh:
            cached = self._cache.get_many(symbols)
            for symbol, data in cached.items():
                if data is not None:
                    result[symbol] = data
                else:
                    symbols_to_fetch.append(symbol)

            logger.debug(f"Cache hit: {len(result)}, Cache miss: {len(symbols_to_fetch)}")
        else:
            symbols_to_fetch = symbols
            logger.debug(f"Force refresh: fetching all {len(symbols)} symbols")

        # Step 2: Batch fetch missing symbols
        if symbols_to_fetch:
            fresh_data = self._batch_service.fetch_current_prices(symbols_to_fetch)

            # Step 3: Update cache and result
            if fresh_data:
                self._cache.set_many(fresh_data)
                result.update(fresh_data)

        return result

    def get_current_price(
        self,
        symbol: str,
        force_refresh: bool = False
    ) -> Optional[Dict[str, Any]]:
        """
        Get current price for a single symbol.

        Args:
            symbol: Stock ticker symbol
            force_refresh: If True, bypass cache

        Returns:
            Price data dict or None if not found
        """
        prices = self.get_current_prices([symbol], force_refresh)
        return prices.get(symbol.upper())

    def get_historical_prices(
        self,
        symbols: List[str],
        days: int = 100,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None
    ) -> Dict[str, List[Dict[str, Any]]]:
        """
        Get historical prices for multiple symbols.

        Note: Historical data is not cached (too large).

        Args:
            symbols: List of stock ticker symbols
            days: Number of days of history
            start_date: Optional start date
            end_date: Optional end date

        Returns:
            Dict mapping symbols to list of OHLCV records
        """
        if not symbols:
            return {}

        return self._batch_service.fetch_historical_prices(
            symbols=symbols,
            days=days,
            start_date=start_date,
            end_date=end_date
        )

    def get_historical_price(
        self,
        symbol: str,
        days: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Get historical prices for a single symbol.

        Args:
            symbol: Stock ticker symbol
            days: Number of days of history

        Returns:
            List of OHLCV records
        """
        result = self.get_historical_prices([symbol], days)
        return result.get(symbol.upper(), [])

    def invalidate_cache(self, symbols: Optional[List[str]] = None) -> int:
        """
        Invalidate cache for specific symbols or all.

        Args:
            symbols: Optional list of symbols to invalidate.
                    If None, clears entire cache.

        Returns:
            Number of entries cleared
        """
        if symbols is None:
            return self._cache.clear()
        else:
            count = 0
            for symbol in symbols:
                if self._cache.delete(symbol):
                    count += 1
            return count

    def cache_stats(self) -> Dict[str, Any]:
        """Get cache statistics."""
        return self._cache.stats()

    def cleanup_cache(self) -> int:
        """Remove expired cache entries."""
        return self._cache.cleanup_expired()


# Global unified price service instance
unified_price_service = UnifiedPriceService(cache_ttl=60)

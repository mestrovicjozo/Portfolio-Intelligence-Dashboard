"""
In-memory price cache with TTL support.

Provides fast access to recently fetched stock prices without hitting external APIs.
"""

import time
import threading
from typing import Dict, Optional, Any
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)


@dataclass
class CacheEntry:
    """Single cache entry with value and expiration time."""
    value: Any
    expires_at: float


class PriceCache:
    """
    Thread-safe in-memory cache for stock prices with TTL support.

    Features:
    - Configurable TTL (default 60 seconds)
    - Thread-safe operations
    - Automatic expiration on read
    - Bulk operations support
    """

    def __init__(self, ttl_seconds: int = 60):
        """
        Initialize price cache.

        Args:
            ttl_seconds: Time-to-live for cache entries in seconds
        """
        self._cache: Dict[str, CacheEntry] = {}
        self._lock = threading.RLock()
        self._ttl = ttl_seconds

    @property
    def ttl(self) -> int:
        """Get current TTL setting."""
        return self._ttl

    @ttl.setter
    def ttl(self, value: int) -> None:
        """Set TTL for new cache entries."""
        self._ttl = max(1, value)  # Minimum 1 second

    def get(self, symbol: str) -> Optional[Dict[str, Any]]:
        """
        Get cached price data for a symbol.

        Args:
            symbol: Stock ticker symbol (case-insensitive)

        Returns:
            Cached price data if valid, None if expired or not found
        """
        key = symbol.upper()

        with self._lock:
            entry = self._cache.get(key)

            if entry is None:
                return None

            # Check if expired
            if time.time() > entry.expires_at:
                del self._cache[key]
                logger.debug(f"Cache entry expired for {key}")
                return None

            return entry.value

    def set(self, symbol: str, data: Dict[str, Any], ttl: Optional[int] = None) -> None:
        """
        Cache price data for a symbol.

        Args:
            symbol: Stock ticker symbol
            data: Price data to cache
            ttl: Optional custom TTL (uses default if not specified)
        """
        key = symbol.upper()
        expires_at = time.time() + (ttl if ttl is not None else self._ttl)

        with self._lock:
            self._cache[key] = CacheEntry(value=data, expires_at=expires_at)

        logger.debug(f"Cached price data for {key}, expires in {ttl or self._ttl}s")

    def get_many(self, symbols: list) -> Dict[str, Optional[Dict[str, Any]]]:
        """
        Get cached data for multiple symbols.

        Args:
            symbols: List of stock ticker symbols

        Returns:
            Dict mapping symbols to their cached data (None if not cached/expired)
        """
        result = {}

        for symbol in symbols:
            result[symbol.upper()] = self.get(symbol)

        return result

    def set_many(self, data: Dict[str, Dict[str, Any]], ttl: Optional[int] = None) -> None:
        """
        Cache price data for multiple symbols.

        Args:
            data: Dict mapping symbols to their price data
            ttl: Optional custom TTL
        """
        for symbol, price_data in data.items():
            self.set(symbol, price_data, ttl)

        logger.debug(f"Cached price data for {len(data)} symbols")

    def delete(self, symbol: str) -> bool:
        """
        Remove a symbol from cache.

        Args:
            symbol: Stock ticker symbol

        Returns:
            True if entry was deleted, False if not found
        """
        key = symbol.upper()

        with self._lock:
            if key in self._cache:
                del self._cache[key]
                return True
            return False

    def clear(self) -> int:
        """
        Clear all cache entries.

        Returns:
            Number of entries cleared
        """
        with self._lock:
            count = len(self._cache)
            self._cache.clear()

        logger.info(f"Cleared {count} cache entries")
        return count

    def cleanup_expired(self) -> int:
        """
        Remove all expired entries from cache.

        Returns:
            Number of entries removed
        """
        now = time.time()
        removed = 0

        with self._lock:
            expired_keys = [
                key for key, entry in self._cache.items()
                if now > entry.expires_at
            ]

            for key in expired_keys:
                del self._cache[key]
                removed += 1

        if removed > 0:
            logger.debug(f"Cleaned up {removed} expired cache entries")

        return removed

    def stats(self) -> Dict[str, Any]:
        """
        Get cache statistics.

        Returns:
            Dict with cache stats (size, ttl, etc.)
        """
        with self._lock:
            now = time.time()
            valid_entries = sum(
                1 for entry in self._cache.values()
                if now <= entry.expires_at
            )

            return {
                "total_entries": len(self._cache),
                "valid_entries": valid_entries,
                "expired_entries": len(self._cache) - valid_entries,
                "ttl_seconds": self._ttl
            }

    def __contains__(self, symbol: str) -> bool:
        """Check if symbol is in cache and not expired."""
        return self.get(symbol) is not None

    def __len__(self) -> int:
        """Get number of entries (including expired)."""
        return len(self._cache)


# Global price cache instance
price_cache = PriceCache(ttl_seconds=60)

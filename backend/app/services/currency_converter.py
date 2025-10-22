"""
Currency conversion service for converting USD prices to EUR.
Uses real-time exchange rates from Yahoo Finance.
"""

import yfinance as yf
from datetime import datetime, timedelta
from typing import Optional
import logging

logger = logging.getLogger(__name__)


class CurrencyConverter:
    """Service for converting currencies using real-time exchange rates."""

    def __init__(self):
        self._cached_rate: Optional[float] = None
        self._cache_timestamp: Optional[datetime] = None
        self._cache_duration = timedelta(hours=1)  # Cache rate for 1 hour

    def get_usd_to_eur_rate(self) -> float:
        """
        Get current USD to EUR exchange rate.

        Returns:
            Exchange rate (how many EUR for 1 USD)
        """
        # Check if we have a valid cached rate
        if self._cached_rate and self._cache_timestamp:
            if datetime.now() - self._cache_timestamp < self._cache_duration:
                logger.debug(f"Using cached USD/EUR rate: {self._cached_rate}")
                return self._cached_rate

        try:
            # Fetch EUR/USD exchange rate from Yahoo Finance with timeout
            eurusd = yf.Ticker("EURUSD=X")
            data = eurusd.history(period="1d", timeout=2)  # 2 second timeout

            if not data.empty and len(data) > 0:
                # Get the most recent close price (EUR/USD rate)
                rate = float(data['Close'].iloc[-1])

                # Cache the rate
                self._cached_rate = rate
                self._cache_timestamp = datetime.now()

                logger.info(f"Fetched fresh USD/EUR exchange rate: {rate}")
                return rate
            else:
                logger.warning("No exchange rate data returned, using fallback rate")
                # Cache the fallback so we don't keep retrying
                fallback = self._get_fallback_rate()
                self._cached_rate = fallback
                self._cache_timestamp = datetime.now()
                return fallback

        except Exception as e:
            logger.warning(f"Error fetching USD/EUR rate (using fallback): {e}")
            # Cache the fallback to prevent repeated failures
            fallback = self._get_fallback_rate()
            self._cached_rate = fallback
            self._cache_timestamp = datetime.now()
            return fallback

    def _get_fallback_rate(self) -> float:
        """
        Get fallback exchange rate if API fails.
        Uses cached rate or a conservative default.
        """
        if self._cached_rate:
            logger.warning(f"Using cached rate from {self._cache_timestamp}")
            return self._cached_rate

        # Conservative fallback rate (approximate average)
        fallback = 0.92
        logger.warning(f"Using fallback USD/EUR rate: {fallback}")
        return fallback

    def convert_usd_to_eur(self, usd_amount: float) -> float:
        """
        Convert USD amount to EUR.

        Args:
            usd_amount: Amount in USD

        Returns:
            Amount in EUR
        """
        if usd_amount is None or usd_amount == 0:
            return 0.0

        rate = self.get_usd_to_eur_rate()
        eur_amount = usd_amount * rate

        return round(eur_amount, 2)

    def convert_price_dict(self, price_data: dict) -> dict:
        """
        Convert all price fields in a dictionary from USD to EUR.

        Args:
            price_data: Dictionary with price fields (open, high, low, close, price)

        Returns:
            Dictionary with converted EUR prices
        """
        converted = price_data.copy()

        # Convert price fields
        price_fields = ['open', 'high', 'low', 'close', 'price', 'change']

        for field in price_fields:
            if field in converted and converted[field] is not None:
                converted[field] = self.convert_usd_to_eur(converted[field])

        return converted

    def clear_cache(self):
        """Clear the cached exchange rate."""
        self._cached_rate = None
        self._cache_timestamp = None
        logger.info("Currency conversion cache cleared")


# Global instance
currency_converter = CurrencyConverter()

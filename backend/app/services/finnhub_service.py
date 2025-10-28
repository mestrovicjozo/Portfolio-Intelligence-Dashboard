"""
Finnhub API service for fetching stock data.
"""

import finnhub
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import logging
from backend.app.services.currency_converter import currency_converter

logger = logging.getLogger(__name__)


class FinnhubService:
    """Service for interacting with Finnhub API."""

    def __init__(self, api_key: str):
        """Initialize Finnhub client."""
        self.client = finnhub.Client(api_key=api_key)
        logger.info("Finnhub service initialized")

    def get_quote(self, symbol: str) -> Optional[Dict[str, Any]]:
        """
        Get current quote for a stock symbol (prices converted to EUR).

        Args:
            symbol: Stock ticker symbol (e.g., 'AAPL')

        Returns:
            Dictionary with quote data or None if failed
        """
        try:
            quote = self.client.quote(symbol)

            if not quote or quote.get('c') == 0:
                logger.warning(f"No quote data returned for {symbol}")
                return None

            # Finnhub returns: c (current price), h (high), l (low), o (open), pc (previous close)
            quote_data = {
                "symbol": symbol,
                "price": float(quote.get("c", 0)),  # current price
                "change": float(quote.get("d", 0)),  # change
                "change_percent": float(quote.get("dp", 0)),  # change percent
                "high": float(quote.get("h", 0)),
                "low": float(quote.get("l", 0)),
                "open": float(quote.get("o", 0)),
                "previous_close": float(quote.get("pc", 0)),
                "latest_trading_day": datetime.now().strftime("%Y-%m-%d")
            }

            # Convert USD prices to EUR
            quote_data = currency_converter.convert_price_dict(quote_data)

            logger.info(f"Finnhub: Retrieved quote for {symbol}: €{quote_data['price']}")
            return quote_data

        except Exception as e:
            logger.error(f"Finnhub quote error for {symbol}: {e}")
            return None

    def get_daily_prices(self, symbol: str, days: int = 100) -> List[Dict[str, Any]]:
        """
        Get daily price data for a stock (prices converted to EUR).

        Args:
            symbol: Stock ticker symbol
            days: Number of days of historical data (default 100)

        Returns:
            List of price dictionaries with date, open, high, low, close, volume
        """
        try:
            # Calculate timestamps
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)

            start_timestamp = int(start_date.timestamp())
            end_timestamp = int(end_date.timestamp())

            # Get candle data from Finnhub
            candles = self.client.stock_candles(symbol, 'D', start_timestamp, end_timestamp)

            if not candles or candles.get('s') != 'ok':
                logger.warning(f"No candle data returned for {symbol}")
                return []

            # Parse the candle data
            prices = []
            timestamps = candles.get('t', [])
            opens = candles.get('o', [])
            highs = candles.get('h', [])
            lows = candles.get('l', [])
            closes = candles.get('c', [])
            volumes = candles.get('v', [])

            for i in range(len(timestamps)):
                price_data = {
                    "date": datetime.fromtimestamp(timestamps[i]).date(),
                    "open": float(opens[i]),
                    "high": float(highs[i]),
                    "low": float(lows[i]),
                    "close": float(closes[i]),
                    "volume": int(volumes[i])
                }

                # Convert USD prices to EUR
                price_data = currency_converter.convert_price_dict(price_data)
                prices.append(price_data)

            logger.info(f"Finnhub: Retrieved {len(prices)} price records for {symbol} (converted to EUR)")
            return sorted(prices, key=lambda x: x["date"], reverse=True)

        except Exception as e:
            logger.error(f"Finnhub price error for {symbol}: {e}")
            return []

    def get_company_profile(self, symbol: str) -> Optional[Dict[str, Any]]:
        """
        Get company profile/overview.

        Args:
            symbol: Stock ticker symbol

        Returns:
            Dictionary with company info or None if failed
        """
        try:
            profile = self.client.company_profile2(symbol=symbol)

            if not profile:
                logger.warning(f"No profile data returned for {symbol}")
                return None

            return {
                "symbol": symbol,
                "name": profile.get("name", symbol),
                "sector": profile.get("finnhubIndustry", "Unknown"),
                "industry": profile.get("finnhubIndustry", "Unknown"),
                "description": profile.get("description", ""),
                "market_cap": profile.get("marketCapitalization"),
                "logo": profile.get("logo")
            }

        except Exception as e:
            logger.error(f"Finnhub profile error for {symbol}: {e}")
            return None

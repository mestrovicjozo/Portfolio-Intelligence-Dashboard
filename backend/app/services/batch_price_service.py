"""
Batch price fetching service using yfinance.

Efficiently fetches price data for multiple stocks in a single API call.
"""

import yfinance as yf
import pandas as pd
from typing import List, Dict, Any, Optional
from datetime import datetime, date, timedelta
import logging
from concurrent.futures import ThreadPoolExecutor
import numpy as np

logger = logging.getLogger(__name__)


class BatchPriceService:
    """
    Service for batch fetching stock prices using yfinance.

    Advantages over sequential fetching:
    - Single network call for multiple symbols
    - Built-in rate limiting
    - Automatic retry handling
    - Thread-safe concurrent downloads
    """

    def __init__(self, max_concurrent: int = 10):
        """
        Initialize batch price service.

        Args:
            max_concurrent: Maximum concurrent download threads
        """
        self._max_concurrent = max_concurrent

    def fetch_current_prices(self, symbols: List[str]) -> Dict[str, Dict[str, Any]]:
        """
        Fetch current prices for multiple symbols in batch.

        Args:
            symbols: List of stock ticker symbols

        Returns:
            Dict mapping symbols to their current price data
        """
        if not symbols:
            return {}

        # Join symbols with spaces for yfinance batch download
        symbols_str = " ".join(s.upper() for s in symbols)

        try:
            logger.info(f"Batch fetching current prices for {len(symbols)} symbols")

            # Download 2 days of data to get current price and change
            data = yf.download(
                symbols_str,
                period="2d",
                group_by='ticker',
                threads=True,
                progress=False
            )

            return self._parse_batch_data(data, symbols)

        except Exception as e:
            logger.error(f"Error in batch price fetch: {e}")
            return {}

    def fetch_historical_prices(
        self,
        symbols: List[str],
        days: int = 100,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None
    ) -> Dict[str, List[Dict[str, Any]]]:
        """
        Fetch historical prices for multiple symbols in batch.

        Args:
            symbols: List of stock ticker symbols
            days: Number of days of history (used if start_date not specified)
            start_date: Optional start date
            end_date: Optional end date (defaults to today)

        Returns:
            Dict mapping symbols to list of OHLCV price records
        """
        if not symbols:
            return {}

        symbols_str = " ".join(s.upper() for s in symbols)

        try:
            logger.info(f"Batch fetching {days} days of historical prices for {len(symbols)} symbols")

            if start_date and end_date:
                data = yf.download(
                    symbols_str,
                    start=start_date,
                    end=end_date,
                    group_by='ticker',
                    threads=True,
                    progress=False
                )
            else:
                # Use period for relative date range
                period = self._days_to_period(days)
                data = yf.download(
                    symbols_str,
                    period=period,
                    group_by='ticker',
                    threads=True,
                    progress=False
                )

            return self._parse_historical_data(data, symbols)

        except Exception as e:
            logger.error(f"Error in batch historical fetch: {e}")
            return {}

    def _days_to_period(self, days: int) -> str:
        """Convert number of days to yfinance period string."""
        if days <= 5:
            return "5d"
        elif days <= 30:
            return "1mo"
        elif days <= 90:
            return "3mo"
        elif days <= 180:
            return "6mo"
        elif days <= 365:
            return "1y"
        elif days <= 730:
            return "2y"
        else:
            return "5y"

    def _parse_batch_data(
        self,
        data: pd.DataFrame,
        symbols: List[str]
    ) -> Dict[str, Dict[str, Any]]:
        """
        Parse batch download data into price dictionaries.

        Args:
            data: DataFrame from yfinance batch download
            symbols: List of requested symbols

        Returns:
            Dict mapping symbols to current price data
        """
        result = {}

        if data.empty:
            logger.warning("Empty data returned from yfinance")
            return result

        # Handle single vs multiple symbols (different DataFrame structure)
        is_multi_symbol = isinstance(data.columns, pd.MultiIndex)

        for symbol in symbols:
            symbol_upper = symbol.upper()

            try:
                if is_multi_symbol:
                    # Multi-symbol: columns are (symbol, field)
                    if symbol_upper not in data.columns.get_level_values(0):
                        logger.warning(f"No data for symbol {symbol_upper}")
                        continue
                    symbol_data = data[symbol_upper]
                else:
                    # Single symbol: columns are just fields
                    symbol_data = data

                if symbol_data.empty or symbol_data.dropna(how='all').empty:
                    continue

                # Get latest row
                latest = symbol_data.iloc[-1]

                # Get previous row for change calculation
                prev = symbol_data.iloc[-2] if len(symbol_data) >= 2 else None

                current_price = self._safe_float(latest.get('Close'))
                if current_price is None:
                    continue

                price_data = {
                    "symbol": symbol_upper,
                    "current_price": current_price,
                    "open": self._safe_float(latest.get('Open')),
                    "high": self._safe_float(latest.get('High')),
                    "low": self._safe_float(latest.get('Low')),
                    "volume": self._safe_int(latest.get('Volume')),
                    "timestamp": datetime.now().isoformat()
                }

                # Calculate change if we have previous day
                if prev is not None:
                    prev_close = self._safe_float(prev.get('Close'))
                    if prev_close and prev_close > 0:
                        change = current_price - prev_close
                        change_percent = (change / prev_close) * 100
                        price_data["price_change"] = round(change, 4)
                        price_data["price_change_percent"] = round(change_percent, 2)

                result[symbol_upper] = price_data

            except Exception as e:
                logger.error(f"Error parsing data for {symbol}: {e}")
                continue

        logger.info(f"Successfully parsed prices for {len(result)}/{len(symbols)} symbols")
        return result

    def _parse_historical_data(
        self,
        data: pd.DataFrame,
        symbols: List[str]
    ) -> Dict[str, List[Dict[str, Any]]]:
        """
        Parse batch download data into historical price lists.

        Args:
            data: DataFrame from yfinance batch download
            symbols: List of requested symbols

        Returns:
            Dict mapping symbols to list of OHLCV records
        """
        result = {}

        if data.empty:
            logger.warning("Empty data returned from yfinance")
            return result

        is_multi_symbol = isinstance(data.columns, pd.MultiIndex)

        for symbol in symbols:
            symbol_upper = symbol.upper()

            try:
                if is_multi_symbol:
                    if symbol_upper not in data.columns.get_level_values(0):
                        continue
                    symbol_data = data[symbol_upper]
                else:
                    symbol_data = data

                if symbol_data.empty:
                    continue

                # Drop rows with all NaN values
                symbol_data = symbol_data.dropna(how='all')

                prices = []
                for idx, row in symbol_data.iterrows():
                    close_price = self._safe_float(row.get('Close'))
                    if close_price is None:
                        continue

                    price_record = {
                        "date": idx.date() if hasattr(idx, 'date') else idx,
                        "open": self._safe_float(row.get('Open')),
                        "high": self._safe_float(row.get('High')),
                        "low": self._safe_float(row.get('Low')),
                        "close": close_price,
                        "volume": self._safe_int(row.get('Volume'))
                    }
                    prices.append(price_record)

                if prices:
                    # Sort by date descending (most recent first)
                    prices.sort(key=lambda x: x['date'], reverse=True)
                    result[symbol_upper] = prices
                    logger.debug(f"Parsed {len(prices)} price records for {symbol_upper}")

            except Exception as e:
                logger.error(f"Error parsing historical data for {symbol}: {e}")
                continue

        logger.info(f"Successfully parsed historical data for {len(result)}/{len(symbols)} symbols")
        return result

    def _safe_float(self, value) -> Optional[float]:
        """Safely convert value to float, handling NaN and None."""
        if value is None:
            return None
        try:
            if pd.isna(value) or np.isnan(value):
                return None
            return round(float(value), 4)
        except (TypeError, ValueError):
            return None

    def _safe_int(self, value) -> Optional[int]:
        """Safely convert value to int, handling NaN and None."""
        if value is None:
            return None
        try:
            if pd.isna(value) or np.isnan(value):
                return None
            return int(value)
        except (TypeError, ValueError):
            return None


# Global batch price service instance
batch_price_service = BatchPriceService()

"""
Custom Stock API service for fetching prices from actually-free-api.
"""

import requests
from typing import Dict, List, Optional, Any
from datetime import datetime
import logging
from backend.app.services.currency_converter import currency_converter

logger = logging.getLogger(__name__)


class CustomStockAPIService:
    """Service for fetching stock data from custom actually-free-api."""

    def __init__(self):
        self.base_url = "https://actually-free-api.vercel.app/api"
        self.stocks_cache = {}
        self.cache_timestamp = None
        logger.info("Custom Stock API service initialized")

    def _fetch_all_stocks(self) -> Dict[str, Dict[str, Any]]:
        """
        Fetch all stock data from the API and cache it.

        Returns:
            Dictionary mapping ticker symbols to stock data
        """
        try:
            response = requests.get(f"{self.base_url}/stocks", timeout=10)
            response.raise_for_status()

            data = response.json()
            stocks_data = data.get('data', [])

            # Create a lookup dictionary by ticker
            stocks_dict = {}
            for stock in stocks_data:
                ticker = stock.get('ticker')
                if ticker:
                    stocks_dict[ticker] = stock

            logger.info(f"Fetched {len(stocks_dict)} stocks from custom API")
            return stocks_dict

        except Exception as e:
            logger.error(f"Error fetching stocks from custom API: {e}")
            return {}

    def get_quote(self, symbol: str) -> Optional[Dict[str, Any]]:
        """
        Get current quote for a stock symbol (prices converted to EUR).

        Args:
            symbol: Stock ticker symbol (e.g., 'AAPL')

        Returns:
            Dictionary with quote data or None if failed
        """
        try:
            # Fetch all stocks (will be cached in real implementation)
            stocks = self._fetch_all_stocks()

            stock_data = stocks.get(symbol.upper())
            if not stock_data:
                logger.warning(f"No data found for {symbol} in custom API")
                return None

            # Extract price data (in USD)
            quote_data = {
                "symbol": symbol,
                "price": float(stock_data.get("price", 0)),
                "change": float(stock_data.get("change", 0)),
                "change_percent": float(stock_data.get("change_percent", 0)),
                "latest_trading_day": datetime.now().strftime("%Y-%m-%d")
            }

            # Convert USD prices to EUR
            quote_data = currency_converter.convert_price_dict(quote_data)

            logger.info(f"Custom API: Retrieved quote for {symbol}: €{quote_data['price']}")
            return quote_data

        except Exception as e:
            logger.error(f"Custom API quote error for {symbol}: {e}")
            return None

    def get_current_prices(self) -> Dict[str, float]:
        """
        Get current prices for all stocks in EUR.

        Returns:
            Dictionary mapping ticker symbols to EUR prices
        """
        try:
            stocks = self._fetch_all_stocks()
            prices = {}

            for ticker, data in stocks.items():
                price_usd = float(data.get("price", 0))
                if price_usd > 0:
                    price_eur = currency_converter.convert_usd_to_eur(price_usd)
                    prices[ticker] = price_eur

            logger.info(f"Retrieved {len(prices)} current prices from custom API")
            return prices

        except Exception as e:
            logger.error(f"Error fetching current prices: {e}")
            return {}

    def get_company_info(self, symbol: str) -> Optional[Dict[str, Any]]:
        """
        Get company info for a stock.

        Args:
            symbol: Stock ticker symbol

        Returns:
            Dictionary with company info or None if failed
        """
        try:
            stocks = self._fetch_all_stocks()
            stock_data = stocks.get(symbol.upper())

            if not stock_data:
                return None

            return {
                "symbol": symbol,
                "name": stock_data.get("company_name", symbol),
                "sector": "Unknown",  # API doesn't provide sector
                "industry": "Unknown"
            }

        except Exception as e:
            logger.error(f"Custom API company info error for {symbol}: {e}")
            return None

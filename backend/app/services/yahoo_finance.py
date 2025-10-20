import yfinance as yf
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import logging
from backend.app.services.currency_converter import currency_converter

logger = logging.getLogger(__name__)


class YahooFinanceService:
    """Service for interacting with Yahoo Finance API (via yfinance library)."""

    def get_quote(self, symbol: str) -> Optional[Dict[str, Any]]:
        """Get current quote for a stock symbol (prices converted to EUR)."""
        try:
            ticker = yf.Ticker(symbol)
            info = ticker.info

            if not info or 'currentPrice' not in info:
                return None

            # Prices are in USD, convert to EUR
            quote_data = {
                "symbol": symbol,
                "price": float(info.get("currentPrice", 0)),
                "change": float(info.get("regularMarketChange", 0)),
                "change_percent": str(info.get("regularMarketChangePercent", 0)),
                "volume": int(info.get("volume", 0)),
                "latest_trading_day": datetime.now().strftime("%Y-%m-%d")
            }

            # Convert USD prices to EUR
            quote_data = currency_converter.convert_price_dict(quote_data)

            return quote_data
        except Exception as e:
            logger.error(f"Yahoo Finance quote error for {symbol}: {e}")
            return None

    def get_daily_prices(self, symbol: str, days: int = 100) -> List[Dict[str, Any]]:
        """
        Get daily price data for a stock (prices converted to EUR).

        Args:
            symbol: Stock ticker symbol
            days: Number of days of historical data (default 100)
        """
        try:
            ticker = yf.Ticker(symbol)

            # Get historical data
            hist = ticker.history(period=f"{days}d")

            if hist.empty:
                logger.warning(f"No historical data returned for {symbol}")
                return []

            prices = []
            for date, row in hist.iterrows():
                # Prices are in USD, convert to EUR
                price_data = {
                    "date": date.date(),
                    "open": float(row["Open"]),
                    "high": float(row["High"]),
                    "low": float(row["Low"]),
                    "close": float(row["Close"]),
                    "volume": int(row["Volume"])
                }

                # Convert USD prices to EUR
                price_data = currency_converter.convert_price_dict(price_data)
                prices.append(price_data)

            logger.info(f"Yahoo Finance: Retrieved {len(prices)} price records for {symbol} (converted to EUR)")
            return sorted(prices, key=lambda x: x["date"], reverse=True)

        except Exception as e:
            logger.error(f"Yahoo Finance price error for {symbol}: {e}")
            return []

    def get_company_overview(self, symbol: str) -> Optional[Dict[str, Any]]:
        """Get company overview including sector, industry, etc."""
        try:
            ticker = yf.Ticker(symbol)
            info = ticker.info

            if not info or 'symbol' not in info:
                return None

            return {
                "symbol": info.get("symbol", symbol),
                "name": info.get("longName", symbol),
                "sector": info.get("sector", "Unknown"),
                "industry": info.get("industry", "Unknown"),
                "description": info.get("longBusinessSummary", ""),
                "market_cap": info.get("marketCap"),
                "pe_ratio": info.get("trailingPE")
            }
        except Exception as e:
            logger.error(f"Yahoo Finance company overview error for {symbol}: {e}")
            return None

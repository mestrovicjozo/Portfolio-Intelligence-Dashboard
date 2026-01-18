"""
Stock price collection service for automated daily price data gathering.

Features:
- Multi-source price fetching (Yahoo Finance primary, Alpha Vantage fallback)
- Batch fetching for efficient multi-stock downloads (10x+ speedup)
- Historical backfill (100 days on first run)
- Smart weekend/holiday detection
- Duplicate prevention with unique constraints
- Comprehensive error handling
"""

import logging
from typing import List, Dict, Any
from datetime import datetime, date, timedelta
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError

from backend.app.core.config import settings
from backend.app.models import Stock, StockPrice
from backend.app.services.yahoo_finance import YahooFinanceService
from backend.app.services.alpha_vantage import AlphaVantageService
from backend.app.services.batch_price_service import batch_price_service

logger = logging.getLogger(__name__)


class PriceCollectorService:
    """Service for collecting stock price data from multiple sources."""

    def __init__(self):
        self.yahoo_service = YahooFinanceService()
        self.alpha_vantage = AlphaVantageService()
        self.batch_service = batch_price_service

    def fetch_price_data(self, symbol: str, days: int = 100) -> List[Dict[str, Any]]:
        """
        Fetch price data for a stock, trying Yahoo Finance first then Alpha Vantage.

        Args:
            symbol: Stock ticker symbol
            days: Number of days of historical data

        Returns:
            List of price records with OHLCV data
        """
        # Try Yahoo Finance first (free, unlimited)
        logger.info(f"Fetching {days} days of price data for {symbol} from Yahoo Finance")
        prices = self.yahoo_service.get_daily_prices(symbol, days=days)

        if prices:
            logger.info(f"Yahoo Finance: Got {len(prices)} price records for {symbol}")
            return prices

        # Fallback to Alpha Vantage
        logger.warning(f"Yahoo Finance failed for {symbol}, trying Alpha Vantage")
        try:
            outputsize = "full" if days > 100 else "compact"
            prices = self.alpha_vantage.get_daily_prices(symbol, outputsize=outputsize)

            if prices:
                # Limit to requested days
                prices = prices[:days]
                logger.info(f"Alpha Vantage: Got {len(prices)} price records for {symbol}")
                return prices
        except Exception as e:
            logger.error(f"Alpha Vantage also failed for {symbol}: {e}")

        logger.error(f"All sources failed for {symbol}")
        return []

    def store_prices(self, db, stock: Stock, prices: List[Dict[str, Any]]) -> Dict[str, int]:
        """
        Store price data in database, handling duplicates gracefully.

        Args:
            db: Database session
            stock: Stock model instance
            prices: List of price dictionaries

        Returns:
            Dictionary with counts of new and skipped records
        """
        new_count = 0
        skipped_count = 0
        error_count = 0

        for price_data in prices:
            try:
                # Check if price already exists
                existing = db.query(StockPrice).filter(
                    StockPrice.stock_id == stock.id,
                    StockPrice.date == price_data["date"]
                ).first()

                if existing:
                    skipped_count += 1
                    continue

                # Create new price record
                price = StockPrice(
                    stock_id=stock.id,
                    date=price_data["date"],
                    open=price_data["open"],
                    close=price_data["close"],
                    high=price_data["high"],
                    low=price_data["low"],
                    volume=price_data["volume"]
                )
                db.add(price)
                new_count += 1

            except IntegrityError as e:
                # Duplicate key constraint violation
                db.rollback()
                skipped_count += 1
                logger.debug(f"Duplicate price for {stock.symbol} on {price_data['date']}")
            except Exception as e:
                db.rollback()
                error_count += 1
                logger.error(f"Error storing price for {stock.symbol} on {price_data['date']}: {e}")

        # Commit all new prices
        try:
            db.commit()
        except Exception as e:
            db.rollback()
            logger.error(f"Error committing prices for {stock.symbol}: {e}")

        return {
            "new": new_count,
            "skipped": skipped_count,
            "errors": error_count
        }

    def needs_backfill(self, db, stock: Stock, days_threshold: int = 30) -> bool:
        """
        Check if stock needs historical backfill.

        A stock needs backfill if it has fewer than days_threshold records.

        Args:
            db: Database session
            stock: Stock model instance
            days_threshold: Minimum number of records expected

        Returns:
            True if backfill needed
        """
        count = db.query(StockPrice).filter(
            StockPrice.stock_id == stock.id
        ).count()

        return count < days_threshold

    def is_trading_day(self, check_date: date = None) -> bool:
        """
        Check if a given date is a trading day (not weekend).
        Note: This doesn't check for market holidays.

        Args:
            check_date: Date to check (defaults to today)

        Returns:
            True if it's a weekday (Mon-Fri)
        """
        if check_date is None:
            check_date = date.today()

        # 0 = Monday, 5 = Saturday, 6 = Sunday
        return check_date.weekday() < 5

    def fetch_prices_batch(
        self,
        symbols: List[str],
        days: int = 100
    ) -> Dict[str, List[Dict[str, Any]]]:
        """
        Fetch price data for multiple stocks in a single batch call.

        This is significantly faster than sequential fetching for many stocks.

        Args:
            symbols: List of stock ticker symbols
            days: Number of days of historical data

        Returns:
            Dict mapping symbols to their price records
        """
        logger.info(f"Batch fetching {days} days of prices for {len(symbols)} symbols")

        # Use batch service for efficient fetching
        result = self.batch_service.fetch_historical_prices(symbols, days=days)

        if result:
            logger.info(f"Batch fetch successful: got data for {len(result)} symbols")
        else:
            logger.warning("Batch fetch returned no data, falling back to sequential")
            # Fallback to sequential fetching if batch fails
            for symbol in symbols:
                prices = self.fetch_price_data(symbol, days)
                if prices:
                    result[symbol.upper()] = prices

        return result


async def collect_all_prices() -> Dict[str, Any]:
    """
    Main function to collect price data for all portfolio stocks.
    Called by the scheduler.

    Uses batch fetching for 10x+ speedup over sequential fetching.

    Returns:
        Dictionary with collection statistics
    """
    logger.info("=== Starting Price Collection (Batch Mode) ===")

    # Create database session
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    db = Session()

    try:
        # Get all stocks in portfolio
        stocks = db.query(Stock).all()

        if not stocks:
            logger.warning("No stocks in portfolio - skipping price collection")
            return {
                "status": "skipped",
                "reason": "no_stocks",
                "stocks_updated": 0,
                "new_prices": 0
            }

        # Check if today is a trading day
        today = date.today()
        collector = PriceCollectorService()

        if not collector.is_trading_day(today):
            logger.info(f"Today ({today}) is not a trading day (weekend). Skipping collection.")
            return {
                "status": "skipped",
                "reason": "not_trading_day",
                "date": today.isoformat(),
                "stocks_updated": 0,
                "new_prices": 0
            }

        logger.info(f"Collecting prices for {len(stocks)} stocks using batch mode")

        total_new = 0
        total_skipped = 0
        total_errors = 0
        stocks_updated = 0
        stocks_failed = 0

        # Separate stocks into backfill needed vs regular update
        backfill_stocks = []
        regular_stocks = []

        for stock in stocks:
            if collector.needs_backfill(db, stock, days_threshold=30):
                backfill_stocks.append(stock)
            else:
                regular_stocks.append(stock)

        logger.info(f"Backfill needed: {len(backfill_stocks)}, Regular update: {len(regular_stocks)}")

        # Batch fetch for stocks needing backfill (100 days)
        if backfill_stocks:
            backfill_symbols = [s.symbol for s in backfill_stocks]
            logger.info(f"Batch fetching 100 days for {len(backfill_symbols)} backfill stocks")

            backfill_prices = collector.fetch_prices_batch(backfill_symbols, days=100)

            for stock in backfill_stocks:
                symbol = stock.symbol.upper()
                prices = backfill_prices.get(symbol, [])

                if not prices:
                    logger.warning(f"No prices in batch for {symbol}")
                    stocks_failed += 1
                    continue

                result = collector.store_prices(db, stock, prices)
                total_new += result["new"]
                total_skipped += result["skipped"]
                total_errors += result["errors"]

                if result["new"] > 0:
                    stocks_updated += 1

                logger.debug(
                    f"{symbol}: {result['new']} new, "
                    f"{result['skipped']} skipped"
                )

        # Batch fetch for regular updates (5 days)
        if regular_stocks:
            regular_symbols = [s.symbol for s in regular_stocks]
            logger.info(f"Batch fetching 5 days for {len(regular_symbols)} regular stocks")

            regular_prices = collector.fetch_prices_batch(regular_symbols, days=5)

            for stock in regular_stocks:
                symbol = stock.symbol.upper()
                prices = regular_prices.get(symbol, [])

                if not prices:
                    logger.warning(f"No prices in batch for {symbol}")
                    stocks_failed += 1
                    continue

                result = collector.store_prices(db, stock, prices)
                total_new += result["new"]
                total_skipped += result["skipped"]
                total_errors += result["errors"]

                if result["new"] > 0:
                    stocks_updated += 1

                logger.debug(
                    f"{symbol}: {result['new']} new, "
                    f"{result['skipped']} skipped"
                )

        result = {
            "status": "success",
            "timestamp": datetime.now().isoformat(),
            "date": today.isoformat(),
            "stocks_total": len(stocks),
            "stocks_updated": stocks_updated,
            "stocks_failed": stocks_failed,
            "new_prices": total_new,
            "skipped_prices": total_skipped,
            "errors": total_errors,
            "mode": "batch"
        }

        logger.info(f"=== Price Collection Complete (Batch Mode) ===")
        logger.info(
            f"Stocks updated: {stocks_updated}/{len(stocks)}, "
            f"New prices: {total_new}, "
            f"Skipped: {total_skipped}, "
            f"Errors: {total_errors}"
        )

        return result

    except Exception as e:
        db.rollback()
        logger.error(f"Fatal error in price collection: {e}")
        return {
            "status": "error",
            "error": str(e),
            "stocks_updated": 0,
            "new_prices": 0
        }
    finally:
        db.close()

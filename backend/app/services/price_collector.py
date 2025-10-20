"""
Stock price collection service for automated daily price data gathering.

Features:
- Multi-source price fetching (Yahoo Finance primary, Alpha Vantage fallback)
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

logger = logging.getLogger(__name__)


class PriceCollectorService:
    """Service for collecting stock price data from multiple sources."""

    def __init__(self):
        self.yahoo_service = YahooFinanceService()
        self.alpha_vantage = AlphaVantageService()

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


async def collect_all_prices() -> Dict[str, Any]:
    """
    Main function to collect price data for all portfolio stocks.
    Called by the scheduler.

    Returns:
        Dictionary with collection statistics
    """
    logger.info("=== Starting Price Collection ===")

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

        logger.info(f"Collecting prices for {len(stocks)} stocks")

        total_new = 0
        total_skipped = 0
        total_errors = 0
        stocks_updated = 0
        stocks_failed = 0

        for stock in stocks:
            try:
                logger.info(f"Processing {stock.symbol}")

                # Check if backfill is needed
                needs_backfill = collector.needs_backfill(db, stock, days_threshold=30)

                if needs_backfill:
                    logger.info(f"{stock.symbol} needs backfill - fetching 100 days")
                    prices = collector.fetch_price_data(stock.symbol, days=100)
                else:
                    logger.info(f"{stock.symbol} has sufficient history - fetching last 5 days")
                    prices = collector.fetch_price_data(stock.symbol, days=5)

                if not prices:
                    logger.warning(f"No prices fetched for {stock.symbol}")
                    stocks_failed += 1
                    continue

                # Store prices
                result = collector.store_prices(db, stock, prices)

                total_new += result["new"]
                total_skipped += result["skipped"]
                total_errors += result["errors"]

                if result["new"] > 0:
                    stocks_updated += 1

                logger.info(
                    f"{stock.symbol}: {result['new']} new, "
                    f"{result['skipped']} skipped, "
                    f"{result['errors']} errors"
                )

            except Exception as e:
                logger.error(f"Error processing {stock.symbol}: {e}")
                stocks_failed += 1

        result = {
            "status": "success",
            "timestamp": datetime.now().isoformat(),
            "date": today.isoformat(),
            "stocks_total": len(stocks),
            "stocks_updated": stocks_updated,
            "stocks_failed": stocks_failed,
            "new_prices": total_new,
            "skipped_prices": total_skipped,
            "errors": total_errors
        }

        logger.info(f"=== Price Collection Complete ===")
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

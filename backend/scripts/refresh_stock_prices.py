"""
Script to refresh stock prices with proper USD to EUR conversion.
This will delete existing price data and re-fetch it with correct currency conversion.
"""

import sys
import os
import logging

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from sqlalchemy.orm import Session
from backend.app.db.base import engine, SessionLocal
from backend.app.models import Stock, StockPrice
from backend.app.services.yahoo_finance import YahooFinanceService
from backend.app.services.alpha_vantage import AlphaVantageService
from backend.app.core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

yahoo_finance = YahooFinanceService()
alpha_vantage = AlphaVantageService(settings.ALPHA_VANTAGE_API_KEY)


def refresh_all_stock_prices(db: Session):
    """Delete and re-fetch all stock prices with proper EUR conversion."""

    stocks = db.query(Stock).all()

    logger.info(f"Found {len(stocks)} stocks to refresh")

    for stock in stocks:
        logger.info(f"\n{'='*60}")
        logger.info(f"Processing {stock.symbol} ({stock.name})")
        logger.info(f"{'='*60}")

        # Delete existing prices for this stock
        deleted_count = db.query(StockPrice).filter(StockPrice.stock_id == stock.id).delete()
        db.commit()
        logger.info(f"Deleted {deleted_count} old price records for {stock.symbol}")

        # Fetch new prices (will be converted to EUR)
        prices = []

        try:
            # Try Yahoo Finance first
            logger.info(f"Fetching prices from Yahoo Finance for {stock.symbol}")
            prices = yahoo_finance.get_daily_prices(stock.symbol, days=100)

            if not prices:
                # Fallback to Alpha Vantage
                logger.info(f"Yahoo Finance failed, trying Alpha Vantage for {stock.symbol}")
                prices = alpha_vantage.get_daily_prices(stock.symbol, outputsize="compact")

        except Exception as e:
            logger.error(f"Error fetching prices for {stock.symbol}: {e}")
            continue

        if prices:
            # Save new prices
            price_count = 0
            for price_data in prices:
                db_price = StockPrice(
                    stock_id=stock.id,
                    date=price_data["date"],
                    open=price_data["open"],
                    close=price_data["close"],
                    high=price_data["high"],
                    low=price_data["low"],
                    volume=price_data["volume"]
                )
                db.add(db_price)
                price_count += 1

            db.commit()
            logger.info(f"✓ Added {price_count} price records for {stock.symbol} (in EUR)")
        else:
            logger.warning(f"✗ No prices available for {stock.symbol}")

    logger.info(f"\n{'='*60}")
    logger.info("Price refresh completed!")
    logger.info(f"{'='*60}")


if __name__ == "__main__":
    db = SessionLocal()
    try:
        refresh_all_stock_prices(db)
    finally:
        db.close()

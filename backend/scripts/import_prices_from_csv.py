"""
Script to import stock prices from local CSV files.
"""

import sys
import os
import csv
import logging
from datetime import datetime

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from sqlalchemy.orm import Session
from backend.app.db.base import SessionLocal
from backend.app.models import Stock, StockPrice
from backend.app.services.currency_converter import currency_converter

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def import_prices_from_csv(db: Session, symbol: str, csv_path: str):
    """Import prices from a CSV file for a specific stock."""

    # Find the stock
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()

    if not stock:
        logger.error(f"Stock {symbol} not found in database")
        return False

    logger.info(f"Found stock: {stock.symbol} (ID: {stock.id})")

    # Read CSV file
    try:
        with open(csv_path, 'r') as file:
            csv_reader = csv.DictReader(file)
            prices_added = 0

            for row in csv_reader:
                # Parse date (format: MM/DD/YYYY)
                date_str = row['Date']
                date = datetime.strptime(date_str, '%m/%d/%Y').date()

                # Parse prices (remove $ and convert to float, then convert USD to EUR)
                close_usd = float(row['Close/Last'].replace('$', ''))
                open_usd = float(row['Open'].replace('$', ''))
                high_usd = float(row['High'].replace('$', ''))
                low_usd = float(row['Low'].replace('$', ''))
                volume = int(row['Volume'])

                # Convert USD prices to EUR
                close = currency_converter.convert_usd_to_eur(close_usd)
                open_price = currency_converter.convert_usd_to_eur(open_usd)
                high = currency_converter.convert_usd_to_eur(high_usd)
                low = currency_converter.convert_usd_to_eur(low_usd)

                # Check if price already exists
                existing = db.query(StockPrice).filter(
                    StockPrice.stock_id == stock.id,
                    StockPrice.date == date
                ).first()

                if not existing:
                    db_price = StockPrice(
                        stock_id=stock.id,
                        date=date,
                        open=open_price,
                        close=close,
                        high=high,
                        low=low,
                        volume=volume
                    )
                    db.add(db_price)
                    prices_added += 1

            db.commit()
            logger.info(f"✓ Added {prices_added} price records for {symbol}")
            return True

    except Exception as e:
        logger.error(f"Error importing prices for {symbol}: {e}")
        db.rollback()
        return False


if __name__ == "__main__":
    db = SessionLocal()

    try:
        # Map of stock symbols to their CSV files
        csv_files = {
            'NVDA': 'nvda.csv',
            'MSFT': 'msft.csv',
            'AMZN': 'amzn.csv',
            'META': 'meta.csv',
            'AMD': 'amd.csv',
            'AVGO': 'avgo.csv',
            'IBM': 'ibm.csv',
            'GOOG': 'goog.csv',
            'ORCL': 'orlc.csv',
            'ASML': 'asml.csv',
            'FDS': 'fds.csv',
            'FTNT': 'ftnt.csv',
            'PLTR': 'pltr.csv',
            'QBTS': 'qbts.csv',
            'IONQ': 'ionq.csv',
            'FN': 'fn.csv',
            'QUBT': 'qubt.csv',
            'RGTI': 'rgti.csv',
            'LMT': 'lmt.csv'
        }

        csv_dir = os.path.join(os.path.dirname(__file__), '../../csvFiles')

        # Delete all existing prices first
        logger.info("Deleting all existing price data...")
        deleted_count = db.query(StockPrice).delete()
        db.commit()
        logger.info(f"Deleted {deleted_count} existing price records")

        # Import prices for each stock
        for symbol, filename in csv_files.items():
            csv_path = os.path.join(csv_dir, filename)
            if os.path.exists(csv_path):
                logger.info(f"\nImporting {symbol} prices from {filename} (USD -> EUR)")
                import_prices_from_csv(db, symbol, csv_path)
            else:
                logger.warning(f"CSV file not found for {symbol}: {csv_path}")

        logger.info("\n" + "="*60)
        logger.info("✓ All prices imported and converted to EUR!")
        logger.info("="*60)

    finally:
        db.close()

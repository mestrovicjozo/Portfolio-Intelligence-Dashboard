"""
Script to seed sample portfolio data for testing.

Creates:
- A sample portfolio
- Common tech stocks (AAPL, MSFT, GOOGL, NVDA, AMZN)
- Positions with sample share counts and cost basis

Run with: docker compose exec backend python -m backend.scripts.seed_sample_data
"""

import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.app.core.config import settings
from backend.app.models.portfolio import Portfolio
from backend.app.models.stock import Stock
from backend.app.models.position import Position


# Sample stocks to create
SAMPLE_STOCKS = [
    {"symbol": "AAPL", "name": "Apple Inc.", "sector": "Technology"},
    {"symbol": "MSFT", "name": "Microsoft Corporation", "sector": "Technology"},
    {"symbol": "GOOGL", "name": "Alphabet Inc.", "sector": "Technology"},
    {"symbol": "NVDA", "name": "NVIDIA Corporation", "sector": "Technology"},
    {"symbol": "AMZN", "name": "Amazon.com Inc.", "sector": "Consumer Cyclical"},
]

# Sample positions (symbol -> shares, average_cost)
SAMPLE_POSITIONS = {
    "AAPL": (10, 150.00),
    "MSFT": (5, 380.00),
    "GOOGL": (3, 140.00),
    "NVDA": (8, 450.00),
    "AMZN": (4, 175.00),
}


def seed_data():
    """Seed sample portfolio data."""
    print("Seeding sample data...")

    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        # Check if sample portfolio already exists
        existing = session.query(Portfolio).filter_by(name="Sample Portfolio").first()
        if existing:
            print("Sample portfolio already exists. Use --force to recreate.")
            return

        # Create portfolio
        portfolio = Portfolio(
            name="Sample Portfolio",
            description="Sample portfolio with tech stocks for testing",
            is_active=True
        )
        session.add(portfolio)
        session.flush()  # Get the portfolio ID
        print(f"Created portfolio: {portfolio.name} (ID: {portfolio.id})")

        # Deactivate other portfolios
        session.query(Portfolio).filter(Portfolio.id != portfolio.id).update({"is_active": False})

        # Create stocks and positions
        for stock_data in SAMPLE_STOCKS:
            # Check if stock exists
            stock = session.query(Stock).filter_by(symbol=stock_data["symbol"]).first()
            if not stock:
                stock = Stock(**stock_data)
                session.add(stock)
                session.flush()
                print(f"  Created stock: {stock.symbol}")
            else:
                print(f"  Stock exists: {stock.symbol}")

            # Create position
            shares, avg_cost = SAMPLE_POSITIONS[stock.symbol]
            position = Position(
                portfolio_id=portfolio.id,
                stock_id=stock.id,
                shares=shares,
                average_cost=avg_cost
            )
            session.add(position)
            print(f"    Added position: {shares} shares @ ${avg_cost:.2f}")

        session.commit()
        print("\nSample data seeded successfully!")
        print(f"Portfolio '{portfolio.name}' is now active with {len(SAMPLE_STOCKS)} positions.")

    except Exception as e:
        session.rollback()
        print(f"Error seeding data: {e}")
        raise
    finally:
        session.close()


def remove_sample_data():
    """Remove the sample portfolio and its positions."""
    print("Removing sample data...")

    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        portfolio = session.query(Portfolio).filter_by(name="Sample Portfolio").first()
        if portfolio:
            session.delete(portfolio)  # Cascade deletes positions
            session.commit()
            print("Sample portfolio removed.")
        else:
            print("Sample portfolio not found.")
    finally:
        session.close()


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Seed sample portfolio data")
    parser.add_argument("--remove", action="store_true", help="Remove sample data instead of creating")
    parser.add_argument("--force", action="store_true", help="Force recreate (removes existing first)")

    args = parser.parse_args()

    if args.remove:
        remove_sample_data()
    elif args.force:
        remove_sample_data()
        seed_data()
    else:
        seed_data()

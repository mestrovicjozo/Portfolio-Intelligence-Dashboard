"""
Script to seed sample portfolio data for testing.

Creates:
- A sample portfolio with IMBALANCED positions to trigger roboadvisor
- Common tech stocks (AAPL, MSFT, GOOGL, NVDA, AMZN)
- Positions with sample share counts and cost basis
- Target allocations (balanced) to show drift
- User profile for roboadvisor

Run with: docker compose exec backend python -m backend.scripts.seed_sample_data
Options:
  --clean: Delete ALL data before seeding
  --remove: Only remove sample data
  --force: Force recreate (removes existing first)
"""

import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from decimal import Decimal
from datetime import date
import asyncio
from backend.app.core.config import settings
from backend.app.models.portfolio import Portfolio
from backend.app.models.stock import Stock
from backend.app.models.position import Position
from backend.app.models.stock_price import StockPrice
from backend.app.models.user_profile import UserProfile
from backend.app.models.target_allocation import TargetAllocation
from backend.app.services.news_collector import NewsCollectorService
from backend.app.services.yahoo_finance import YahooFinanceService
from backend.app.services.alpha_vantage import AlphaVantageService


# Sample stocks to create
SAMPLE_STOCKS = [
    {"symbol": "AAPL", "name": "Apple Inc.", "sector": "Technology"},
    {"symbol": "MSFT", "name": "Microsoft Corporation", "sector": "Technology"},
    {"symbol": "GOOGL", "name": "Alphabet Inc.", "sector": "Technology"},
    {"symbol": "NVDA", "name": "NVIDIA Corporation", "sector": "Technology"},
    {"symbol": "AMZN", "name": "Amazon.com Inc.", "sector": "Consumer Cyclical"},
]

# IMBALANCED positions to trigger roboadvisor (symbol -> shares, average_cost)
# Portfolio will be ~60% NVDA, ~25% AAPL, ~15% others
SAMPLE_POSITIONS = {
    "NVDA": (50, 450.00),   # ~$22,500 (60% of portfolio)
    "AAPL": (60, 150.00),   # ~$9,000  (24% of portfolio)
    "MSFT": (10, 380.00),   # ~$3,800  (10% of portfolio)
    "GOOGL": (5, 140.00),   # ~$700    (2% of portfolio)
    "AMZN": (8, 175.00),    # ~$1,400  (4% of portfolio)
}

# Balanced target allocations (will show significant drift)
TARGET_ALLOCATIONS = {
    "AAPL": 20.0,
    "MSFT": 20.0,
    "GOOGL": 20.0,
    "NVDA": 20.0,
    "AMZN": 20.0,
}

# Current stock prices (showing gains from cost basis)
CURRENT_PRICES = {
    "NVDA": {"close": 520.00, "open": 515.00, "high": 525.00, "low": 510.00, "volume": 50000000},  # +15.6% gain
    "AAPL": {"close": 180.00, "open": 178.00, "high": 182.00, "low": 177.00, "volume": 60000000},  # +20.0% gain
    "MSFT": {"close": 425.00, "open": 420.00, "high": 428.00, "low": 418.00, "volume": 30000000},  # +11.8% gain
    "GOOGL": {"close": 165.00, "open": 163.00, "high": 167.00, "low": 162.00, "volume": 25000000}, # +17.9% gain
    "AMZN": {"close": 200.00, "open": 198.00, "high": 203.00, "low": 197.00, "volume": 40000000},  # +14.3% gain
}


async def fetch_and_store_news(session, stock_map: dict):
    """Fetch and store news from ActuallyFreeAPI for all stocks."""
    print("\n" + "="*70)
    print("FETCHING NEWS (ActuallyFreeAPI)")
    print("="*70)

    from backend.app.models import NewsArticle, ArticleStock
    collector = NewsCollectorService()
    all_articles = []
    symbols = list(stock_map.keys())

    for symbol in symbols:
        print(f"Fetching news for {symbol}...")
        try:
            articles = await collector.fetch_from_actually_free_api(
                ticker=symbol,
                limit=10  # Get 10 recent articles per stock
            )
            all_articles.extend(articles)
            print(f"  Found {len(articles)} articles")
        except Exception as e:
            print(f"  Error: {e}")

    # Deduplicate
    unique_articles = collector.deduplicate_articles(all_articles)
    print(f"\nTotal unique articles: {len(unique_articles)}")

    # Store articles in database
    print("Storing articles in database...")
    stored_count = 0

    for article_data in unique_articles[:50]:  # Limit to 50 articles for initial seed
        try:
            # Check if already exists
            existing = session.query(NewsArticle).filter(
                NewsArticle.url == article_data["url"]
            ).first()

            if existing:
                continue

            # Find related stocks
            related_stocks = []
            for stock_symbol, stock in stock_map.items():
                if stock_symbol in article_data.get("tickers", []):
                    related_stocks.append(stock)

            if not related_stocks:
                continue

            # Process sentiment
            sentiment_score = collector.process_article_sentiment(article_data)

            # Create article
            article = NewsArticle(
                title=article_data["title"][:500],
                source=article_data["source"][:100] if article_data.get("source") else "ActuallyFreeAPI",
                url=article_data["url"],
                published_at=article_data["published_at"] or date.today(),
                summary=article_data["summary"][:1000] if article_data.get("summary") else "",
                sentiment_score=sentiment_score
            )
            session.add(article)
            session.flush()

            # Link to stocks
            for stock in related_stocks:
                article_stock = ArticleStock(
                    article_id=article.id,
                    stock_id=stock.id
                )
                session.add(article_stock)

            stored_count += 1

        except Exception as e:
            print(f"  Error storing article: {e}")
            continue

    session.commit()
    print(f"Stored {stored_count} articles in database")
    print("="*70)

    return stored_count


def fetch_prices_for_stocks(session, stock_map: dict):
    """Fetch real historical prices for all stocks."""
    print("\n" + "="*70)
    print("FETCHING REAL STOCK PRICES")
    print("="*70)

    yahoo_finance = YahooFinanceService()
    alpha_vantage = AlphaVantageService(settings.ALPHA_VANTAGE_API_KEY)

    for symbol, stock in stock_map.items():
        print(f"Fetching prices for {symbol}...")

        try:
            # Try Yahoo Finance first
            prices = yahoo_finance.get_daily_prices(symbol, days=30)

            if not prices:
                # Fallback to Alpha Vantage
                print(f"  Yahoo failed, trying Alpha Vantage...")
                prices = alpha_vantage.get_daily_prices(symbol, outputsize="compact")

            if prices:
                # Delete existing sample prices for this stock
                session.query(StockPrice).filter(StockPrice.stock_id == stock.id).delete()

                # Add new prices
                for price_data in prices:
                    stock_price = StockPrice(
                        stock_id=stock.id,
                        date=price_data["date"],
                        open=price_data["open"],
                        close=price_data["close"],
                        high=price_data["high"],
                        low=price_data["low"],
                        volume=price_data["volume"]
                    )
                    session.add(stock_price)

                session.commit()
                print(f"  Added {len(prices)} price records")
            else:
                print(f"  No prices available, keeping sample data")

        except Exception as e:
            print(f"  Error: {e}")

    print("="*70)


def delete_all_data():
    """Delete ALL data from ALL tables. Use with caution!"""
    print("WARNING: Deleting ALL data from database...")
    print("This will delete: portfolios, stocks, positions, news, prices, roboadvisor data, etc.")

    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        # Import all models to ensure they're registered
        from backend.app.models import (
            PaperTrade, Recommendation, RiskScore, TargetAllocation,
            UserProfile, Position, Portfolio, ArticleStock, NewsArticle,
            StockPrice, Stock
        )

        # Delete in correct order to respect foreign key constraints
        print("Deleting roboadvisor data...")
        session.query(PaperTrade).delete()
        session.query(Recommendation).delete()
        session.query(RiskScore).delete()
        session.query(TargetAllocation).delete()
        session.query(UserProfile).delete()

        print("Deleting portfolio data...")
        session.query(Position).delete()
        session.query(Portfolio).delete()

        print("Deleting news data...")
        session.query(ArticleStock).delete()
        session.query(NewsArticle).delete()

        print("Deleting stock data...")
        session.query(StockPrice).delete()
        session.query(Stock).delete()

        session.commit()
        print("All data deleted successfully!")

    except Exception as e:
        session.rollback()
        print(f"Error deleting data: {e}")
        raise
    finally:
        session.close()


def seed_data():
    """Seed sample portfolio data with IMBALANCED positions."""
    print("Seeding sample data...")
    print("Portfolio will be imbalanced to trigger roboadvisor recommendations")

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
            description="Imbalanced portfolio to demonstrate roboadvisor",
            is_active=True
        )
        session.add(portfolio)
        session.flush()  # Get the portfolio ID
        print(f"Created portfolio: {portfolio.name} (ID: {portfolio.id})")

        # Deactivate other portfolios
        session.query(Portfolio).filter(Portfolio.id != portfolio.id).update({"is_active": False})

        # Create stocks and positions
        stock_map = {}  # Keep track of created stocks
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

            stock_map[stock.symbol] = stock

            # Create position
            shares, avg_cost = SAMPLE_POSITIONS[stock.symbol]
            position = Position(
                portfolio_id=portfolio.id,
                stock_id=stock.id,
                shares=shares,
                average_cost=avg_cost
            )
            session.add(position)
            position_value = shares * avg_cost
            print(f"    Added position: {shares} shares @ ${avg_cost:.2f} = ${position_value:,.2f}")

        # Add current stock prices
        print("\nAdding current stock prices...")
        today = date.today()
        for symbol, price_data in CURRENT_PRICES.items():
            stock = stock_map.get(symbol)
            if stock:
                stock_price = StockPrice(
                    stock_id=stock.id,
                    date=today,
                    open=price_data["open"],
                    close=price_data["close"],
                    high=price_data["high"],
                    low=price_data["low"],
                    volume=price_data["volume"]
                )
                session.add(stock_price)
                print(f"  {symbol}: ${price_data['close']:.2f}")

        # Create user profile for roboadvisor
        print("\nCreating roboadvisor profile...")
        profile = UserProfile(
            portfolio_id=portfolio.id,
            risk_tolerance="moderate",
            investment_horizon=5,
            rebalance_threshold=Decimal("5.0")
        )
        session.add(profile)
        session.flush()
        print(f"  Created user profile (ID: {profile.id})")

        # Create balanced target allocations (will show drift)
        print("\nSetting target allocations (balanced)...")
        for symbol, target_pct in TARGET_ALLOCATIONS.items():
            stock = stock_map.get(symbol)
            if stock:
                allocation = TargetAllocation(
                    profile_id=profile.id,
                    stock_id=stock.id,
                    target_weight=Decimal(str(target_pct))
                )
                session.add(allocation)
                print(f"  {symbol}: {target_pct}%")

        session.commit()

        # Calculate and display current allocation with gains
        print("\n" + "="*70)
        print("PORTFOLIO SUMMARY")
        print("="*70)

        total_cost = sum(shares * avg_cost for shares, avg_cost in SAMPLE_POSITIONS.values())
        total_current_value = sum(shares * CURRENT_PRICES[symbol]["close"]
                                  for symbol, (shares, avg_cost) in SAMPLE_POSITIONS.items())
        total_gain = total_current_value - total_cost
        total_gain_pct = (total_gain / total_cost) * 100 if total_cost > 0 else 0

        print(f"Total Cost Basis:    ${total_cost:>12,.2f}")
        print(f"Current Value:       ${total_current_value:>12,.2f}")
        print(f"Total Gain/Loss:     ${total_gain:>12,.2f} ({total_gain_pct:+.1f}%)\n")

        print(f"{'Stock':<8} {'Shares':<8} {'Cost':<10} {'Current':<10} {'Gain/Loss':<15} {'Target':<8} {'Actual':<8} {'Drift':<8}")
        print("-" * 80)

        for symbol, (shares, avg_cost) in SAMPLE_POSITIONS.items():
            current_price = CURRENT_PRICES[symbol]["close"]
            cost_basis = shares * avg_cost
            current_value = shares * current_price
            gain = current_value - cost_basis
            gain_pct = (gain / cost_basis) * 100 if cost_basis > 0 else 0

            current_alloc_pct = (current_value / total_current_value) * 100
            target_pct = TARGET_ALLOCATIONS.get(symbol, 0)
            drift = current_alloc_pct - target_pct

            print(f"{symbol:<8} {shares:<8.0f} ${avg_cost:<9.2f} ${current_price:<9.2f} "
                  f"${gain:>7,.2f} ({gain_pct:>+5.1f}%)  {target_pct:>5.1f}%  {current_alloc_pct:>5.1f}%  {drift:>+5.1f}%")

        print("\n" + "="*70)
        print("Sample data seeded successfully!")
        print(f"Portfolio '{portfolio.name}' is now active with {len(SAMPLE_STOCKS)} positions.")
        print("\nRoboadvisor should recommend rebalancing due to significant drift!")
        print("="*70)

        # Fetch real prices and news
        print("\nFetching real stock prices and news...")
        try:
            # Fetch real prices (this will replace sample prices with real ones)
            fetch_prices_for_stocks(session, stock_map)

            # Fetch and store news articles
            stored_count = asyncio.run(fetch_and_store_news(session, stock_map))

            if stored_count > 0:
                print(f"\nSuccessfully stored {stored_count} news articles!")
            else:
                print("\nNo news articles stored (may have rate limits or no matching tickers)")

        except Exception as e:
            print(f"\nWarning: Error fetching real data: {e}")
            print("Portfolio created with sample prices and no news.")

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
    parser.add_argument("--clean", action="store_true", help="Delete ALL data from database before seeding")
    parser.add_argument("--remove", action="store_true", help="Remove sample data instead of creating")
    parser.add_argument("--force", action="store_true", help="Force recreate (removes existing first)")

    args = parser.parse_args()

    if args.remove:
        remove_sample_data()
    elif args.clean:
        # Delete everything and seed fresh data
        response = input("This will DELETE ALL DATA from the database. Are you sure? (yes/no): ")
        if response.lower() == "yes":
            delete_all_data()
            seed_data()
        else:
            print("Operation cancelled.")
    elif args.force:
        remove_sample_data()
        seed_data()
    else:
        seed_data()

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import logging

from backend.app.db.base import get_db
from backend.app.models import Portfolio, Position, StockPrice
from backend.app.schemas.portfolio import PortfolioWithStats

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/default", response_model=PortfolioWithStats)
def get_default_portfolio(db: Session = Depends(get_db)):
    """
    Get the default portfolio with statistics.
    Auto-creates a default portfolio if none exists.
    """
    # Check if any portfolio exists
    portfolio = db.query(Portfolio).first()

    if not portfolio:
        # Create a default portfolio if none exists
        portfolio = Portfolio(
            name="My Portfolio",
            description="Your investment portfolio",
            is_active=True
        )
        db.add(portfolio)
        db.commit()
        db.refresh(portfolio)
        logger.info("Created default portfolio")

    # Calculate portfolio statistics
    stats = calculate_portfolio_stats(db, portfolio.id)

    return PortfolioWithStats(
        id=portfolio.id,
        name=portfolio.name,
        description=portfolio.description,
        is_active=portfolio.is_active,
        created_at=portfolio.created_at,
        updated_at=portfolio.updated_at,
        **stats
    )


def calculate_portfolio_stats(db: Session, portfolio_id: int) -> dict:
    """Calculate portfolio statistics including value, cost, and gain/loss."""
    positions = db.query(Position).filter(Position.portfolio_id == portfolio_id).all()

    if not positions:
        return {
            "total_value": 0.0,
            "total_cost": 0.0,
            "total_gain_loss": 0.0,
            "total_gain_loss_percent": 0.0,
            "position_count": 0
        }

    total_value = 0.0
    total_cost = 0.0

    for position in positions:
        # Get latest stock price
        latest_price = db.query(StockPrice).filter(
            StockPrice.stock_id == position.stock_id
        ).order_by(StockPrice.date.desc()).first()

        position_cost = position.shares * position.average_cost
        total_cost += position_cost

        if latest_price:
            position_value = position.shares * latest_price.close
            total_value += position_value

    total_gain_loss = total_value - total_cost
    total_gain_loss_percent = (total_gain_loss / total_cost * 100) if total_cost > 0 else 0.0

    return {
        "total_value": round(total_value, 2),
        "total_cost": round(total_cost, 2),
        "total_gain_loss": round(total_gain_loss, 2),
        "total_gain_loss_percent": round(total_gain_loss_percent, 2),
        "position_count": len(positions)
    }

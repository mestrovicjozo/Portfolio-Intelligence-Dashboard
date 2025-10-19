from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import logging

from backend.app.db.base import get_db
from backend.app.models import Portfolio, Position, Stock, StockPrice
from backend.app.schemas.portfolio import (
    Portfolio as PortfolioSchema,
    PortfolioCreate,
    PortfolioUpdate,
    PortfolioWithStats,
)
from sqlalchemy import func

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/", response_model=List[PortfolioSchema])
def get_portfolios(db: Session = Depends(get_db)):
    """Get all portfolios."""
    portfolios = db.query(Portfolio).order_by(Portfolio.created_at.desc()).all()
    return portfolios


@router.get("/active", response_model=PortfolioWithStats)
def get_active_portfolio(db: Session = Depends(get_db)):
    """Get the currently active portfolio with statistics."""
    portfolio = db.query(Portfolio).filter(Portfolio.is_active == True).first()

    if not portfolio:
        # Create a default portfolio if none exists
        portfolio = Portfolio(
            name="My Portfolio",
            description="Default portfolio",
            is_active=True
        )
        db.add(portfolio)
        db.commit()
        db.refresh(portfolio)

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


@router.get("/{portfolio_id}", response_model=PortfolioWithStats)
def get_portfolio(portfolio_id: int, db: Session = Depends(get_db)):
    """Get a specific portfolio by ID with statistics."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()

    if not portfolio:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Portfolio with id {portfolio_id} not found"
        )

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


@router.post("/", response_model=PortfolioSchema, status_code=status.HTTP_201_CREATED)
def create_portfolio(portfolio_data: PortfolioCreate, db: Session = Depends(get_db)):
    """Create a new portfolio."""
    try:
        portfolio = Portfolio(
            name=portfolio_data.name,
            description=portfolio_data.description,
            is_active=False
        )

        db.add(portfolio)
        db.commit()
        db.refresh(portfolio)

        logger.info(f"Created portfolio: {portfolio.name} (ID: {portfolio.id})")
        return portfolio

    except Exception as e:
        db.rollback()
        logger.error(f"Error creating portfolio: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating portfolio: {str(e)}"
        )


@router.put("/{portfolio_id}", response_model=PortfolioSchema)
def update_portfolio(
    portfolio_id: int,
    portfolio_data: PortfolioUpdate,
    db: Session = Depends(get_db)
):
    """Update a portfolio."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()

    if not portfolio:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Portfolio with id {portfolio_id} not found"
        )

    try:
        # Update only provided fields
        if portfolio_data.name is not None:
            portfolio.name = portfolio_data.name
        if portfolio_data.description is not None:
            portfolio.description = portfolio_data.description

        db.commit()
        db.refresh(portfolio)

        logger.info(f"Updated portfolio: {portfolio.name} (ID: {portfolio.id})")
        return portfolio

    except Exception as e:
        db.rollback()
        logger.error(f"Error updating portfolio: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating portfolio: {str(e)}"
        )


@router.post("/{portfolio_id}/activate", response_model=PortfolioSchema)
def activate_portfolio(portfolio_id: int, db: Session = Depends(get_db)):
    """Set a portfolio as the active portfolio."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()

    if not portfolio:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Portfolio with id {portfolio_id} not found"
        )

    try:
        # Deactivate all portfolios
        db.query(Portfolio).update({Portfolio.is_active: False})

        # Activate the selected portfolio
        portfolio.is_active = True

        db.commit()
        db.refresh(portfolio)

        logger.info(f"Activated portfolio: {portfolio.name} (ID: {portfolio.id})")
        return portfolio

    except Exception as e:
        db.rollback()
        logger.error(f"Error activating portfolio: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error activating portfolio: {str(e)}"
        )


@router.delete("/{portfolio_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_portfolio(portfolio_id: int, db: Session = Depends(get_db)):
    """Delete a portfolio and all its positions."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()

    if not portfolio:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Portfolio with id {portfolio_id} not found"
        )

    # Don't allow deleting the last portfolio
    portfolio_count = db.query(Portfolio).count()
    if portfolio_count <= 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete the last portfolio"
        )

    try:
        # If deleting active portfolio, activate another one
        if portfolio.is_active:
            other_portfolio = db.query(Portfolio).filter(
                Portfolio.id != portfolio_id
            ).first()
            if other_portfolio:
                other_portfolio.is_active = True

        db.delete(portfolio)
        db.commit()

        logger.info(f"Deleted portfolio: {portfolio.name} (ID: {portfolio.id})")

    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting portfolio: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting portfolio: {str(e)}"
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

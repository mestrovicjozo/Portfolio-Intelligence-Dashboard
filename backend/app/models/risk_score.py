"""
Risk score model for roboadvisor.

Stores historical risk scores for portfolio positions.
"""

from sqlalchemy import Column, Integer, Numeric, Date, ForeignKey, UniqueConstraint, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from backend.app.db.base import Base


class RiskScore(Base):
    """Risk score record for a stock on a specific date."""

    __tablename__ = "risk_scores"

    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("portfolios.id"), nullable=False)
    stock_id = Column(Integer, ForeignKey("stocks.id"), nullable=True)  # Null for portfolio-level

    # Score date
    score_date = Column(Date, nullable=False)

    # Risk components (0-100 scale)
    volatility_score = Column(Numeric(5, 2))  # Based on historical volatility
    sentiment_score = Column(Numeric(5, 2))  # Based on news sentiment
    beta = Column(Numeric(5, 2))  # Market correlation

    # Overall risk (weighted combination)
    overall_risk = Column(Numeric(5, 2), nullable=False)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)

    # Unique constraint: one score per stock per date per portfolio
    __table_args__ = (
        UniqueConstraint('portfolio_id', 'stock_id', 'score_date', name='uix_portfolio_stock_date'),
    )

    # Relationships
    portfolio = relationship("Portfolio")
    stock = relationship("Stock")

    def __repr__(self):
        return f"<RiskScore(stock_id={self.stock_id}, date={self.score_date}, risk={self.overall_risk})>"

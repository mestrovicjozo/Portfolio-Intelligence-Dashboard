"""
Recommendation model for roboadvisor.

Stores AI-generated trading recommendations with reasoning.
"""

from sqlalchemy import Column, Integer, String, Numeric, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from backend.app.db.base import Base


class Recommendation(Base):
    """AI-generated trading recommendation."""

    __tablename__ = "recommendations"

    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("portfolios.id"), nullable=False)
    stock_id = Column(Integer, ForeignKey("stocks.id"), nullable=False)

    # Recommendation details
    recommendation_type = Column(String(50), nullable=False)  # signal, rebalance, risk_alert
    action = Column(String(20), nullable=False)  # BUY, SELL, HOLD, REDUCE, INCREASE
    confidence = Column(Numeric(3, 2), nullable=False)  # 0.00 to 1.00
    reasoning = Column(Text)

    # Risk and time horizon
    risk_level = Column(String(20))  # low, medium, high
    time_horizon = Column(String(20))  # short, medium, long

    # Status tracking
    status = Column(String(20), default="pending")  # pending, accepted, rejected, executed, expired

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    expires_at = Column(DateTime)  # When this recommendation becomes stale

    # Relationships
    portfolio = relationship("Portfolio")
    stock = relationship("Stock")
    paper_trades = relationship("PaperTrade", back_populates="recommendation")

    def __repr__(self):
        return f"<Recommendation(stock_id={self.stock_id}, action={self.action}, confidence={self.confidence})>"

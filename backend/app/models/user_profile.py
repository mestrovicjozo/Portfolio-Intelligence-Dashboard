"""
User investment profile model for roboadvisor.

Stores user preferences for risk tolerance, investment horizon, and rebalancing thresholds.
"""

from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from backend.app.db.base import Base


class UserProfile(Base):
    """User investment profile for roboadvisor recommendations."""

    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("portfolios.id"), unique=True, nullable=False)

    # Risk preferences
    risk_tolerance = Column(String(20), default="moderate")  # conservative, moderate, aggressive
    investment_horizon = Column(Integer, default=5)  # years
    rebalance_threshold = Column(Numeric(5, 2), default=5.0)  # percentage drift to trigger rebalance

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    portfolio = relationship("Portfolio", back_populates="user_profile")
    target_allocations = relationship("TargetAllocation", back_populates="profile", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<UserProfile(portfolio_id={self.portfolio_id}, risk={self.risk_tolerance})>"

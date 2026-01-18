"""
Target allocation model for roboadvisor.

Stores the target weight for each stock in a portfolio.
"""

from sqlalchemy import Column, Integer, Numeric, ForeignKey, UniqueConstraint, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from backend.app.db.base import Base


class TargetAllocation(Base):
    """Target allocation for a stock in a portfolio."""

    __tablename__ = "target_allocations"

    id = Column(Integer, primary_key=True, index=True)
    profile_id = Column(Integer, ForeignKey("user_profiles.id"), nullable=False)
    stock_id = Column(Integer, ForeignKey("stocks.id"), nullable=False)

    # Target weight as percentage (0-100)
    target_weight = Column(Numeric(5, 2), nullable=False)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Unique constraint: one target per stock per profile
    __table_args__ = (
        UniqueConstraint('profile_id', 'stock_id', name='uix_profile_stock'),
    )

    # Relationships
    profile = relationship("UserProfile", back_populates="target_allocations")
    stock = relationship("Stock")

    def __repr__(self):
        return f"<TargetAllocation(profile_id={self.profile_id}, stock_id={self.stock_id}, weight={self.target_weight})>"

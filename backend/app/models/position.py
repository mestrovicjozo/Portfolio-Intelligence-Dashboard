from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.app.db.base import Base


class Position(Base):
    """Position model representing stock holdings in a portfolio."""

    __tablename__ = "positions"

    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("portfolios.id", ondelete="CASCADE"), nullable=False)
    stock_id = Column(Integer, ForeignKey("stocks.id", ondelete="CASCADE"), nullable=False)

    # Position details
    shares = Column(Float, nullable=False)  # Number of shares owned
    average_cost = Column(Float, nullable=False)  # Average cost per share

    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Ensure unique stock per portfolio
    __table_args__ = (
        UniqueConstraint('portfolio_id', 'stock_id', name='unique_portfolio_stock'),
    )

    # Relationships
    portfolio = relationship("Portfolio", back_populates="positions")
    stock = relationship("Stock")

    def __repr__(self):
        return f"<Position(portfolio_id={self.portfolio_id}, stock_id={self.stock_id}, shares={self.shares})>"

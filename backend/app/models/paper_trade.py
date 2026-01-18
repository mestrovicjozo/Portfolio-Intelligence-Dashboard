"""
Paper trade model for roboadvisor.

Simulates trades based on AI signals without real money.
Used to track performance and validate signal accuracy.
"""

from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, DateTime, Index
from sqlalchemy.orm import relationship
from datetime import datetime

from backend.app.db.base import Base


class PaperTrade(Base):
    """Paper trade simulation record."""

    __tablename__ = "paper_trades"

    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("portfolios.id"), nullable=False)
    stock_id = Column(Integer, ForeignKey("stocks.id"), nullable=False)
    recommendation_id = Column(Integer, ForeignKey("recommendations.id"), nullable=True)

    # Trade details
    action = Column(String(10), nullable=False)  # buy, sell
    quantity = Column(Numeric(10, 4), nullable=False)

    # Prices
    entry_price = Column(Numeric(10, 2), nullable=False)
    exit_price = Column(Numeric(10, 2), nullable=True)  # Filled when closed

    # Timestamps
    entry_date = Column(DateTime, default=datetime.utcnow, nullable=False)
    exit_date = Column(DateTime, nullable=True)

    # Performance
    pnl = Column(Numeric(12, 2), nullable=True)  # Profit/loss in dollars
    pnl_percent = Column(Numeric(6, 2), nullable=True)  # Profit/loss percentage

    # Status
    status = Column(String(20), default="open")  # open, closed, cancelled

    # Signal info
    signal_confidence = Column(Numeric(3, 2), nullable=True)  # Confidence at time of trade

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Indexes
    __table_args__ = (
        Index('idx_paper_trades_portfolio', 'portfolio_id'),
        Index('idx_paper_trades_status', 'status'),
    )

    # Relationships
    portfolio = relationship("Portfolio")
    stock = relationship("Stock")
    recommendation = relationship("Recommendation", back_populates="paper_trades")

    def calculate_pnl(self):
        """Calculate P&L when trade is closed."""
        if self.exit_price and self.entry_price and self.quantity:
            if self.action == "buy":
                self.pnl = float(self.quantity) * (float(self.exit_price) - float(self.entry_price))
            else:  # sell (short)
                self.pnl = float(self.quantity) * (float(self.entry_price) - float(self.exit_price))

            if float(self.entry_price) > 0:
                if self.action == "buy":
                    self.pnl_percent = ((float(self.exit_price) - float(self.entry_price)) / float(self.entry_price)) * 100
                else:
                    self.pnl_percent = ((float(self.entry_price) - float(self.exit_price)) / float(self.entry_price)) * 100

    def __repr__(self):
        return f"<PaperTrade(stock_id={self.stock_id}, action={self.action}, status={self.status})>"

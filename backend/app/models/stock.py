from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.app.db.base import Base


class Stock(Base):
    """Stock model representing tracked stocks in portfolio."""

    __tablename__ = "stocks"

    id = Column(Integer, primary_key=True, index=True)
    symbol = Column(String(10), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    sector = Column(String(100), nullable=True)
    logo_filename = Column(String(255), nullable=True)  # Filename of logo (e.g., "AAPL.png")
    added_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    prices = relationship("StockPrice", back_populates="stock", cascade="all, delete-orphan")
    articles = relationship("ArticleStock", back_populates="stock", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Stock(symbol={self.symbol}, name={self.name})>"

from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.app.db.base import Base


class Portfolio(Base):
    """Portfolio model representing user's investment portfolios."""

    __tablename__ = "portfolios"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=False, nullable=False)  # Currently selected portfolio
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    positions = relationship("Position", back_populates="portfolio", cascade="all, delete-orphan")
    user_profile = relationship("UserProfile", back_populates="portfolio", uselist=False, cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Portfolio(name={self.name}, active={self.is_active})>"

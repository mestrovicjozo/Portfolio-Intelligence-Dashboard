from sqlalchemy import Column, Integer, String, Text, DateTime, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from backend.app.db.base import Base


class NewsArticle(Base):
    """News article model for storing financial news."""

    __tablename__ = "news_articles"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(500), nullable=False)
    source = Column(String(100), nullable=True)
    url = Column(Text, nullable=True, unique=True)
    published_at = Column(DateTime(timezone=True), nullable=True, index=True)
    summary = Column(Text, nullable=True)
    sentiment_score = Column(Float, nullable=True)  # -1.0 (negative) to 1.0 (positive)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    stocks = relationship("ArticleStock", back_populates="article", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<NewsArticle(id={self.id}, title={self.title[:50]}...)>"

from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from backend.app.db.base import Base


class ArticleStock(Base):
    """Many-to-many relationship between articles and stocks."""

    __tablename__ = "article_stocks"

    id = Column(Integer, primary_key=True, index=True)
    article_id = Column(Integer, ForeignKey("news_articles.id", ondelete="CASCADE"), nullable=False)
    stock_id = Column(Integer, ForeignKey("stocks.id", ondelete="CASCADE"), nullable=False)

    # Relationships
    article = relationship("NewsArticle", back_populates="stocks")
    stock = relationship("Stock", back_populates="articles")

    # Ensure one relationship per article-stock pair
    __table_args__ = (
        UniqueConstraint('article_id', 'stock_id', name='uix_article_stock'),
    )

    def __repr__(self):
        return f"<ArticleStock(article_id={self.article_id}, stock_id={self.stock_id})>"

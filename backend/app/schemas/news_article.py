from pydantic import BaseModel, Field, HttpUrl
from datetime import datetime
from typing import Optional, List


class NewsArticleBase(BaseModel):
    """Base news article schema."""
    title: str = Field(..., max_length=500)
    source: Optional[str] = Field(None, max_length=100)
    url: Optional[str] = None
    published_at: Optional[datetime] = None
    summary: Optional[str] = None
    sentiment_score: Optional[float] = Field(None, ge=-1.0, le=1.0, description="Sentiment from -1 (negative) to 1 (positive)")


class NewsArticleCreate(NewsArticleBase):
    """Schema for creating a news article."""
    stock_symbols: List[str] = Field(default_factory=list, description="Associated stock symbols")


class NewsArticle(NewsArticleBase):
    """Schema for news article response."""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class NewsArticleWithStocks(NewsArticle):
    """News article with associated stocks."""
    stock_symbols: List[str] = Field(default_factory=list)


class SentimentAnalysis(BaseModel):
    """Sentiment analysis result."""
    score: float = Field(..., ge=-1.0, le=1.0, description="Sentiment score")
    label: str = Field(..., description="Sentiment label (positive/neutral/negative)")
    confidence: Optional[float] = Field(None, ge=0.0, le=1.0)

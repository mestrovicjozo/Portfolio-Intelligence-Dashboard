from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any


class QueryRequest(BaseModel):
    """Schema for natural language query request."""
    question: str = Field(..., min_length=1, max_length=1000, description="User's question")
    context_limit: Optional[int] = Field(5, ge=1, le=20, description="Number of relevant articles to retrieve")


class QueryResponse(BaseModel):
    """Schema for query response."""
    answer: str = Field(..., description="AI-generated answer")
    sources: List[Dict[str, Any]] = Field(default_factory=list, description="Source articles used")
    confidence: Optional[float] = Field(None, ge=0.0, le=1.0, description="Confidence score")


class PortfolioSummary(BaseModel):
    """Schema for portfolio summary."""
    total_stocks: int
    total_value: Optional[float] = None
    total_change: Optional[float] = None
    total_change_percent: Optional[float] = None
    sentiment_average: Optional[float] = None
    top_gainers: List[Dict[str, Any]] = Field(default_factory=list)
    top_losers: List[Dict[str, Any]] = Field(default_factory=list)

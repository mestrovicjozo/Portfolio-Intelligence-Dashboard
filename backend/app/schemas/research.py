"""
Pydantic schemas for research API endpoints.
"""

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class SearchResult(BaseModel):
    """Individual search result."""
    title: str
    link: str
    snippet: str = ""
    source: Optional[str] = None
    date: Optional[str] = None
    symbol: str
    search_type: str


class NewsSearchResponse(BaseModel):
    """Response for news search endpoint."""
    symbol: str
    company_name: Optional[str] = None
    results: List[SearchResult]
    count: int
    timestamp: datetime = Field(default_factory=datetime.now)


class SECFilingResult(SearchResult):
    """SEC filing search result."""
    filing_type: Optional[str] = None


class SECFilingsResponse(BaseModel):
    """Response for SEC filings search endpoint."""
    symbol: str
    results: List[SECFilingResult]
    count: int
    timestamp: datetime = Field(default_factory=datetime.now)


class AnalystReportResponse(BaseModel):
    """Response for analyst reports search endpoint."""
    symbol: str
    results: List[SearchResult]
    count: int
    timestamp: datetime = Field(default_factory=datetime.now)


class ComprehensiveResearchResponse(BaseModel):
    """Response for comprehensive research endpoint."""
    symbol: str
    company_name: Optional[str] = None
    news: List[SearchResult]
    sec_filings: List[SECFilingResult]
    analyst_reports: List[SearchResult]
    total_results: int
    timestamp: datetime = Field(default_factory=datetime.now)


class EnhancedNewsRequest(BaseModel):
    """Request for enhanced news collection."""
    symbols: List[str] = Field(..., description="List of stock symbols to search")
    days_back: int = Field(default=7, ge=1, le=30, description="Days to look back")
    include_sec: bool = Field(default=False, description="Include SEC filings")
    include_analyst: bool = Field(default=False, description="Include analyst reports")


class EnhancedNewsResponse(BaseModel):
    """Response for enhanced news collection."""
    results: dict  # symbol -> list of results
    total_articles: int
    symbols_searched: int
    timestamp: datetime = Field(default_factory=datetime.now)

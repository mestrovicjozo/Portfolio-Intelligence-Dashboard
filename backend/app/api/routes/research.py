"""
Research API routes for enhanced financial research using Serper.

Provides endpoints for:
- Stock news search
- SEC filings discovery
- Analyst reports
- Comprehensive research
"""

from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from datetime import datetime
import logging

from backend.app.schemas.research import (
    NewsSearchResponse,
    SECFilingsResponse,
    AnalystReportResponse,
    ComprehensiveResearchResponse,
    EnhancedNewsRequest,
    EnhancedNewsResponse,
    SearchResult,
    SECFilingResult
)
from backend.app.services.serper_service import get_serper_service
from backend.app.db.base import get_db
from backend.app.models import Stock
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)

router = APIRouter()


def get_serper():
    """Dependency to get Serper service."""
    try:
        return get_serper_service()
    except ValueError as e:
        logger.warning(f"Serper service not available: {e}")
        raise HTTPException(
            status_code=503,
            detail="Research service not configured. Please set SERPER_API_KEY."
        )


@router.get("/search/{symbol}", response_model=NewsSearchResponse)
def search_stock_news(
    symbol: str,
    company_name: Optional[str] = Query(None, description="Company name for better results"),
    days_back: int = Query(7, ge=1, le=30, description="Days to look back"),
    db: Session = Depends(get_db)
):
    """
    Search for recent news about a stock.

    Args:
        symbol: Stock ticker symbol
        company_name: Optional company name
        days_back: Number of days to search back

    Returns:
        News search results
    """
    symbol = symbol.upper()

    # Try to get company name from database if not provided
    if not company_name:
        stock = db.query(Stock).filter(Stock.symbol == symbol).first()
        if stock:
            company_name = stock.name

    try:
        serper = get_serper()
        results = serper.search_stock_news(symbol, company_name, days_back)

        return NewsSearchResponse(
            symbol=symbol,
            company_name=company_name,
            results=[SearchResult(**r) for r in results],
            count=len(results),
            timestamp=datetime.now()
        )

    except Exception as e:
        logger.error(f"Error searching news for {symbol}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error searching news: {str(e)}"
        )


@router.get("/filings/{symbol}", response_model=SECFilingsResponse)
def search_sec_filings(
    symbol: str,
    company_name: Optional[str] = Query(None, description="Company name"),
    filing_type: Optional[str] = Query(None, description="Filing type (10-K, 10-Q, 8-K)"),
    db: Session = Depends(get_db)
):
    """
    Search for SEC filings for a company.

    Args:
        symbol: Stock ticker symbol
        company_name: Optional company name
        filing_type: Optional specific filing type

    Returns:
        SEC filing search results
    """
    symbol = symbol.upper()

    # Try to get company name from database if not provided
    if not company_name:
        stock = db.query(Stock).filter(Stock.symbol == symbol).first()
        if stock:
            company_name = stock.name

    try:
        serper = get_serper()
        results = serper.search_sec_filings(symbol, company_name, filing_type)

        return SECFilingsResponse(
            symbol=symbol,
            results=[SECFilingResult(**r) for r in results],
            count=len(results),
            timestamp=datetime.now()
        )

    except Exception as e:
        logger.error(f"Error searching SEC filings for {symbol}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error searching SEC filings: {str(e)}"
        )


@router.get("/analysts/{symbol}", response_model=AnalystReportResponse)
def search_analyst_reports(
    symbol: str,
    company_name: Optional[str] = Query(None, description="Company name"),
    db: Session = Depends(get_db)
):
    """
    Search for analyst reports and ratings.

    Args:
        symbol: Stock ticker symbol
        company_name: Optional company name

    Returns:
        Analyst report search results
    """
    symbol = symbol.upper()

    # Try to get company name from database if not provided
    if not company_name:
        stock = db.query(Stock).filter(Stock.symbol == symbol).first()
        if stock:
            company_name = stock.name

    try:
        serper = get_serper()
        results = serper.search_analyst_reports(symbol, company_name)

        return AnalystReportResponse(
            symbol=symbol,
            results=[SearchResult(**r) for r in results],
            count=len(results),
            timestamp=datetime.now()
        )

    except Exception as e:
        logger.error(f"Error searching analyst reports for {symbol}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error searching analyst reports: {str(e)}"
        )


@router.get("/comprehensive/{symbol}", response_model=ComprehensiveResearchResponse)
def comprehensive_research(
    symbol: str,
    company_name: Optional[str] = Query(None, description="Company name"),
    db: Session = Depends(get_db)
):
    """
    Perform comprehensive research on a stock.

    Combines news, SEC filings, and analyst reports.

    Args:
        symbol: Stock ticker symbol
        company_name: Optional company name

    Returns:
        Comprehensive research results
    """
    symbol = symbol.upper()

    # Try to get company name from database if not provided
    if not company_name:
        stock = db.query(Stock).filter(Stock.symbol == symbol).first()
        if stock:
            company_name = stock.name

    try:
        serper = get_serper()
        results = serper.comprehensive_research(symbol, company_name)

        news = [SearchResult(**r) for r in results.get("news", [])]
        sec_filings = [SECFilingResult(**r) for r in results.get("sec_filings", [])]
        analyst_reports = [SearchResult(**r) for r in results.get("analyst_reports", [])]

        return ComprehensiveResearchResponse(
            symbol=symbol,
            company_name=company_name,
            news=news,
            sec_filings=sec_filings,
            analyst_reports=analyst_reports,
            total_results=len(news) + len(sec_filings) + len(analyst_reports),
            timestamp=datetime.now()
        )

    except Exception as e:
        logger.error(f"Error performing comprehensive research for {symbol}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error performing research: {str(e)}"
        )


@router.post("/news/", response_model=EnhancedNewsResponse)
def enhanced_news_collection(
    request: EnhancedNewsRequest,
    db: Session = Depends(get_db)
):
    """
    Enhanced news collection for multiple symbols.

    Args:
        request: Request with symbols and options

    Returns:
        News results for all requested symbols
    """
    try:
        serper = get_serper()
        all_results = {}
        total_articles = 0

        for symbol in request.symbols:
            symbol = symbol.upper()

            # Get company name from database
            stock = db.query(Stock).filter(Stock.symbol == symbol).first()
            company_name = stock.name if stock else None

            symbol_results = []

            # Get news
            news = serper.search_stock_news(symbol, company_name, request.days_back)
            symbol_results.extend(news)

            # Optionally get SEC filings
            if request.include_sec:
                filings = serper.search_sec_filings(symbol, company_name)
                symbol_results.extend(filings)

            # Optionally get analyst reports
            if request.include_analyst:
                analysts = serper.search_analyst_reports(symbol, company_name)
                symbol_results.extend(analysts)

            all_results[symbol] = symbol_results
            total_articles += len(symbol_results)

        return EnhancedNewsResponse(
            results=all_results,
            total_articles=total_articles,
            symbols_searched=len(request.symbols),
            timestamp=datetime.now()
        )

    except Exception as e:
        logger.error(f"Error in enhanced news collection: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error collecting news: {str(e)}"
        )


@router.get("/health/")
def research_health_check():
    """
    Check if research service is available.

    Returns:
        Health status of the research service
    """
    try:
        serper = get_serper()
        is_healthy = serper.health_check()

        return {
            "status": "healthy" if is_healthy else "unhealthy",
            "service": "serper",
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return {
            "status": "unavailable",
            "service": "serper",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }


@router.post("/cache/clear/")
def clear_research_cache():
    """Clear the research cache."""
    try:
        serper = get_serper()
        serper.clear_cache()
        return {"message": "Research cache cleared", "timestamp": datetime.now().isoformat()}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error clearing cache: {str(e)}"
        )

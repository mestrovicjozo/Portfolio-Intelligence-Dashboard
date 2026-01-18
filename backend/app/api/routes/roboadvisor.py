"""
Roboadvisor API routes.

Provides endpoints for:
- Risk analysis
- Portfolio rebalancing
- Trading signals
- Paper trading simulation
- User profile management
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import logging

from backend.app.db.base import get_db
from backend.app.models import (
    Stock, Portfolio, Position,
    UserProfile, TargetAllocation, Recommendation, PaperTrade
)
from backend.app.schemas.roboadvisor import (
    UserProfileCreate, UserProfileResponse,
    TargetAllocationsCreate, TargetAllocationResponse,
    StockRiskResponse, PortfolioRiskResponse,
    TradingSignalResponse, PortfolioSignalsResponse,
    RecommendationResponse, RebalancingResponse,
    PaperTradeCreate, PaperTradeFromSignal, PaperTradeResponse,
    PaperPerformanceResponse, PortfolioAnalysisResponse,
    AllocationSummaryResponse
)
from backend.app.services.roboadvisor import (
    RiskAnalyzer, AllocationOptimizer, SignalGenerator
)
from backend.app.services.unified_price_service import unified_price_service

logger = logging.getLogger(__name__)

router = APIRouter()


# ============== Helper Functions ==============

def get_default_portfolio(db: Session) -> Portfolio:
    """Get the default/active portfolio."""
    portfolio = db.query(Portfolio).filter(Portfolio.is_active == True).first()
    if not portfolio:
        portfolio = db.query(Portfolio).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="No portfolio found")
    return portfolio


def get_portfolio_positions(db: Session, portfolio_id: int) -> List[Position]:
    """Get all positions for a portfolio."""
    return db.query(Position).filter(Position.portfolio_id == portfolio_id).all()


# ============== Portfolio Analysis Endpoints ==============

@router.get("/analysis/{portfolio_id}", response_model=PortfolioAnalysisResponse)
def get_portfolio_analysis(
    portfolio_id: int,
    db: Session = Depends(get_db)
):
    """
    Get comprehensive portfolio analysis including risk, allocation, and AI insights.
    """
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="Portfolio not found")

    positions = get_portfolio_positions(db, portfolio_id)

    # Initialize services
    risk_analyzer = RiskAnalyzer(db)
    allocation_optimizer = AllocationOptimizer(db)
    signal_generator = SignalGenerator(db)

    # Get current prices
    symbols = [p.stock.symbol for p in positions]
    current_prices = {}
    if symbols:
        price_data = unified_price_service.get_current_prices(symbols)
        current_prices = {s: d.get("current_price", 0) for s, d in price_data.items()}

    # Calculate risk
    risk_data = risk_analyzer.calculate_portfolio_risk(portfolio_id, positions)

    # Get allocation summary
    allocation_summary = allocation_optimizer.get_allocation_summary(
        portfolio_id, positions, current_prices
    )

    # Get AI analysis
    from backend.app.services.gemini_service import GeminiService
    gemini = GeminiService()

    portfolio_data = {
        "total_value": risk_data.get("total_value", 0),
        "position_count": len(positions),
        "average_risk": risk_data.get("overall_risk", 50)
    }

    ai_analysis = gemini.generate_portfolio_analysis(
        portfolio_data,
        risk_data.get("position_risks", []),
        allocation_summary.get("drift_data", {})
    )

    # Get pending recommendations
    recommendations = signal_generator.get_pending_recommendations(portfolio_id)
    rec_responses = []
    for rec in recommendations:
        rec_dict = {
            "id": rec.id,
            "portfolio_id": rec.portfolio_id,
            "stock_id": rec.stock_id,
            "symbol": rec.stock.symbol if rec.stock else None,
            "recommendation_type": rec.recommendation_type,
            "action": rec.action,
            "confidence": float(rec.confidence),
            "reasoning": rec.reasoning,
            "risk_level": rec.risk_level,
            "time_horizon": rec.time_horizon,
            "status": rec.status,
            "created_at": rec.created_at,
            "expires_at": rec.expires_at
        }
        rec_responses.append(RecommendationResponse(**rec_dict))

    return PortfolioAnalysisResponse(
        portfolio_id=portfolio_id,
        risk_analysis=PortfolioRiskResponse(**risk_data),
        allocation_summary=allocation_summary,
        ai_analysis=ai_analysis,
        recommendations=rec_responses,
        generated_at=datetime.now().isoformat()
    )


# ============== Risk Analysis Endpoints ==============

@router.get("/risk/{symbol}", response_model=StockRiskResponse)
def get_stock_risk(
    symbol: str,
    db: Session = Depends(get_db)
):
    """Get risk analysis for a single stock."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found")

    risk_analyzer = RiskAnalyzer(db)
    risk_data = risk_analyzer.calculate_stock_risk(stock)

    return StockRiskResponse(**risk_data)


@router.get("/risk/portfolio/{portfolio_id}", response_model=PortfolioRiskResponse)
def get_portfolio_risk(
    portfolio_id: int,
    db: Session = Depends(get_db)
):
    """Get risk analysis for entire portfolio."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="Portfolio not found")

    positions = get_portfolio_positions(db, portfolio_id)
    risk_analyzer = RiskAnalyzer(db)
    risk_data = risk_analyzer.calculate_portfolio_risk(portfolio_id, positions)

    return PortfolioRiskResponse(**risk_data)


# ============== Signal Endpoints ==============

@router.get("/signals/{symbol}", response_model=TradingSignalResponse)
def get_trading_signal(
    symbol: str,
    db: Session = Depends(get_db)
):
    """Get AI trading signal for a single stock."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found")

    portfolio = get_default_portfolio(db)
    signal_generator = SignalGenerator(db)
    signal = signal_generator.generate_signal(stock, portfolio.id)

    return TradingSignalResponse(**signal)


@router.get("/recommendations/{portfolio_id}", response_model=PortfolioSignalsResponse)
def get_portfolio_recommendations(
    portfolio_id: int,
    save_recommendations: bool = Query(False, description="Save as recommendations"),
    db: Session = Depends(get_db)
):
    """Get trading signals for all positions in portfolio."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="Portfolio not found")

    positions = get_portfolio_positions(db, portfolio_id)
    signal_generator = SignalGenerator(db)
    signals = signal_generator.generate_portfolio_signals(portfolio, positions)

    # Optionally save as recommendations
    if save_recommendations:
        for signal in signals:
            stock = db.query(Stock).filter(Stock.symbol == signal["symbol"]).first()
            if stock and signal.get("confidence", 0) >= signal_generator.confidence_threshold:
                signal_generator.save_recommendation(
                    portfolio_id, stock.id, signal
                )

    high_conf = sum(1 for s in signals if s.get("confidence", 0) >= 0.7)

    return PortfolioSignalsResponse(
        portfolio_id=portfolio_id,
        signals=[TradingSignalResponse(**s) for s in signals],
        high_confidence_signals=high_conf,
        generated_at=datetime.now().isoformat()
    )


# ============== Rebalancing Endpoints ==============

@router.get("/rebalance/{portfolio_id}", response_model=RebalancingResponse)
def get_rebalancing_recommendations(
    portfolio_id: int,
    db: Session = Depends(get_db)
):
    """Get portfolio rebalancing recommendations."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="Portfolio not found")

    positions = get_portfolio_positions(db, portfolio_id)

    # Get current prices
    symbols = [p.stock.symbol for p in positions]
    current_prices = {}
    if symbols:
        price_data = unified_price_service.get_current_prices(symbols)
        current_prices = {s: d.get("current_price", 0) for s, d in price_data.items()}

    allocation_optimizer = AllocationOptimizer(db)
    rebalance_data = allocation_optimizer.generate_rebalancing_recommendations(
        portfolio, positions, current_prices
    )

    return RebalancingResponse(**rebalance_data)


# ============== User Profile Endpoints ==============

@router.post("/profile/", response_model=UserProfileResponse)
def create_or_update_profile(
    profile_data: UserProfileCreate,
    portfolio_id: Optional[int] = Query(None, description="Portfolio ID (uses default if not specified)"),
    db: Session = Depends(get_db)
):
    """Create or update user investment profile."""
    if portfolio_id is None:
        portfolio = get_default_portfolio(db)
        portfolio_id = portfolio.id

    allocation_optimizer = AllocationOptimizer(db)
    profile = allocation_optimizer.get_or_create_profile(
        portfolio_id,
        profile_data.risk_tolerance,
        profile_data.investment_horizon,
        profile_data.rebalance_threshold
    )

    # Update if exists
    profile.risk_tolerance = profile_data.risk_tolerance
    profile.investment_horizon = profile_data.investment_horizon
    profile.rebalance_threshold = profile_data.rebalance_threshold
    db.commit()
    db.refresh(profile)

    return UserProfileResponse.model_validate(profile)


@router.get("/profile/{portfolio_id}", response_model=UserProfileResponse)
def get_profile(
    portfolio_id: int,
    db: Session = Depends(get_db)
):
    """Get user profile for portfolio."""
    profile = db.query(UserProfile).filter(
        UserProfile.portfolio_id == portfolio_id
    ).first()

    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    return UserProfileResponse.model_validate(profile)


# ============== Target Allocation Endpoints ==============

@router.post("/allocations/", response_model=List[TargetAllocationResponse])
def set_target_allocations(
    allocations_data: TargetAllocationsCreate,
    portfolio_id: Optional[int] = Query(None, description="Portfolio ID"),
    db: Session = Depends(get_db)
):
    """Set target allocations for portfolio."""
    if portfolio_id is None:
        portfolio = get_default_portfolio(db)
        portfolio_id = portfolio.id

    # Ensure profile exists
    allocation_optimizer = AllocationOptimizer(db)
    profile = allocation_optimizer.get_or_create_profile(portfolio_id)

    # Convert to dict format
    allocations_dict = {
        item.symbol: item.target_weight
        for item in allocations_data.allocations
    }

    try:
        created = allocation_optimizer.set_target_allocations(profile.id, allocations_dict)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return [
        TargetAllocationResponse(
            id=alloc.id,
            symbol=alloc.stock.symbol,
            target_weight=float(alloc.target_weight)
        )
        for alloc in created
    ]


@router.get("/allocations/{portfolio_id}", response_model=AllocationSummaryResponse)
def get_allocation_summary(
    portfolio_id: int,
    db: Session = Depends(get_db)
):
    """Get allocation summary for portfolio."""
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="Portfolio not found")

    positions = get_portfolio_positions(db, portfolio_id)

    # Get current prices
    symbols = [p.stock.symbol for p in positions]
    current_prices = {}
    if symbols:
        price_data = unified_price_service.get_current_prices(symbols)
        current_prices = {s: d.get("current_price", 0) for s, d in price_data.items()}

    allocation_optimizer = AllocationOptimizer(db)
    summary = allocation_optimizer.get_allocation_summary(
        portfolio_id, positions, current_prices
    )

    return AllocationSummaryResponse(**summary)


# ============== Paper Trading Endpoints ==============

@router.post("/paper-trade/", response_model=PaperTradeResponse)
def create_paper_trade(
    trade_data: PaperTradeCreate,
    portfolio_id: Optional[int] = Query(None, description="Portfolio ID"),
    db: Session = Depends(get_db)
):
    """Create a new paper trade."""
    if portfolio_id is None:
        portfolio = get_default_portfolio(db)
        portfolio_id = portfolio.id

    stock = db.query(Stock).filter(Stock.id == trade_data.stock_id).first()
    if not stock:
        raise HTTPException(status_code=404, detail="Stock not found")

    signal_generator = SignalGenerator(db)

    # Create a simple signal for the trade
    signal = {
        "action": trade_data.action.upper(),
        "confidence": 0.5
    }

    try:
        trade = signal_generator.execute_paper_trade(
            portfolio_id, stock, signal, trade_data.quantity, trade_data.recommendation_id
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return PaperTradeResponse(
        id=trade.id,
        portfolio_id=trade.portfolio_id,
        stock_id=trade.stock_id,
        symbol=stock.symbol,
        action=trade.action,
        quantity=float(trade.quantity),
        entry_price=float(trade.entry_price),
        exit_price=float(trade.exit_price) if trade.exit_price else None,
        entry_date=trade.entry_date,
        exit_date=trade.exit_date,
        pnl=float(trade.pnl) if trade.pnl else None,
        pnl_percent=float(trade.pnl_percent) if trade.pnl_percent else None,
        status=trade.status,
        signal_confidence=float(trade.signal_confidence) if trade.signal_confidence else None,
        recommendation_id=trade.recommendation_id
    )


@router.post("/paper-trade/from-signal/", response_model=PaperTradeResponse)
def create_paper_trade_from_signal(
    trade_data: PaperTradeFromSignal,
    portfolio_id: Optional[int] = Query(None, description="Portfolio ID"),
    db: Session = Depends(get_db)
):
    """Create a paper trade based on current AI signal."""
    if portfolio_id is None:
        portfolio = get_default_portfolio(db)
        portfolio_id = portfolio.id

    stock = db.query(Stock).filter(Stock.symbol == trade_data.symbol.upper()).first()
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {trade_data.symbol} not found")

    signal_generator = SignalGenerator(db)

    # Generate signal
    signal = signal_generator.generate_signal(stock, portfolio_id)

    if signal.get("action") == "HOLD":
        raise HTTPException(
            status_code=400,
            detail="Signal is HOLD - no trade recommended"
        )

    # Save recommendation
    recommendation = signal_generator.save_recommendation(
        portfolio_id, stock.id, signal
    )

    try:
        trade = signal_generator.execute_paper_trade(
            portfolio_id, stock, signal, trade_data.quantity, recommendation.id
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return PaperTradeResponse(
        id=trade.id,
        portfolio_id=trade.portfolio_id,
        stock_id=trade.stock_id,
        symbol=stock.symbol,
        action=trade.action,
        quantity=float(trade.quantity),
        entry_price=float(trade.entry_price),
        exit_price=None,
        entry_date=trade.entry_date,
        exit_date=None,
        pnl=None,
        pnl_percent=None,
        status=trade.status,
        signal_confidence=float(trade.signal_confidence) if trade.signal_confidence else None,
        recommendation_id=trade.recommendation_id
    )


@router.get("/paper-trades/{portfolio_id}", response_model=List[PaperTradeResponse])
def get_paper_trades(
    portfolio_id: int,
    status: Optional[str] = Query(None, description="Filter by status (open, closed)"),
    db: Session = Depends(get_db)
):
    """Get all paper trades for portfolio."""
    signal_generator = SignalGenerator(db)
    trades = signal_generator.get_paper_trades(portfolio_id, status)

    return [
        PaperTradeResponse(
            id=t.id,
            portfolio_id=t.portfolio_id,
            stock_id=t.stock_id,
            symbol=t.stock.symbol if t.stock else None,
            action=t.action,
            quantity=float(t.quantity),
            entry_price=float(t.entry_price),
            exit_price=float(t.exit_price) if t.exit_price else None,
            entry_date=t.entry_date,
            exit_date=t.exit_date,
            pnl=float(t.pnl) if t.pnl else None,
            pnl_percent=float(t.pnl_percent) if t.pnl_percent else None,
            status=t.status,
            signal_confidence=float(t.signal_confidence) if t.signal_confidence else None,
            recommendation_id=t.recommendation_id
        )
        for t in trades
    ]


@router.put("/paper-trade/{trade_id}/close", response_model=PaperTradeResponse)
def close_paper_trade(
    trade_id: int,
    exit_price: Optional[float] = Query(None, description="Exit price (uses current if not specified)"),
    db: Session = Depends(get_db)
):
    """Close an open paper trade."""
    signal_generator = SignalGenerator(db)

    try:
        trade = signal_generator.close_paper_trade(trade_id, exit_price)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return PaperTradeResponse(
        id=trade.id,
        portfolio_id=trade.portfolio_id,
        stock_id=trade.stock_id,
        symbol=trade.stock.symbol if trade.stock else None,
        action=trade.action,
        quantity=float(trade.quantity),
        entry_price=float(trade.entry_price),
        exit_price=float(trade.exit_price) if trade.exit_price else None,
        entry_date=trade.entry_date,
        exit_date=trade.exit_date,
        pnl=float(trade.pnl) if trade.pnl else None,
        pnl_percent=float(trade.pnl_percent) if trade.pnl_percent else None,
        status=trade.status,
        signal_confidence=float(trade.signal_confidence) if trade.signal_confidence else None,
        recommendation_id=trade.recommendation_id
    )


@router.get("/paper-performance/{portfolio_id}", response_model=PaperPerformanceResponse)
def get_paper_performance(
    portfolio_id: int,
    db: Session = Depends(get_db)
):
    """Get paper trading performance metrics."""
    signal_generator = SignalGenerator(db)
    performance = signal_generator.get_paper_performance(portfolio_id)

    return PaperPerformanceResponse(**performance)


# ============== Recommendation Status Endpoints ==============

@router.put("/recommendation/{recommendation_id}/status")
def update_recommendation_status(
    recommendation_id: int,
    status: str = Query(..., pattern="^(pending|accepted|rejected|executed|expired)$"),
    db: Session = Depends(get_db)
):
    """Update recommendation status."""
    signal_generator = SignalGenerator(db)

    try:
        recommendation = signal_generator.update_recommendation_status(
            recommendation_id, status
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return {
        "id": recommendation.id,
        "status": recommendation.status,
        "updated_at": recommendation.updated_at.isoformat()
    }

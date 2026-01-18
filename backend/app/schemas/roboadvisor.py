"""
Pydantic schemas for roboadvisor API endpoints.
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from decimal import Decimal


# ============== User Profile Schemas ==============

class UserProfileCreate(BaseModel):
    """Schema for creating/updating user profile."""
    risk_tolerance: str = Field(default="moderate", pattern="^(conservative|moderate|aggressive)$")
    investment_horizon: int = Field(default=5, ge=1, le=30)
    rebalance_threshold: float = Field(default=5.0, ge=1.0, le=20.0)


class UserProfileResponse(BaseModel):
    """Response schema for user profile."""
    id: int
    portfolio_id: int
    risk_tolerance: str
    investment_horizon: int
    rebalance_threshold: float
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ============== Target Allocation Schemas ==============

class TargetAllocationItem(BaseModel):
    """Single target allocation item."""
    symbol: str
    target_weight: float = Field(ge=0, le=100)


class TargetAllocationsCreate(BaseModel):
    """Schema for setting target allocations."""
    allocations: List[TargetAllocationItem]


class TargetAllocationResponse(BaseModel):
    """Response for a single target allocation."""
    id: int
    symbol: str
    target_weight: float

    class Config:
        from_attributes = True


# ============== Risk Analysis Schemas ==============

class StockRiskResponse(BaseModel):
    """Risk analysis response for a single stock."""
    symbol: str
    overall_risk: float
    volatility_score: float
    beta: float
    beta_score: float
    sentiment_score: float
    risk_level: str
    calculated_at: str
    weight: Optional[float] = None
    position_value: Optional[float] = None


class PortfolioRiskResponse(BaseModel):
    """Risk analysis response for entire portfolio."""
    portfolio_id: int
    overall_risk: float
    weighted_risk: float
    concentration_risk: float
    risk_level: str
    total_value: float
    position_count: int
    position_risks: List[StockRiskResponse]
    calculated_at: str


# ============== Signal Schemas ==============

class TradingSignalResponse(BaseModel):
    """Trading signal response."""
    symbol: str
    action: str  # BUY, SELL, HOLD
    confidence: float
    reasoning: str
    key_factors: List[str]
    risk_level: str
    time_horizon: str
    generated_at: str
    risk_data: Optional[Dict[str, Any]] = None
    sentiment_data: Optional[Dict[str, Any]] = None
    price_trend: Optional[Dict[str, Any]] = None


class PortfolioSignalsResponse(BaseModel):
    """Response for portfolio-wide signals."""
    portfolio_id: int
    signals: List[TradingSignalResponse]
    high_confidence_signals: int
    generated_at: str


# ============== Recommendation Schemas ==============

class RecommendationResponse(BaseModel):
    """Recommendation response schema."""
    id: int
    portfolio_id: int
    stock_id: int
    symbol: Optional[str] = None
    recommendation_type: str
    action: str
    confidence: float
    reasoning: Optional[str] = None
    risk_level: Optional[str] = None
    time_horizon: Optional[str] = None
    status: str
    created_at: datetime
    expires_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ============== Rebalancing Schemas ==============

class RebalanceRecommendation(BaseModel):
    """Single rebalancing recommendation."""
    symbol: str
    action: str  # BUY, SELL
    direction: str  # Overweight, Underweight
    current_weight: float
    target_weight: float
    drift_percent: float
    trade_value: float
    quantity: float
    current_price: float
    priority: str


class RebalancingResponse(BaseModel):
    """Portfolio rebalancing response."""
    portfolio_id: int
    rebalancing_needed: bool
    threshold: float
    total_value: float
    recommendations: List[RebalanceRecommendation]
    drift_summary: Dict[str, Any]
    generated_at: str


# ============== Paper Trade Schemas ==============

class PaperTradeCreate(BaseModel):
    """Schema for creating a paper trade."""
    stock_id: int
    action: str = Field(pattern="^(buy|sell)$")
    quantity: float = Field(gt=0)
    recommendation_id: Optional[int] = None


class PaperTradeFromSignal(BaseModel):
    """Schema for creating paper trade from signal."""
    symbol: str
    quantity: float = Field(gt=0)


class PaperTradeResponse(BaseModel):
    """Paper trade response schema."""
    id: int
    portfolio_id: int
    stock_id: int
    symbol: Optional[str] = None
    action: str
    quantity: float
    entry_price: float
    exit_price: Optional[float] = None
    entry_date: datetime
    exit_date: Optional[datetime] = None
    pnl: Optional[float] = None
    pnl_percent: Optional[float] = None
    status: str
    signal_confidence: Optional[float] = None
    recommendation_id: Optional[int] = None

    class Config:
        from_attributes = True


class PaperPerformanceResponse(BaseModel):
    """Paper trading performance metrics."""
    portfolio_id: int
    total_trades: int
    open_trades: int
    closed_trades: int
    winning_trades: int
    losing_trades: int
    win_rate: float
    total_realized_pnl: float
    unrealized_pnl: float
    average_win: float
    average_loss: float
    profit_factor: float
    high_confidence_accuracy: float
    calculated_at: str


# ============== Portfolio Analysis Schemas ==============

class PortfolioAnalysisResponse(BaseModel):
    """Comprehensive portfolio analysis response."""
    portfolio_id: int
    risk_analysis: PortfolioRiskResponse
    allocation_summary: Dict[str, Any]
    ai_analysis: Dict[str, Any]
    recommendations: List[RecommendationResponse]
    generated_at: str


class AllocationSummaryResponse(BaseModel):
    """Allocation summary response."""
    portfolio_id: int
    has_targets: bool
    risk_tolerance: str
    rebalance_threshold: float
    total_value: float
    position_count: int
    current_allocation: Dict[str, Any]
    drift_data: Dict[str, Any]
    max_drift: float
    needs_rebalancing: bool

from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
from backend.app.schemas.stock import Stock


class PositionBase(BaseModel):
    """Base position schema with common attributes."""
    shares: float = Field(..., gt=0, description="Number of shares")
    average_cost: float = Field(..., gt=0, description="Average cost per share")


class PositionCreate(PositionBase):
    """Schema for creating a new position."""
    stock_symbol: str = Field(..., description="Stock symbol")


class PositionUpdate(BaseModel):
    """Schema for updating a position."""
    shares: Optional[float] = Field(None, gt=0)
    average_cost: Optional[float] = Field(None, gt=0)


class PositionAddShares(BaseModel):
    """Schema for adding shares to existing position."""
    shares: float = Field(..., gt=0, description="Number of shares to add")
    cost_per_share: float = Field(..., gt=0, description="Cost per share for new purchase")


class Position(PositionBase):
    """Full position schema with all fields."""
    id: int
    portfolio_id: int
    stock_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PositionWithDetails(Position):
    """Position with stock details and calculated metrics."""
    stock: Stock
    current_price: Optional[float] = Field(None, description="Current stock price")
    total_cost: float = Field(description="Total investment (shares * average_cost)")
    current_value: Optional[float] = Field(None, description="Current value (shares * current_price)")
    gain_loss: Optional[float] = Field(None, description="Gain/loss in dollars")
    gain_loss_percent: Optional[float] = Field(None, description="Gain/loss percentage")
    day_change: Optional[float] = Field(None, description="Today's price change")
    day_change_percent: Optional[float] = Field(None, description="Today's price change percentage")

    class Config:
        from_attributes = True

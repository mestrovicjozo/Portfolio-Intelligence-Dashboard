from pydantic import BaseModel, Field
from datetime import date
from typing import Optional


class StockPriceBase(BaseModel):
    """Base stock price schema."""
    date: date
    open: float = Field(..., gt=0)
    close: float = Field(..., gt=0)
    high: float = Field(..., gt=0)
    low: float = Field(..., gt=0)
    volume: int = Field(..., ge=0)


class StockPriceCreate(StockPriceBase):
    """Schema for creating a stock price."""
    stock_id: int


class StockPrice(StockPriceBase):
    """Schema for stock price response."""
    id: int
    stock_id: int

    class Config:
        from_attributes = True


class StockPriceWithChange(StockPrice):
    """Stock price with calculated changes."""
    price_change: Optional[float] = None
    price_change_percent: Optional[float] = None

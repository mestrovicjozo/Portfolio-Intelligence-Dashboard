from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class StockBase(BaseModel):
    """Base stock schema."""
    symbol: str = Field(..., max_length=10, description="Stock ticker symbol")
    name: str = Field(..., max_length=255, description="Company name")
    sector: Optional[str] = Field(None, max_length=100, description="Industry sector")


class StockCreate(StockBase):
    """Schema for creating a stock."""
    pass


class StockUpdate(BaseModel):
    """Schema for updating a stock."""
    name: Optional[str] = Field(None, max_length=255)
    sector: Optional[str] = Field(None, max_length=100)


class Stock(StockBase):
    """Schema for stock response."""
    id: int
    added_at: datetime

    class Config:
        from_attributes = True


class StockWithPrice(Stock):
    """Stock with current price information."""
    current_price: Optional[float] = None
    price_change: Optional[float] = None
    price_change_percent: Optional[float] = None

from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List


class PortfolioBase(BaseModel):
    """Base portfolio schema with common attributes."""
    name: str = Field(..., min_length=1, max_length=255, description="Portfolio name")
    description: Optional[str] = Field(None, max_length=500, description="Portfolio description")


class PortfolioCreate(PortfolioBase):
    """Schema for creating a new portfolio."""
    pass


class PortfolioUpdate(BaseModel):
    """Schema for updating a portfolio."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None


class Portfolio(PortfolioBase):
    """Full portfolio schema with all fields."""
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PortfolioWithStats(Portfolio):
    """Portfolio with calculated statistics."""
    total_value: float = Field(description="Total portfolio value")
    total_cost: float = Field(description="Total cost basis")
    total_gain_loss: float = Field(description="Total gain/loss")
    total_gain_loss_percent: float = Field(description="Total gain/loss percentage")
    position_count: int = Field(description="Number of positions")

    class Config:
        from_attributes = True

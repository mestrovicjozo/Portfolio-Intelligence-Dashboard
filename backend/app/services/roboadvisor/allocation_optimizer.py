"""
Allocation optimizer for roboadvisor.

Handles:
- Target allocation management
- Drift detection and rebalancing recommendations
- Position sizing suggestions
"""

from typing import Dict, Any, List, Optional
from decimal import Decimal
from datetime import datetime
from sqlalchemy.orm import Session
import logging

from backend.app.models import (
    Stock, Position, Portfolio,
    UserProfile, TargetAllocation
)

logger = logging.getLogger(__name__)


class AllocationOptimizer:
    """
    Optimizes portfolio allocation based on targets and drift thresholds.
    """

    def __init__(self, db: Session):
        self.db = db

    def get_or_create_profile(
        self,
        portfolio_id: int,
        risk_tolerance: str = "moderate",
        investment_horizon: int = 5,
        rebalance_threshold: float = 5.0
    ) -> UserProfile:
        """
        Get existing profile or create new one.

        Args:
            portfolio_id: Portfolio ID
            risk_tolerance: Risk tolerance level
            investment_horizon: Investment horizon in years
            rebalance_threshold: Rebalance threshold percentage

        Returns:
            UserProfile instance
        """
        profile = self.db.query(UserProfile).filter(
            UserProfile.portfolio_id == portfolio_id
        ).first()

        if not profile:
            profile = UserProfile(
                portfolio_id=portfolio_id,
                risk_tolerance=risk_tolerance,
                investment_horizon=investment_horizon,
                rebalance_threshold=Decimal(str(rebalance_threshold))
            )
            self.db.add(profile)
            self.db.commit()
            self.db.refresh(profile)

        return profile

    def set_target_allocations(
        self,
        profile_id: int,
        allocations: Dict[str, float]
    ) -> List[TargetAllocation]:
        """
        Set target allocations for portfolio.

        Args:
            profile_id: User profile ID
            allocations: Dict of symbol -> target weight percentage

        Returns:
            List of TargetAllocation instances
        """
        # Validate total equals 100%
        total = sum(allocations.values())
        if abs(total - 100) > 0.1:
            raise ValueError(f"Target allocations must sum to 100%, got {total}%")

        # Clear existing allocations
        self.db.query(TargetAllocation).filter(
            TargetAllocation.profile_id == profile_id
        ).delete()

        # Create new allocations
        created = []
        for symbol, weight in allocations.items():
            stock = self.db.query(Stock).filter(
                Stock.symbol == symbol.upper()
            ).first()

            if not stock:
                logger.warning(f"Stock {symbol} not found, skipping allocation")
                continue

            allocation = TargetAllocation(
                profile_id=profile_id,
                stock_id=stock.id,
                target_weight=Decimal(str(weight))
            )
            self.db.add(allocation)
            created.append(allocation)

        self.db.commit()

        for alloc in created:
            self.db.refresh(alloc)

        return created

    def calculate_current_allocation(
        self,
        positions: List[Position],
        current_prices: Dict[str, float] = None
    ) -> Dict[str, Dict[str, Any]]:
        """
        Calculate current allocation based on positions.

        Args:
            positions: List of position instances
            current_prices: Optional dict of current prices

        Returns:
            Dict of symbol -> allocation data
        """
        if not positions:
            return {}

        # Calculate total portfolio value
        allocations = {}
        total_value = 0

        for position in positions:
            symbol = position.stock.symbol

            # Use provided price or average cost
            price = current_prices.get(symbol) if current_prices else None
            if price is None:
                price = float(position.average_cost)

            position_value = float(position.shares) * price
            total_value += position_value

            allocations[symbol] = {
                "symbol": symbol,
                "quantity": float(position.shares),
                "price": price,
                "value": position_value,
                "stock_id": position.stock_id
            }

        # Calculate weights
        for symbol, data in allocations.items():
            data["current_weight"] = (data["value"] / total_value * 100) if total_value > 0 else 0

        return allocations

    def calculate_allocation_drift(
        self,
        portfolio_id: int,
        current_allocation: Dict[str, Dict[str, Any]]
    ) -> Dict[str, Dict[str, Any]]:
        """
        Calculate drift between current and target allocation.

        Args:
            portfolio_id: Portfolio ID
            current_allocation: Current allocation data

        Returns:
            Dict of symbol -> drift data
        """
        # Get user profile and targets
        profile = self.db.query(UserProfile).filter(
            UserProfile.portfolio_id == portfolio_id
        ).first()

        if not profile:
            return {}

        # Get target allocations
        targets = {
            ta.stock.symbol: float(ta.target_weight)
            for ta in profile.target_allocations
        }

        # Calculate drift
        drift_data = {}
        all_symbols = set(current_allocation.keys()) | set(targets.keys())

        for symbol in all_symbols:
            current = current_allocation.get(symbol, {}).get("current_weight", 0)
            target = targets.get(symbol, 0)
            drift = current - target

            drift_data[symbol] = {
                "symbol": symbol,
                "current_weight": round(current, 2),
                "target_weight": round(target, 2),
                "drift": round(drift, 2),
                "drift_abs": round(abs(drift), 2),
                "action_needed": self._get_drift_action(drift, profile.rebalance_threshold)
            }

        return drift_data

    def generate_rebalancing_recommendations(
        self,
        portfolio: Portfolio,
        positions: List[Position],
        current_prices: Dict[str, float] = None
    ) -> Dict[str, Any]:
        """
        Generate rebalancing recommendations based on drift.

        Args:
            portfolio: Portfolio instance
            positions: List of positions
            current_prices: Optional current prices

        Returns:
            Dict with rebalancing recommendations
        """
        profile = self.db.query(UserProfile).filter(
            UserProfile.portfolio_id == portfolio.id
        ).first()

        if not profile or not profile.target_allocations:
            return {
                "portfolio_id": portfolio.id,
                "rebalancing_needed": False,
                "threshold": 5.0,
                "total_value": 0.0,
                "recommendations": [],
                "drift_summary": {},
                "generated_at": datetime.now().isoformat()
            }

        # Calculate current allocation
        current = self.calculate_current_allocation(positions, current_prices)

        if not current:
            return {
                "portfolio_id": portfolio.id,
                "rebalancing_needed": False,
                "threshold": float(profile.rebalance_threshold),
                "total_value": 0.0,
                "recommendations": [],
                "drift_summary": {},
                "generated_at": datetime.now().isoformat()
            }

        # Calculate total value
        total_value = sum(pos["value"] for pos in current.values())

        # Calculate drift
        drift_data = self.calculate_allocation_drift(portfolio.id, current)

        # Generate recommendations
        recommendations = []
        rebalancing_needed = False
        threshold = float(profile.rebalance_threshold)

        for symbol, drift in drift_data.items():
            if drift["drift_abs"] >= threshold:
                rebalancing_needed = True

                # Calculate action
                if drift["drift"] > 0:
                    action = "SELL"
                    direction = "Overweight"
                elif drift["drift"] < 0:
                    action = "BUY"
                    direction = "Underweight"
                else:
                    continue

                # Calculate amount to trade
                target_value = total_value * (drift["target_weight"] / 100)
                current_value = current.get(symbol, {}).get("value", 0)
                trade_value = abs(target_value - current_value)

                price = current.get(symbol, {}).get("price", 0)
                if price > 0:
                    quantity = trade_value / price
                else:
                    quantity = 0

                recommendations.append({
                    "symbol": symbol,
                    "action": action,
                    "direction": direction,
                    "current_weight": drift["current_weight"],
                    "target_weight": drift["target_weight"],
                    "drift_percent": drift["drift"],
                    "trade_value": round(trade_value, 2),
                    "quantity": round(quantity, 4),
                    "current_price": price,
                    "priority": "high" if drift["drift_abs"] >= threshold * 2 else "medium"
                })

        # Sort by priority and drift magnitude
        recommendations.sort(key=lambda x: (x["priority"] == "high", x["drift_percent"]), reverse=True)

        return {
            "portfolio_id": portfolio.id,
            "rebalancing_needed": rebalancing_needed,
            "threshold": threshold,
            "total_value": round(total_value, 2),
            "recommendations": recommendations,
            "drift_summary": drift_data,
            "generated_at": datetime.now().isoformat()
        }

    def suggest_position_size(
        self,
        portfolio_value: float,
        risk_score: float,
        target_weight: float,
        current_price: float
    ) -> Dict[str, Any]:
        """
        Suggest position size based on risk and targets.

        Args:
            portfolio_value: Total portfolio value
            risk_score: Stock's risk score (0-100)
            target_weight: Target weight percentage
            current_price: Current stock price

        Returns:
            Dict with position size recommendation
        """
        # Adjust target based on risk
        # Higher risk = potentially reduce allocation
        risk_adjustment = 1.0 - (risk_score / 200)  # Max 50% reduction for very high risk
        adjusted_weight = target_weight * risk_adjustment

        # Calculate position value and shares
        position_value = portfolio_value * (adjusted_weight / 100)
        shares = position_value / current_price if current_price > 0 else 0

        return {
            "target_weight": round(target_weight, 2),
            "risk_adjusted_weight": round(adjusted_weight, 2),
            "risk_adjustment": round(risk_adjustment, 3),
            "position_value": round(position_value, 2),
            "shares": round(shares, 4),
            "current_price": round(current_price, 2)
        }

    def _get_drift_action(self, drift: float, threshold: Decimal) -> str:
        """Determine action needed based on drift."""
        threshold_float = float(threshold)

        if abs(drift) < threshold_float:
            return "none"
        elif drift > 0:
            return "reduce"
        else:
            return "increase"

    def get_allocation_summary(
        self,
        portfolio_id: int,
        positions: List[Position],
        current_prices: Dict[str, float] = None
    ) -> Dict[str, Any]:
        """
        Get comprehensive allocation summary.

        Args:
            portfolio_id: Portfolio ID
            positions: List of positions
            current_prices: Optional current prices

        Returns:
            Complete allocation summary
        """
        profile = self.db.query(UserProfile).filter(
            UserProfile.portfolio_id == portfolio_id
        ).first()

        current = self.calculate_current_allocation(positions, current_prices)
        drift = self.calculate_allocation_drift(portfolio_id, current) if profile else {}

        # Calculate metrics
        total_value = sum(pos["value"] for pos in current.values())
        max_drift = max((d["drift_abs"] for d in drift.values()), default=0)

        return {
            "portfolio_id": portfolio_id,
            "has_targets": profile is not None and bool(profile.target_allocations),
            "risk_tolerance": profile.risk_tolerance if profile else "unknown",
            "rebalance_threshold": float(profile.rebalance_threshold) if profile else 5.0,
            "total_value": round(total_value, 2),
            "position_count": len(positions),
            "current_allocation": current,
            "drift_data": drift,
            "max_drift": round(max_drift, 2),
            "needs_rebalancing": max_drift >= (float(profile.rebalance_threshold) if profile else 5.0)
        }

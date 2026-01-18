"""
Roboadvisor service module.

Provides AI-powered portfolio recommendations including:
- Risk analysis (volatility, beta, sentiment)
- Portfolio rebalancing suggestions
- Buy/sell signals with confidence scores
- Paper trading simulation
"""

from backend.app.services.roboadvisor.risk_analyzer import RiskAnalyzer
from backend.app.services.roboadvisor.allocation_optimizer import AllocationOptimizer
from backend.app.services.roboadvisor.signal_generator import SignalGenerator

__all__ = ["RiskAnalyzer", "AllocationOptimizer", "SignalGenerator"]

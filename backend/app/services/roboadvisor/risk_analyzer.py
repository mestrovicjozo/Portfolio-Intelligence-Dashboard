"""
Risk analyzer for roboadvisor.

Calculates risk scores based on:
- Volatility: Annualized standard deviation of daily returns (30 days)
- Beta: Covariance with SPY / Variance of SPY (90 days)
- Sentiment Risk: Inverse of average news sentiment (7 days)

Overall Risk = (0.4 × Volatility) + (0.3 × Beta Risk) + (0.3 × Sentiment Risk)
"""

import numpy as np
from typing import Dict, Any, List, Optional
from datetime import date, timedelta
from sqlalchemy.orm import Session
import logging

from backend.app.models import Stock, StockPrice, NewsArticle, Position, RiskScore
from backend.app.services.batch_price_service import batch_price_service

logger = logging.getLogger(__name__)


class RiskAnalyzer:
    """
    Analyzes risk for individual stocks and portfolios.

    Risk Score Components:
    - Volatility (40%): Historical price volatility
    - Beta (30%): Market correlation
    - Sentiment (30%): News sentiment analysis
    """

    def __init__(self, db: Session):
        self.db = db
        self._spy_returns = None  # Cached SPY returns

    def calculate_stock_risk(
        self,
        stock: Stock,
        days_volatility: int = 30,
        days_beta: int = 90,
        days_sentiment: int = 7
    ) -> Dict[str, Any]:
        """
        Calculate comprehensive risk score for a stock.

        Args:
            stock: Stock model instance
            days_volatility: Days for volatility calculation
            days_beta: Days for beta calculation
            days_sentiment: Days for sentiment analysis

        Returns:
            Dict with risk scores and components
        """
        # Get price data
        prices = self._get_price_history(stock.id, max(days_volatility, days_beta))

        if len(prices) < 10:
            logger.warning(f"Insufficient price data for {stock.symbol}")
            return self._default_risk_score(stock.symbol, "Insufficient price data")

        # Calculate components
        volatility_score = self._calculate_volatility_score(prices[:days_volatility])
        beta, beta_score = self._calculate_beta(prices[:days_beta], stock.symbol)
        sentiment_score = self._calculate_sentiment_risk(stock.id, days_sentiment)

        # Calculate overall risk (weighted average)
        overall_risk = (
            0.4 * volatility_score +
            0.3 * beta_score +
            0.3 * sentiment_score
        )

        # Normalize to 0-100 scale
        overall_risk = min(100, max(0, overall_risk))

        return {
            "symbol": stock.symbol,
            "overall_risk": round(overall_risk, 2),
            "volatility_score": round(volatility_score, 2),
            "beta": round(beta, 2),
            "beta_score": round(beta_score, 2),
            "sentiment_score": round(sentiment_score, 2),
            "risk_level": self._get_risk_level(overall_risk),
            "calculated_at": date.today().isoformat()
        }

    def calculate_portfolio_risk(
        self,
        portfolio_id: int,
        positions: List[Position]
    ) -> Dict[str, Any]:
        """
        Calculate aggregate risk for entire portfolio.

        Args:
            portfolio_id: Portfolio ID
            positions: List of position model instances

        Returns:
            Dict with portfolio risk metrics
        """
        if not positions:
            return {
                "portfolio_id": portfolio_id,
                "overall_risk": 0,
                "weighted_risk": 0,
                "concentration_risk": 0,
                "risk_level": "unknown",
                "total_value": 0,
                "position_count": 0,
                "position_risks": [],
                "error": "No positions in portfolio",
                "calculated_at": date.today().isoformat()
            }

        # Calculate total portfolio value
        total_value = sum(
            float(p.shares) * float(p.average_cost)
            for p in positions
        )

        if total_value <= 0:
            return self._default_portfolio_risk(portfolio_id, "Invalid portfolio value")

        # Calculate weighted risk for each position
        position_risks = []
        weighted_risk = 0

        for position in positions:
            stock = position.stock
            position_value = float(position.shares) * float(position.average_cost)
            weight = (position_value / total_value) * 100

            risk_data = self.calculate_stock_risk(stock)
            risk_data["weight"] = round(weight, 2)
            risk_data["position_value"] = round(position_value, 2)

            position_risks.append(risk_data)
            weighted_risk += risk_data["overall_risk"] * (weight / 100)

        # Calculate concentration risk
        concentration_risk = self._calculate_concentration_risk(position_risks)

        # Adjust overall risk for concentration
        overall_risk = weighted_risk * (1 + concentration_risk / 100)
        overall_risk = min(100, max(0, overall_risk))

        return {
            "portfolio_id": portfolio_id,
            "overall_risk": round(overall_risk, 2),
            "weighted_risk": round(weighted_risk, 2),
            "concentration_risk": round(concentration_risk, 2),
            "risk_level": self._get_risk_level(overall_risk),
            "total_value": round(total_value, 2),
            "position_count": len(positions),
            "position_risks": position_risks,
            "calculated_at": date.today().isoformat()
        }

    def _get_price_history(
        self,
        stock_id: int,
        days: int
    ) -> List[Dict[str, Any]]:
        """Get historical prices from database."""
        start_date = date.today() - timedelta(days=days + 10)  # Extra buffer

        prices = self.db.query(StockPrice).filter(
            StockPrice.stock_id == stock_id,
            StockPrice.date >= start_date
        ).order_by(StockPrice.date.desc()).all()

        return [
            {
                "date": p.date,
                "close": float(p.close),
                "volume": p.volume
            }
            for p in prices
        ]

    def _calculate_volatility_score(self, prices: List[Dict]) -> float:
        """
        Calculate volatility score based on standard deviation of returns.

        Returns score 0-100 where higher = more volatile = more risky.
        """
        if len(prices) < 5:
            return 50.0  # Default moderate risk

        # Calculate daily returns
        closes = [p["close"] for p in prices]
        returns = []

        for i in range(1, len(closes)):
            if closes[i] > 0:
                daily_return = (closes[i-1] - closes[i]) / closes[i]
                returns.append(daily_return)

        if not returns:
            return 50.0

        # Calculate annualized volatility
        daily_vol = np.std(returns)
        annual_vol = daily_vol * np.sqrt(252)  # Annualize

        # Convert to 0-100 score
        # Typical range: 10% (low) to 60% (high) annual volatility
        score = (annual_vol / 0.6) * 100
        return min(100, max(0, score))

    def _calculate_beta(
        self,
        stock_prices: List[Dict],
        symbol: str
    ) -> tuple:
        """
        Calculate beta relative to SPY (market proxy).

        Returns (beta value, beta risk score 0-100).
        """
        if len(stock_prices) < 20:
            return 1.0, 50.0  # Default market beta

        # Get or cache SPY returns
        if self._spy_returns is None:
            self._spy_returns = self._get_spy_returns(len(stock_prices))

        if not self._spy_returns:
            return 1.0, 50.0

        # Calculate stock returns
        stock_returns = self._calculate_returns(stock_prices)

        if len(stock_returns) < 10 or len(self._spy_returns) < 10:
            return 1.0, 50.0

        # Align lengths
        min_len = min(len(stock_returns), len(self._spy_returns))
        stock_returns = stock_returns[:min_len]
        spy_returns = self._spy_returns[:min_len]

        # Calculate beta: Cov(stock, market) / Var(market)
        covariance = np.cov(stock_returns, spy_returns)[0][1]
        market_variance = np.var(spy_returns)

        if market_variance == 0:
            return 1.0, 50.0

        beta = covariance / market_variance

        # Convert beta to risk score
        # Beta < 0.5: low risk, Beta 0.5-1.5: moderate, Beta > 1.5: high
        if beta < 0:
            beta_score = 80  # Negative beta is unusual, moderate-high risk
        elif beta < 0.5:
            beta_score = beta * 60  # 0-30
        elif beta <= 1.5:
            beta_score = 30 + (beta - 0.5) * 40  # 30-70
        else:
            beta_score = 70 + min(30, (beta - 1.5) * 20)  # 70-100

        return beta, beta_score

    def _get_spy_returns(self, days: int) -> List[float]:
        """Fetch SPY returns for beta calculation."""
        try:
            # Use batch service to get SPY data
            spy_data = batch_price_service.fetch_historical_prices(["SPY"], days=days + 10)
            spy_prices = spy_data.get("SPY", [])

            if not spy_prices:
                return []

            return self._calculate_returns(spy_prices)

        except Exception as e:
            logger.warning(f"Could not fetch SPY data for beta: {e}")
            return []

    def _calculate_returns(self, prices: List[Dict]) -> List[float]:
        """Calculate daily returns from price list."""
        if not prices:
            return []

        returns = []
        closes = [p["close"] for p in prices]

        for i in range(1, len(closes)):
            if closes[i] > 0:
                daily_return = (closes[i-1] - closes[i]) / closes[i]
                returns.append(daily_return)

        return returns

    def _calculate_sentiment_risk(self, stock_id: int, days: int) -> float:
        """
        Calculate risk score based on news sentiment.

        Negative sentiment = higher risk.
        Returns score 0-100.
        """
        start_date = date.today() - timedelta(days=days)

        # Get articles related to this stock
        from backend.app.models import ArticleStock

        articles = self.db.query(NewsArticle).join(
            ArticleStock,
            NewsArticle.id == ArticleStock.article_id
        ).filter(
            ArticleStock.stock_id == stock_id,
            NewsArticle.published_at >= start_date,
            NewsArticle.sentiment_score.isnot(None)
        ).all()

        if not articles:
            return 50.0  # Neutral if no news

        # Calculate average sentiment (-1 to 1)
        avg_sentiment = sum(float(a.sentiment_score) for a in articles) / len(articles)

        # Convert to risk score (inverse relationship)
        # Sentiment 1 (very positive) -> Risk 20
        # Sentiment 0 (neutral) -> Risk 50
        # Sentiment -1 (very negative) -> Risk 80
        risk_score = 50 - (avg_sentiment * 30)

        return max(0, min(100, risk_score))

    def _calculate_concentration_risk(self, position_risks: List[Dict]) -> float:
        """
        Calculate concentration risk based on position weights.

        High concentration in few stocks = higher risk.
        """
        if not position_risks:
            return 0.0

        weights = [p["weight"] for p in position_risks]

        # Calculate Herfindahl-Hirschman Index (HHI)
        hhi = sum(w ** 2 for w in weights)

        # HHI ranges from 10000/n (equal weights) to 10000 (single stock)
        # Normalize to 0-20 range for concentration risk adjustment
        n = len(weights)
        min_hhi = 10000 / n if n > 0 else 10000
        max_hhi = 10000

        if max_hhi == min_hhi:
            return 0.0

        concentration = ((hhi - min_hhi) / (max_hhi - min_hhi)) * 20

        return concentration

    def _get_risk_level(self, score: float) -> str:
        """Convert numeric risk score to risk level string."""
        if score < 30:
            return "low"
        elif score < 60:
            return "moderate"
        elif score < 80:
            return "high"
        else:
            return "very_high"

    def _default_risk_score(self, symbol: str, reason: str) -> Dict[str, Any]:
        """Return default risk score when calculation fails."""
        return {
            "symbol": symbol,
            "overall_risk": 50.0,
            "volatility_score": 50.0,
            "beta": 1.0,
            "beta_score": 50.0,
            "sentiment_score": 50.0,
            "risk_level": "unknown",
            "note": reason,
            "calculated_at": date.today().isoformat()
        }

    def _default_portfolio_risk(self, portfolio_id: int, reason: str) -> Dict[str, Any]:
        """Return default portfolio risk when calculation fails."""
        return {
            "portfolio_id": portfolio_id,
            "overall_risk": 50.0,
            "weighted_risk": 50.0,
            "concentration_risk": 0.0,
            "risk_level": "unknown",
            "total_value": 0.0,
            "position_count": 0,
            "position_risks": [],
            "note": reason,
            "calculated_at": date.today().isoformat()
        }

    def save_risk_score(
        self,
        portfolio_id: int,
        stock_id: int,
        risk_data: Dict[str, Any]
    ) -> RiskScore:
        """Save risk score to database."""
        risk_score = RiskScore(
            portfolio_id=portfolio_id,
            stock_id=stock_id,
            score_date=date.today(),
            volatility_score=risk_data.get("volatility_score"),
            sentiment_score=risk_data.get("sentiment_score"),
            beta=risk_data.get("beta"),
            overall_risk=risk_data.get("overall_risk", 50.0)
        )

        self.db.add(risk_score)
        self.db.commit()
        self.db.refresh(risk_score)

        return risk_score

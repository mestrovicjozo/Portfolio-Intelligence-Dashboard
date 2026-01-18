"""
Signal generator for roboadvisor.

Generates AI-powered trading signals using:
- Risk analysis data
- Sentiment trends
- Price momentum
- Gemini AI for reasoning
"""

from typing import Dict, Any, List, Optional
from datetime import datetime, date, timedelta
from decimal import Decimal
from sqlalchemy.orm import Session
import logging

from backend.app.models import (
    Stock, StockPrice, NewsArticle, ArticleStock,
    Position, Portfolio, Recommendation, PaperTrade
)
from backend.app.services.gemini_service import GeminiService
from backend.app.services.roboadvisor.risk_analyzer import RiskAnalyzer

logger = logging.getLogger(__name__)


class SignalGenerator:
    """
    Generates trading signals using AI and market data analysis.
    """

    def __init__(self, db: Session, confidence_threshold: float = 0.6):
        self.db = db
        self.confidence_threshold = confidence_threshold
        self.gemini = GeminiService()
        self.risk_analyzer = RiskAnalyzer(db)

    def generate_signal(
        self,
        stock: Stock,
        portfolio_id: int
    ) -> Dict[str, Any]:
        """
        Generate trading signal for a stock.

        Args:
            stock: Stock model instance
            portfolio_id: Portfolio ID for context

        Returns:
            Dict with signal data
        """
        # Gather analysis data
        risk_data = self.risk_analyzer.calculate_stock_risk(stock)
        sentiment_data = self._get_sentiment_data(stock.id)
        price_trend = self._get_price_trend(stock.id)
        news_context = self._get_recent_news(stock.id)

        # Generate signal using Gemini
        signal = self.gemini.generate_trading_signal(
            symbol=stock.symbol,
            risk_data=risk_data,
            sentiment_data=sentiment_data,
            price_trend=price_trend,
            news_context=news_context
        )

        # Add timestamp
        signal["generated_at"] = datetime.now().isoformat()

        # Add supporting data
        signal["risk_data"] = risk_data
        signal["sentiment_data"] = sentiment_data
        signal["price_trend"] = price_trend

        return signal

    def generate_portfolio_signals(
        self,
        portfolio: Portfolio,
        positions: List[Position]
    ) -> List[Dict[str, Any]]:
        """
        Generate signals for all positions in portfolio.

        Args:
            portfolio: Portfolio instance
            positions: List of position instances

        Returns:
            List of signals for each position
        """
        signals = []

        for position in positions:
            signal = self.generate_signal(position.stock, portfolio.id)
            signal["position_id"] = position.id
            signal["quantity"] = float(position.shares)
            signals.append(signal)

        # Sort by confidence (highest first)
        signals.sort(key=lambda x: x.get("confidence", 0), reverse=True)

        return signals

    def save_recommendation(
        self,
        portfolio_id: int,
        stock_id: int,
        signal: Dict[str, Any],
        recommendation_type: str = "signal"
    ) -> Recommendation:
        """
        Save signal as recommendation to database.

        Args:
            portfolio_id: Portfolio ID
            stock_id: Stock ID
            signal: Signal data
            recommendation_type: Type of recommendation

        Returns:
            Recommendation instance
        """
        recommendation = Recommendation(
            portfolio_id=portfolio_id,
            stock_id=stock_id,
            recommendation_type=recommendation_type,
            action=signal.get("action", "HOLD"),
            confidence=Decimal(str(signal.get("confidence", 0))),
            reasoning=signal.get("reasoning", ""),
            risk_level=signal.get("risk_level"),
            time_horizon=signal.get("time_horizon"),
            status="pending",
            expires_at=datetime.now() + timedelta(days=7)  # Valid for 7 days
        )

        self.db.add(recommendation)
        self.db.commit()
        self.db.refresh(recommendation)

        return recommendation

    def execute_paper_trade(
        self,
        portfolio_id: int,
        stock: Stock,
        signal: Dict[str, Any],
        quantity: float,
        recommendation_id: int = None
    ) -> PaperTrade:
        """
        Execute a paper trade based on signal.

        Args:
            portfolio_id: Portfolio ID
            stock: Stock instance
            signal: Signal data
            quantity: Quantity to trade
            recommendation_id: Optional recommendation ID

        Returns:
            PaperTrade instance
        """
        # Get current price
        current_price = self._get_current_price(stock.id)

        if current_price is None:
            raise ValueError(f"Cannot get current price for {stock.symbol}")

        # Determine action
        action = "buy" if signal.get("action") == "BUY" else "sell"

        paper_trade = PaperTrade(
            portfolio_id=portfolio_id,
            stock_id=stock.id,
            recommendation_id=recommendation_id,
            action=action,
            quantity=Decimal(str(quantity)),
            entry_price=Decimal(str(current_price)),
            signal_confidence=Decimal(str(signal.get("confidence", 0))),
            status="open"
        )

        self.db.add(paper_trade)
        self.db.commit()
        self.db.refresh(paper_trade)

        return paper_trade

    def close_paper_trade(
        self,
        trade_id: int,
        exit_price: float = None
    ) -> PaperTrade:
        """
        Close a paper trade and calculate P&L.

        Args:
            trade_id: Paper trade ID
            exit_price: Optional exit price (uses current if not provided)

        Returns:
            Updated PaperTrade instance
        """
        trade = self.db.query(PaperTrade).filter(
            PaperTrade.id == trade_id
        ).first()

        if not trade:
            raise ValueError(f"Paper trade {trade_id} not found")

        if trade.status != "open":
            raise ValueError(f"Paper trade {trade_id} is not open")

        # Get exit price if not provided
        if exit_price is None:
            exit_price = self._get_current_price(trade.stock_id)

        if exit_price is None:
            raise ValueError("Cannot get exit price")

        trade.exit_price = Decimal(str(exit_price))
        trade.exit_date = datetime.now()
        trade.status = "closed"
        trade.calculate_pnl()

        self.db.commit()
        self.db.refresh(trade)

        return trade

    def get_paper_trades(
        self,
        portfolio_id: int,
        status: str = None
    ) -> List[PaperTrade]:
        """
        Get paper trades for portfolio.

        Args:
            portfolio_id: Portfolio ID
            status: Optional status filter (open, closed)

        Returns:
            List of paper trades
        """
        query = self.db.query(PaperTrade).filter(
            PaperTrade.portfolio_id == portfolio_id
        )

        if status:
            query = query.filter(PaperTrade.status == status)

        return query.order_by(PaperTrade.created_at.desc()).all()

    def get_paper_performance(
        self,
        portfolio_id: int
    ) -> Dict[str, Any]:
        """
        Calculate paper trading performance metrics.

        Args:
            portfolio_id: Portfolio ID

        Returns:
            Dict with performance metrics
        """
        trades = self.get_paper_trades(portfolio_id)

        if not trades:
            return {
                "portfolio_id": portfolio_id,
                "total_trades": 0,
                "open_trades": 0,
                "closed_trades": 0,
                "winning_trades": 0,
                "losing_trades": 0,
                "win_rate": 0.0,
                "total_realized_pnl": 0.0,
                "unrealized_pnl": 0.0,
                "average_win": 0.0,
                "average_loss": 0.0,
                "profit_factor": 0.0,
                "high_confidence_accuracy": 0.0,
                "calculated_at": datetime.now().isoformat()
            }

        open_trades = [t for t in trades if t.status == "open"]
        closed_trades = [t for t in trades if t.status == "closed"]

        # Calculate metrics for closed trades
        total_pnl = sum(float(t.pnl or 0) for t in closed_trades)
        winning_trades = [t for t in closed_trades if t.pnl and float(t.pnl) > 0]
        losing_trades = [t for t in closed_trades if t.pnl and float(t.pnl) < 0]

        win_rate = (len(winning_trades) / len(closed_trades) * 100) if closed_trades else 0

        avg_win = (sum(float(t.pnl) for t in winning_trades) / len(winning_trades)) if winning_trades else 0
        avg_loss = (sum(float(t.pnl) for t in losing_trades) / len(losing_trades)) if losing_trades else 0

        # Calculate unrealized P&L for open trades
        unrealized_pnl = 0
        for trade in open_trades:
            current_price = self._get_current_price(trade.stock_id)
            if current_price:
                if trade.action == "buy":
                    unrealized_pnl += float(trade.quantity) * (current_price - float(trade.entry_price))
                else:
                    unrealized_pnl += float(trade.quantity) * (float(trade.entry_price) - current_price)

        # Signal accuracy by confidence level
        high_conf_trades = [t for t in closed_trades if t.signal_confidence and float(t.signal_confidence) >= 0.7]
        high_conf_wins = [t for t in high_conf_trades if t.pnl and float(t.pnl) > 0]
        high_conf_accuracy = (len(high_conf_wins) / len(high_conf_trades) * 100) if high_conf_trades else 0

        return {
            "portfolio_id": portfolio_id,
            "total_trades": len(trades),
            "open_trades": len(open_trades),
            "closed_trades": len(closed_trades),
            "winning_trades": len(winning_trades),
            "losing_trades": len(losing_trades),
            "win_rate": round(win_rate, 2),
            "total_realized_pnl": round(total_pnl, 2),
            "unrealized_pnl": round(unrealized_pnl, 2),
            "average_win": round(avg_win, 2),
            "average_loss": round(avg_loss, 2),
            "profit_factor": round(abs(avg_win / avg_loss), 2) if avg_loss != 0 else 0,
            "high_confidence_accuracy": round(high_conf_accuracy, 2),
            "calculated_at": datetime.now().isoformat()
        }

    def _get_sentiment_data(self, stock_id: int, days: int = 7) -> Dict[str, Any]:
        """Get sentiment analysis data for stock."""
        start_date = date.today() - timedelta(days=days)

        articles = self.db.query(NewsArticle).join(
            ArticleStock,
            NewsArticle.id == ArticleStock.article_id
        ).filter(
            ArticleStock.stock_id == stock_id,
            NewsArticle.published_at >= start_date,
            NewsArticle.sentiment_score.isnot(None)
        ).order_by(NewsArticle.published_at.desc()).all()

        if not articles:
            return {
                "average_score": 0,
                "trend": "neutral",
                "article_count": 0
            }

        scores = [float(a.sentiment_score) for a in articles]
        avg_score = sum(scores) / len(scores)

        # Calculate trend (compare first half to second half)
        mid = len(scores) // 2
        if mid > 0:
            recent_avg = sum(scores[:mid]) / mid
            older_avg = sum(scores[mid:]) / (len(scores) - mid)
            if recent_avg > older_avg + 0.1:
                trend = "improving"
            elif recent_avg < older_avg - 0.1:
                trend = "declining"
            else:
                trend = "stable"
        else:
            trend = "insufficient_data"

        return {
            "average_score": round(avg_score, 3),
            "trend": trend,
            "article_count": len(articles),
            "recent_scores": scores[:5]
        }

    def _get_price_trend(self, stock_id: int) -> Dict[str, Any]:
        """Calculate price trend metrics."""
        prices = self.db.query(StockPrice).filter(
            StockPrice.stock_id == stock_id
        ).order_by(StockPrice.date.desc()).limit(60).all()

        if len(prices) < 7:
            return {
                "return_7d": 0,
                "return_30d": 0,
                "momentum": "unknown"
            }

        closes = [float(p.close) for p in prices]

        # Calculate returns
        return_7d = ((closes[0] - closes[min(6, len(closes)-1)]) / closes[min(6, len(closes)-1)]) * 100 if len(closes) > 6 else 0
        return_30d = ((closes[0] - closes[min(29, len(closes)-1)]) / closes[min(29, len(closes)-1)]) * 100 if len(closes) > 29 else 0

        # Determine momentum
        if return_7d > 5:
            momentum = "strong_bullish"
        elif return_7d > 2:
            momentum = "bullish"
        elif return_7d > -2:
            momentum = "neutral"
        elif return_7d > -5:
            momentum = "bearish"
        else:
            momentum = "strong_bearish"

        return {
            "return_7d": round(return_7d, 2),
            "return_30d": round(return_30d, 2),
            "momentum": momentum,
            "current_price": closes[0] if closes else 0
        }

    def _get_recent_news(self, stock_id: int, limit: int = 5) -> List[Dict[str, Any]]:
        """Get recent news articles for context."""
        articles = self.db.query(NewsArticle).join(
            ArticleStock,
            NewsArticle.id == ArticleStock.article_id
        ).filter(
            ArticleStock.stock_id == stock_id
        ).order_by(NewsArticle.published_at.desc()).limit(limit).all()

        return [
            {
                "title": a.title,
                "source": a.source,
                "sentiment_score": float(a.sentiment_score) if a.sentiment_score else None,
                "published_at": a.published_at.isoformat() if a.published_at else None
            }
            for a in articles
        ]

    def _get_current_price(self, stock_id: int) -> Optional[float]:
        """Get most recent price for stock."""
        price = self.db.query(StockPrice).filter(
            StockPrice.stock_id == stock_id
        ).order_by(StockPrice.date.desc()).first()

        return float(price.close) if price else None

    def get_pending_recommendations(
        self,
        portfolio_id: int
    ) -> List[Recommendation]:
        """Get pending recommendations for portfolio."""
        return self.db.query(Recommendation).filter(
            Recommendation.portfolio_id == portfolio_id,
            Recommendation.status == "pending"
        ).order_by(Recommendation.confidence.desc()).all()

    def update_recommendation_status(
        self,
        recommendation_id: int,
        status: str
    ) -> Recommendation:
        """Update recommendation status."""
        recommendation = self.db.query(Recommendation).filter(
            Recommendation.id == recommendation_id
        ).first()

        if not recommendation:
            raise ValueError(f"Recommendation {recommendation_id} not found")

        recommendation.status = status
        recommendation.updated_at = datetime.now()

        self.db.commit()
        self.db.refresh(recommendation)

        return recommendation

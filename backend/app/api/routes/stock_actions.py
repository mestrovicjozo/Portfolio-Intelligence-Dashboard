from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import logging

from backend.app.db.base import get_db
from backend.app.models import Stock, NewsArticle, ArticleStock
from backend.app.schemas.news_article import NewsArticle as NewsArticleSchema
from backend.app.services.gemini_service import GeminiService
from backend.app.core.config import settings
from pydantic import BaseModel

logger = logging.getLogger(__name__)

router = APIRouter()
gemini_service = GeminiService(settings.GEMINI_API_KEY)


class StockInsight(BaseModel):
    """Schema for AI-generated stock insights."""
    summary: str
    key_points: List[str]
    sentiment: str
    recommendation: str


class StockAction(BaseModel):
    """Schema for available stock actions."""
    action: str
    label: str
    description: str
    icon: str


@router.get("/{symbol}/actions", response_model=List[StockAction])
def get_stock_actions(symbol: str):
    """Get available actions for a stock."""
    actions = [
        StockAction(
            action="view_chart",
            label="Price Chart",
            description="View historical price charts (1D, 7D, 30D)",
            icon="bar-chart-3"
        ),
        StockAction(
            action="view_articles",
            label="Read Articles",
            description="View recent news articles about this stock",
            icon="newspaper"
        ),
        StockAction(
            action="get_insights",
            label="AI Insights",
            description="Get AI-generated insights and analysis",
            icon="brain"
        ),
        StockAction(
            action="sentiment_analysis",
            label="Sentiment Analysis",
            description="View detailed sentiment trends over time",
            icon="trending-up"
        ),
        StockAction(
            action="ask_question",
            label="Ask AI",
            description="Ask specific questions about this stock",
            icon="message-circle"
        ),
    ]
    return actions


@router.get("/{symbol}/articles", response_model=List[NewsArticleSchema])
def get_stock_articles(
    symbol: str,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """Get recent articles for a specific stock."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()

    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Get articles related to this stock
    article_stocks = db.query(ArticleStock).filter(
        ArticleStock.stock_id == stock.id
    ).order_by(ArticleStock.id.desc()).limit(limit).all()

    articles = []
    for article_stock in article_stocks:
        article = db.query(NewsArticle).filter(
            NewsArticle.id == article_stock.article_id
        ).first()
        if article:
            articles.append(article)

    return articles


@router.post("/{symbol}/insights", response_model=StockInsight)
def get_stock_insights(symbol: str, db: Session = Depends(get_db)):
    """Generate AI insights for a stock based on recent articles."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()

    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Get recent articles
    article_stocks = db.query(ArticleStock).filter(
        ArticleStock.stock_id == stock.id
    ).order_by(ArticleStock.id.desc()).limit(5).all()

    if not article_stocks:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No articles found for {symbol}. Please refresh news first."
        )

    articles = []
    for article_stock in article_stocks:
        article = db.query(NewsArticle).filter(
            NewsArticle.id == article_stock.article_id
        ).first()
        if article:
            articles.append(article)

    # Create context from articles
    context_list = []
    for article in articles:
        context_list.append({
            "title": article.title,
            "source": article.source or "Unknown",
            "published_at": str(article.published_at) if article.published_at else None,
            "summary": article.summary,
            "sentiment_score": article.sentiment_score,
            "stocks": [stock.symbol]
        })

    # Generate insights using Gemini
    prompt = f"""Based on the following information about {stock.name} ({stock.symbol}), a {stock.sector} stock, provide a comprehensive analysis.

Please provide:
1. A brief summary (2-3 sentences) of the overall situation
2. 3-5 key points or takeaways
3. Overall sentiment (positive, negative, or neutral)
4. A brief recommendation or outlook

Format your response as JSON with keys: summary, key_points (array), sentiment, recommendation"""

    try:
        response = gemini_service.answer_question(prompt, context_list)

        # Try to parse as JSON, fallback to structured text
        import json
        try:
            insights = json.loads(response)
        except:
            # Fallback: create structured response from text
            insights = {
                "summary": response[:200] + "..." if len(response) > 200 else response,
                "key_points": [
                    "AI-generated insights based on recent news",
                    f"Average sentiment score: {sum(a.sentiment_score for a in articles) / len(articles):.2f}",
                    f"Based on {len(articles)} recent articles"
                ],
                "sentiment": "neutral",
                "recommendation": "Review the detailed analysis for more information."
            }

        return StockInsight(**insights)

    except Exception as e:
        logger.error(f"Error generating insights: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating insights: {str(e)}"
        )


@router.post("/{symbol}/ask")
def ask_about_stock(
    symbol: str,
    question: str,
    db: Session = Depends(get_db)
):
    """Ask a specific question about a stock."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()

    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Get recent articles for context
    article_stocks = db.query(ArticleStock).filter(
        ArticleStock.stock_id == stock.id
    ).order_by(ArticleStock.id.desc()).limit(10).all()

    articles = []
    for article_stock in article_stocks:
        article = db.query(NewsArticle).filter(
            NewsArticle.id == article_stock.article_id
        ).first()
        if article:
            articles.append(article)

    if not articles:
        return {
            "answer": f"I don't have enough information about {symbol} yet. Please refresh the news feed first.",
            "sources": []
        }

    # Create context from articles
    context_list = []
    for article in articles:
        context_list.append({
            "title": article.title,
            "source": article.source or "Unknown",
            "published_at": str(article.published_at) if article.published_at else None,
            "summary": article.summary,
            "sentiment_score": article.sentiment_score,
            "stocks": [stock.symbol],
            "url": article.url
        })

    # Get answer from Gemini
    try:
        answer = gemini_service.answer_question(question, context_list)

        return {
            "answer": answer,
            "sources": [
                {
                    "title": article.title,
                    "url": article.url,
                    "published_at": article.published_at.isoformat()
                }
                for article in articles[:3]  # Include top 3 sources
            ]
        }

    except Exception as e:
        logger.error(f"Error answering question: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing question: {str(e)}"
        )

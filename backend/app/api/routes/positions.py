from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import logging

from backend.app.db.base import get_db
from backend.app.models import Portfolio, Position, Stock, StockPrice, NewsArticle, ArticleStock
from backend.app.schemas.position import (
    Position as PositionSchema,
    PositionCreate,
    PositionUpdate,
    PositionAddShares,
    PositionWithDetails,
)
from backend.app.schemas.stock import Stock as StockSchema
from backend.app.services.alpha_vantage import AlphaVantageService
from backend.app.services.gemini_service import GeminiService
from backend.app.services.vector_store import VectorStoreService
from backend.app.core.config import settings
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

router = APIRouter()
alpha_vantage = AlphaVantageService(settings.ALPHA_VANTAGE_API_KEY)
gemini_service = GeminiService()
vector_store = VectorStoreService()


@router.get("/", response_model=List[PositionWithDetails])
def get_positions(portfolio_id: int = None, db: Session = Depends(get_db)):
    """Get all positions, optionally filtered by portfolio."""
    if portfolio_id:
        # Get specific portfolio's positions
        portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
        if not portfolio:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Portfolio with id {portfolio_id} not found"
            )
        positions = db.query(Position).filter(Position.portfolio_id == portfolio_id).all()
    else:
        # Get active portfolio's positions
        portfolio = db.query(Portfolio).filter(Portfolio.is_active == True).first()
        if not portfolio:
            return []
        positions = db.query(Position).filter(Position.portfolio_id == portfolio.id).all()

    # Enrich with details
    result = []
    for position in positions:
        details = get_position_details(db, position)
        result.append(details)

    return result


@router.get("/{position_id}", response_model=PositionWithDetails)
def get_position(position_id: int, db: Session = Depends(get_db)):
    """Get a specific position by ID."""
    position = db.query(Position).filter(Position.id == position_id).first()

    if not position:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Position with id {position_id} not found"
        )

    return get_position_details(db, position)


@router.post("/", response_model=PositionWithDetails, status_code=status.HTTP_201_CREATED)
def create_position(position_data: PositionCreate, db: Session = Depends(get_db)):
    """Create a new position in the active portfolio."""
    # Get active portfolio
    portfolio = db.query(Portfolio).filter(Portfolio.is_active == True).first()

    if not portfolio:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active portfolio found. Please create and activate a portfolio first."
        )

    # Get or create stock
    stock = db.query(Stock).filter(Stock.symbol == position_data.stock_symbol.upper()).first()
    is_new_stock = False

    if not stock:
        # Fetch stock info from Alpha Vantage
        try:
            company_info = alpha_vantage.get_company_overview(position_data.stock_symbol)
            stock = Stock(
                symbol=position_data.stock_symbol.upper(),
                name=company_info.get("Name", position_data.stock_symbol),
                sector=company_info.get("Sector", "Unknown")
            )
            db.add(stock)
            db.flush()  # Get stock ID without committing
            is_new_stock = True
        except Exception as e:
            logger.error(f"Error fetching stock info: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Could not find stock: {position_data.stock_symbol}"
            )

    # Check if position already exists
    existing_position = db.query(Position).filter(
        Position.portfolio_id == portfolio.id,
        Position.stock_id == stock.id
    ).first()

    if existing_position:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Position for {stock.symbol} already exists in this portfolio. Use add-shares endpoint to increase position."
        )

    try:
        position = Position(
            portfolio_id=portfolio.id,
            stock_id=stock.id,
            shares=position_data.shares,
            average_cost=position_data.average_cost
        )

        db.add(position)
        db.commit()
        db.refresh(position)

        logger.info(f"Created position: {stock.symbol} - {position_data.shares} shares @ ${position_data.average_cost}")

        # If this is a new stock, fetch initial price data and news articles
        if is_new_stock:
            try:
                logger.info(f"Fetching initial price data for new stock: {stock.symbol}")
                prices = alpha_vantage.get_daily_prices(stock.symbol, outputsize="compact")

                # Add price data to database
                for price_data in prices:
                    db_price = StockPrice(
                        stock_id=stock.id,
                        date=price_data["date"],
                        open=price_data["open"],
                        close=price_data["close"],
                        high=price_data["high"],
                        low=price_data["low"],
                        volume=price_data["volume"]
                    )
                    db.add(db_price)

                db.commit()
                logger.info(f"Successfully added {len(prices)} price records for {stock.symbol}")
            except Exception as e:
                # Don't fail the position creation if price fetch fails
                logger.warning(f"Could not fetch price data for {stock.symbol}: {str(e)}")

            # Fetch news articles from the last week
            try:
                logger.info(f"Fetching news articles for new stock: {stock.symbol}")
                # Calculate time_from as 1 week ago in YYYYMMDDTHHMM format
                one_week_ago = datetime.now() - timedelta(days=7)
                time_from = one_week_ago.strftime("%Y%m%dT%H%M")

                news_items = alpha_vantage.get_news_sentiment(
                    tickers=stock.symbol,
                    time_from=time_from,
                    limit=50
                )

                news_count = 0
                for item in news_items:
                    # Check if article already exists
                    existing = db.query(NewsArticle).filter(
                        NewsArticle.url == item["url"]
                    ).first()

                    if not existing and stock.symbol in item.get("ticker_sentiment", {}):
                        # Create new article
                        article = NewsArticle(
                            title=item["title"],
                            source=item["source"],
                            url=item["url"],
                            published_at=item["published_at"],
                            summary=item["summary"],
                            sentiment_score=item["overall_sentiment_score"]
                        )
                        db.add(article)
                        db.flush()  # Get article ID

                        # Link to stock
                        article_stock = ArticleStock(
                            article_id=article.id,
                            stock_id=stock.id
                        )
                        db.add(article_stock)

                        # Generate embedding and add to vector store
                        try:
                            content = f"{item['title']}. {item['summary']}"
                            embedding = gemini_service.generate_embedding(content)
                            vector_store.add_article(
                                article_id=article.id,
                                content=content,
                                embedding=embedding,
                                metadata={
                                    "title": item["title"],
                                    "source": item["source"],
                                    "published_at": str(item["published_at"]),
                                    "sentiment_score": item["overall_sentiment_score"],
                                    "stocks": [stock.symbol]
                                }
                            )
                        except Exception as e:
                            logger.warning(f"Could not add article to vector store: {str(e)}")

                        news_count += 1

                db.commit()
                logger.info(f"Successfully added {news_count} news articles for {stock.symbol}")
            except Exception as e:
                # Don't fail the position creation if news fetch fails
                logger.warning(f"Could not fetch news articles for {stock.symbol}: {str(e)}")

        return get_position_details(db, position)

    except Exception as e:
        db.rollback()
        logger.error(f"Error creating position: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating position: {str(e)}"
        )


@router.post("/{position_id}/add-shares", response_model=PositionWithDetails)
def add_shares(
    position_id: int,
    shares_data: PositionAddShares,
    db: Session = Depends(get_db)
):
    """Add shares to an existing position (calculates new average cost)."""
    position = db.query(Position).filter(Position.id == position_id).first()

    if not position:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Position with id {position_id} not found"
        )

    try:
        # Calculate new average cost
        current_total_cost = position.shares * position.average_cost
        new_purchase_cost = shares_data.shares * shares_data.cost_per_share
        total_cost = current_total_cost + new_purchase_cost

        new_total_shares = position.shares + shares_data.shares
        new_average_cost = total_cost / new_total_shares

        # Update position
        position.shares = new_total_shares
        position.average_cost = new_average_cost

        db.commit()
        db.refresh(position)

        logger.info(f"Added {shares_data.shares} shares to position {position_id}. New avg cost: ${new_average_cost:.2f}")

        return get_position_details(db, position)

    except Exception as e:
        db.rollback()
        logger.error(f"Error adding shares: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error adding shares: {str(e)}"
        )


@router.put("/{position_id}", response_model=PositionWithDetails)
def update_position(
    position_id: int,
    position_data: PositionUpdate,
    db: Session = Depends(get_db)
):
    """Update a position."""
    position = db.query(Position).filter(Position.id == position_id).first()

    if not position:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Position with id {position_id} not found"
        )

    try:
        # Update only provided fields
        if position_data.shares is not None:
            position.shares = position_data.shares
        if position_data.average_cost is not None:
            position.average_cost = position_data.average_cost

        db.commit()
        db.refresh(position)

        logger.info(f"Updated position {position_id}")

        return get_position_details(db, position)

    except Exception as e:
        db.rollback()
        logger.error(f"Error updating position: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating position: {str(e)}"
        )


@router.delete("/{position_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_position(position_id: int, db: Session = Depends(get_db)):
    """Delete a position."""
    position = db.query(Position).filter(Position.id == position_id).first()

    if not position:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Position with id {position_id} not found"
        )

    try:
        db.delete(position)
        db.commit()

        logger.info(f"Deleted position {position_id}")

    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting position: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting position: {str(e)}"
        )


def get_position_details(db: Session, position: Position) -> PositionWithDetails:
    """Enrich position with stock details and calculated metrics."""
    stock = db.query(Stock).filter(Stock.id == position.stock_id).first()

    # Get latest price
    latest_price_record = db.query(StockPrice).filter(
        StockPrice.stock_id == position.stock_id
    ).order_by(StockPrice.date.desc()).first()

    # Get previous day's price for day change calculation
    previous_price_record = db.query(StockPrice).filter(
        StockPrice.stock_id == position.stock_id
    ).order_by(StockPrice.date.desc()).offset(1).first()

    current_price = latest_price_record.close if latest_price_record else None
    previous_close = previous_price_record.close if previous_price_record else None

    # Calculate metrics
    total_cost = position.shares * position.average_cost
    current_value = (position.shares * current_price) if current_price else None
    gain_loss = (current_value - total_cost) if current_value else None
    gain_loss_percent = ((gain_loss / total_cost) * 100) if (gain_loss and total_cost > 0) else None

    day_change = (current_price - previous_close) if (current_price and previous_close) else None
    day_change_percent = ((day_change / previous_close) * 100) if (day_change and previous_close) else None

    return PositionWithDetails(
        id=position.id,
        portfolio_id=position.portfolio_id,
        stock_id=position.stock_id,
        shares=position.shares,
        average_cost=position.average_cost,
        created_at=position.created_at,
        updated_at=position.updated_at,
        stock=StockSchema.from_orm(stock),
        current_price=round(current_price, 2) if current_price else None,
        total_cost=round(total_cost, 2),
        current_value=round(current_value, 2) if current_value else None,
        gain_loss=round(gain_loss, 2) if gain_loss else None,
        gain_loss_percent=round(gain_loss_percent, 2) if gain_loss_percent else None,
        day_change=round(day_change, 2) if day_change else None,
        day_change_percent=round(day_change_percent, 2) if day_change_percent else None,
    )

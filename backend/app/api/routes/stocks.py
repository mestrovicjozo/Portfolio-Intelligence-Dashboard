from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta

from backend.app.db.base import get_db
from backend.app.models import Stock, StockPrice
from backend.app.schemas.stock import Stock as StockSchema, StockCreate, StockWithPrice
from backend.app.services.alpha_vantage import AlphaVantageService

router = APIRouter()
av_service = AlphaVantageService()


@router.get("/", response_model=List[StockWithPrice])
def list_stocks(db: Session = Depends(get_db)):
    """Get all stocks in portfolio with current prices."""
    stocks = db.query(Stock).all()

    result = []
    for stock in stocks:
        # Get latest price
        latest_price = db.query(StockPrice).filter(
            StockPrice.stock_id == stock.id
        ).order_by(StockPrice.date.desc()).first()

        stock_dict = StockSchema.from_orm(stock).dict()

        if latest_price:
            # Get previous day's price for comparison
            prev_price = db.query(StockPrice).filter(
                StockPrice.stock_id == stock.id,
                StockPrice.date < latest_price.date
            ).order_by(StockPrice.date.desc()).first()

            stock_dict["current_price"] = latest_price.close
            if prev_price:
                change = latest_price.close - prev_price.close
                change_percent = (change / prev_price.close) * 100
                stock_dict["price_change"] = round(change, 2)
                stock_dict["price_change_percent"] = round(change_percent, 2)

        result.append(StockWithPrice(**stock_dict))

    return result


@router.post("/", response_model=StockSchema, status_code=status.HTTP_201_CREATED)
def add_stock(stock_data: StockCreate, db: Session = Depends(get_db)):
    """Add a new stock to portfolio."""
    # Check if stock already exists
    existing = db.query(Stock).filter(Stock.symbol == stock_data.symbol.upper()).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Stock {stock_data.symbol} already exists in portfolio"
        )

    # Fetch company info from Alpha Vantage if not provided
    if not stock_data.name or not stock_data.sector:
        try:
            overview = av_service.get_company_overview(stock_data.symbol)
            if overview:
                if not stock_data.name:
                    stock_data.name = overview.get("name", stock_data.symbol)
                if not stock_data.sector:
                    stock_data.sector = overview.get("sector")
        except Exception as e:
            # Continue even if API call fails
            if not stock_data.name:
                stock_data.name = stock_data.symbol

    # Create stock
    db_stock = Stock(
        symbol=stock_data.symbol.upper(),
        name=stock_data.name,
        sector=stock_data.sector
    )
    db.add(db_stock)
    db.commit()
    db.refresh(db_stock)

    return db_stock


@router.get("/{symbol}", response_model=StockWithPrice)
def get_stock(symbol: str, db: Session = Depends(get_db)):
    """Get stock details by symbol."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Get latest price
    latest_price = db.query(StockPrice).filter(
        StockPrice.stock_id == stock.id
    ).order_by(StockPrice.date.desc()).first()

    stock_dict = StockSchema.from_orm(stock).dict()

    if latest_price:
        prev_price = db.query(StockPrice).filter(
            StockPrice.stock_id == stock.id,
            StockPrice.date < latest_price.date
        ).order_by(StockPrice.date.desc()).first()

        stock_dict["current_price"] = latest_price.close
        if prev_price:
            change = latest_price.close - prev_price.close
            change_percent = (change / prev_price.close) * 100
            stock_dict["price_change"] = round(change, 2)
            stock_dict["price_change_percent"] = round(change_percent, 2)

    return StockWithPrice(**stock_dict)


@router.delete("/{symbol}", status_code=status.HTTP_204_NO_CONTENT)
def delete_stock(symbol: str, db: Session = Depends(get_db)):
    """Remove a stock from portfolio."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    db.delete(stock)
    db.commit()
    return None


@router.post("/{symbol}/refresh", response_model=dict)
def refresh_stock_data(symbol: str, db: Session = Depends(get_db)):
    """Refresh stock price data from Alpha Vantage."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    try:
        # Fetch latest prices
        prices = av_service.get_daily_prices(symbol, outputsize="compact")

        # Update database
        count = 0
        for price_data in prices:
            # Check if price already exists
            existing = db.query(StockPrice).filter(
                StockPrice.stock_id == stock.id,
                StockPrice.date == price_data["date"]
            ).first()

            if not existing:
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
                count += 1

        db.commit()

        return {
            "message": f"Successfully refreshed data for {symbol}",
            "new_records": count
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error refreshing stock data: {str(e)}"
        )


@router.get("/{symbol}/search")
def search_stock_symbol(keywords: str):
    """Search for stock symbols by company name."""
    try:
        results = av_service.search_symbol(keywords)
        return {"results": results}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error searching stocks: {str(e)}"
        )

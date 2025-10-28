from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta
import os

from backend.app.db.base import get_db
from backend.app.models import Stock, StockPrice
from backend.app.schemas.stock import Stock as StockSchema, StockCreate, StockWithPrice
from backend.app.services.alpha_vantage import AlphaVantageService
from backend.app.services.custom_stock_api import CustomStockAPIService
from backend.app.services.logo_service import logo_service
from backend.app.core.config import settings
import logging

logger = logging.getLogger(__name__)

router = APIRouter()
av_service = AlphaVantageService()
custom_api = CustomStockAPIService()


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

        # Always add logo URL (will use default if specific logo doesn't exist)
        stock_dict["logo_url"] = f"/api/stocks/{stock.symbol}/logo/"

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


@router.get("/{symbol}/", response_model=StockWithPrice)
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

    # Always add logo URL (will use default if specific logo doesn't exist)
    stock_dict["logo_url"] = f"/api/stocks/{stock.symbol}/logo/"

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


@router.get("/{symbol}/prices")
def get_stock_prices(symbol: str, days: int = 30, db: Session = Depends(get_db)):
    """Get historical price data for a stock."""
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Calculate date range
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)

    # Fetch prices from database
    prices = db.query(StockPrice).filter(
        StockPrice.stock_id == stock.id,
        StockPrice.date >= start_date
    ).order_by(StockPrice.date.asc()).all()

    return [
        {
            "date": price.date.isoformat(),
            "open": price.open,
            "close": price.close,
            "high": price.high,
            "low": price.low,
            "volume": price.volume
        }
        for price in prices
    ]


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


@router.post("/{symbol}/logo/", response_model=dict)
async def upload_logo(
    symbol: str,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    Upload a logo for a stock.

    Args:
        symbol: Stock ticker symbol
        file: Logo image file (PNG, JPG, SVG, etc.)
    """
    # Verify stock exists
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Validate file size
    content = await file.read()
    if len(content) > settings.MAX_LOGO_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File too large. Maximum size: {settings.MAX_LOGO_SIZE / 1024 / 1024}MB"
        )

    # Get file extension
    extension = file.filename.split('.')[-1].lower() if '.' in file.filename else ''

    try:
        # Save logo to file system
        filename = logo_service.save_logo(symbol.upper(), content, extension)

        # Update database
        stock.logo_filename = filename
        db.commit()

        return {
            "message": f"Logo uploaded successfully for {symbol}",
            "filename": filename,
            "logo_url": f"/api/stocks/{symbol.upper()}/logo/"
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error uploading logo: {str(e)}"
        )


@router.get("/{symbol}/logo/")
async def get_logo(symbol: str, db: Session = Depends(get_db)):
    """
    Get the logo file for a stock. Returns default logo if specific logo doesn't exist.

    Args:
        symbol: Stock ticker symbol

    Returns:
        Logo image file (specific or default)
    """
    # Try to find logo file (will return default if specific doesn't exist)
    logo_path = logo_service.get_logo_path(symbol.upper(), use_default=True)

    if not logo_path or not logo_path.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No logo available for {symbol}"
        )

    # Determine media type
    extension = logo_path.suffix.lower().lstrip('.')
    media_type_map = {
        'png': 'image/png',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'svg': 'image/svg+xml',
        'webp': 'image/webp'
    }
    media_type = media_type_map.get(extension, 'application/octet-stream')

    return FileResponse(
        path=str(logo_path),
        media_type=media_type,
        filename=logo_path.name
    )


@router.delete("/{symbol}/logo/", status_code=status.HTTP_204_NO_CONTENT)
def delete_logo(symbol: str, db: Session = Depends(get_db)):
    """
    Delete the logo for a stock.

    Args:
        symbol: Stock ticker symbol
    """
    # Verify stock exists
    stock = db.query(Stock).filter(Stock.symbol == symbol.upper()).first()
    if not stock:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stock {symbol} not found"
        )

    # Delete logo file
    deleted = logo_service.delete_logo(symbol.upper())

    if deleted:
        # Update database
        stock.logo_filename = None
        db.commit()

    return None


@router.post("/update-prices", response_model=dict)
def update_current_prices(db: Session = Depends(get_db)):
    """
    Update current prices for all stocks from custom API.
    """
    try:
        # Fetch all current prices from custom API
        prices = custom_api.get_current_prices()

        if not prices:
            raise HTTPException(status_code=500, detail="Failed to fetch prices from API")

        updated_count = 0
        today = datetime.now().date()

        for ticker, price_eur in prices.items():
            # Find the stock in database
            stock = db.query(Stock).filter(Stock.symbol == ticker).first()

            if not stock:
                logger.debug(f"Stock {ticker} not in database, skipping")
                continue

            # Check if today's price already exists
            existing_price = db.query(StockPrice).filter(
                StockPrice.stock_id == stock.id,
                StockPrice.date == today
            ).first()

            if existing_price:
                # Update existing price
                existing_price.close = price_eur
                existing_price.open = price_eur
                existing_price.high = price_eur
                existing_price.low = price_eur
            else:
                # Create new price record
                new_price = StockPrice(
                    stock_id=stock.id,
                    date=today,
                    open=price_eur,
                    high=price_eur,
                    low=price_eur,
                    close=price_eur,
                    volume=0
                )
                db.add(new_price)

            updated_count += 1

        db.commit()

        logger.info(f"Updated prices for {updated_count} stocks")

        return {
            "message": "Prices updated successfully",
            "updated": updated_count,
            "total_prices": len(prices)
        }

    except Exception as e:
        db.rollback()
        logger.error(f"Error updating prices: {e}")
        raise HTTPException(status_code=500, detail=str(e))

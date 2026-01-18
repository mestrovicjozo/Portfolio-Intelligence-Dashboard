from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

from backend.app.core.config import settings
from backend.app.api.routes import stocks, news, query, portfolios, positions, stock_actions, admin, websocket
from backend.app.api.routes import research, roboadvisor
from backend.app.db.base import engine, Base
from backend.app.services.scheduler import scheduler_service

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Portfolio Intelligence Dashboard API",
    description="AI-powered portfolio tracking and analysis system",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(portfolios.router, prefix="/api/portfolios", tags=["portfolios"])
app.include_router(positions.router, prefix="/api/positions", tags=["positions"])
app.include_router(stocks.router, prefix="/api/stocks", tags=["stocks"])
app.include_router(stock_actions.router, prefix="/api/stocks", tags=["stock-actions"])
app.include_router(news.router, prefix="/api/news", tags=["news"])
app.include_router(query.router, prefix="/api/query", tags=["query"])
app.include_router(admin.router, prefix="/api/admin", tags=["admin"])
app.include_router(websocket.router, tags=["websocket"])
app.include_router(research.router, prefix="/api/research", tags=["research"])
app.include_router(roboadvisor.router, prefix="/api/roboadvisor", tags=["roboadvisor"])


@app.on_event("startup")
async def startup_event():
    """Initialize database tables and start scheduler on startup."""
    logger.info("Starting up Portfolio Intelligence Dashboard API")

    # Create all tables
    try:
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Error creating database tables: {e}")

    # Start scheduler
    try:
        scheduler_service.start()
        logger.info("Scheduler started successfully")
    except Exception as e:
        logger.error(f"Error starting scheduler: {e}")


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown."""
    logger.info("Shutting down Portfolio Intelligence Dashboard API")

    # Shutdown scheduler
    try:
        scheduler_service.shutdown()
        logger.info("Scheduler shutdown successfully")
    except Exception as e:
        logger.error(f"Error shutting down scheduler: {e}")


@app.get("/")
def root():
    """Root endpoint."""
    return {
        "message": "Portfolio Intelligence Dashboard API",
        "version": "1.0.0",
        "docs": "/api/docs"
    }


@app.get("/api/health")
def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "environment": settings.APP_ENV
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "backend.app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG
    )

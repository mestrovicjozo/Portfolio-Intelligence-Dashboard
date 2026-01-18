from pydantic_settings import BaseSettings
from typing import List
import os
from pathlib import Path


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # API Keys
    ALPHA_VANTAGE_API_KEY: str
    GEMINI_API_KEY: str
    FINNHUB_API_KEY: str

    # Jina AI Embeddings (cost optimization)
    JINA_API_KEY: str = ""
    JINA_EMBEDDING_MODEL: str = "jina-embeddings-v3"

    # Serper (Google Search API)
    SERPER_API_KEY: str = ""
    SERPER_CACHE_TTL: int = 3600  # 1 hour cache

    # Database
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/portfolio_intelligence"
    CHROMA_PERSIST_DIR: str = str(Path(__file__).parent.parent.parent.parent / "data" / "chroma")

    # Application
    APP_ENV: str = "development"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"

    # CORS
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:5173"

    # Alpha Vantage settings
    ALPHA_VANTAGE_BASE_URL: str = "https://www.alphavantage.co/query"

    # Gemini settings
    GEMINI_MODEL: str = "gemini-2.5-flash-lite"
    EMBEDDING_DIMENSION: int = 768  # Note: Jina uses 1024, Gemini uses 768

    # Price fetching settings
    PRICE_CACHE_TTL: int = 60  # seconds
    MAX_CONCURRENT_PRICE_REQUESTS: int = 10

    # Scheduler settings
    SCHEDULER_TIMEZONE: str = "America/New_York"
    PRICE_COLLECTION_TIME: str = "17:00"  # 5:00 PM ET (after market close)
    NEWS_COLLECTION_TIME: str = "19:00"  # 7:00 PM ET
    WEEKLY_EXPORT_DAY: str = "sun"  # Day of week for exports (sun, mon, tue, wed, thu, fri, sat)
    WEEKLY_EXPORT_TIME: str = "02:00"  # 2:00 AM on export day
    MONTHLY_BACKUP_DAY: int = 1  # Day of month (1-31)
    MONTHLY_BACKUP_TIME: str = "03:00"  # 3:00 AM on backup day

    # Data export settings
    EXPORT_DIR: str = str(Path(__file__).parent.parent.parent.parent / "exports")
    BACKUP_DIR: str = str(Path(__file__).parent.parent.parent.parent / "backups")
    EXPORT_RETENTION_DAYS: int = 180  # Keep exports for 6 months

    # Stock logo settings
    LOGO_DIR: str = str(Path(__file__).parent.parent.parent.parent / "data" / "logos")
    MAX_LOGO_SIZE: int = 2_097_152  # 2MB max file size
    ALLOWED_LOGO_EXTENSIONS: List[str] = ["png", "jpg", "jpeg", "svg", "webp"]

    # Roboadvisor settings
    DEFAULT_RISK_TOLERANCE: str = "moderate"
    DEFAULT_REBALANCE_THRESHOLD: float = 5.0  # percentage
    SIGNAL_CONFIDENCE_THRESHOLD: float = 0.6

    class Config:
        env_file = ".env"
        case_sensitive = True

    @property
    def allowed_origins_list(self) -> List[str]:
        """Parse ALLOWED_ORIGINS string into a list."""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]


# Global settings instance
settings = Settings()

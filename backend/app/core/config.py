from pydantic_settings import BaseSettings
from typing import List
import os
from pathlib import Path


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # API Keys
    ALPHA_VANTAGE_API_KEY: str
    GEMINI_API_KEY: str

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
    GEMINI_MODEL: str = "gemini-1.5-flash"
    EMBEDDING_DIMENSION: int = 768

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

    class Config:
        env_file = ".env"
        case_sensitive = True

    @property
    def allowed_origins_list(self) -> List[str]:
        """Parse ALLOWED_ORIGINS string into a list."""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]


# Global settings instance
settings = Settings()

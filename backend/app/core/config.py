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

    class Config:
        env_file = ".env"
        case_sensitive = True

    @property
    def allowed_origins_list(self) -> List[str]:
        """Parse ALLOWED_ORIGINS string into a list."""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]


# Global settings instance
settings = Settings()

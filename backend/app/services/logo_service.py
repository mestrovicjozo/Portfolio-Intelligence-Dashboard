"""
Stock logo management service.

Handles file system storage and retrieval of stock company logos.
"""

import logging
from pathlib import Path
from typing import Optional
import os
import shutil

from backend.app.core.config import settings

logger = logging.getLogger(__name__)


class LogoService:
    """Service for managing stock logos on the file system."""

    def __init__(self):
        self.logo_dir = Path(settings.LOGO_DIR)
        self.logo_dir.mkdir(parents=True, exist_ok=True)
        logger.info(f"Logo directory initialized: {self.logo_dir}")

    def save_logo(self, symbol: str, file_content: bytes, extension: str) -> str:
        """
        Save a logo file to the file system.

        Args:
            symbol: Stock ticker symbol
            file_content: Binary content of the logo file
            extension: File extension (png, jpg, etc.)

        Returns:
            Filename of the saved logo

        Raises:
            ValueError: If extension is not allowed
        """
        extension = extension.lower().lstrip('.')

        if extension not in settings.ALLOWED_LOGO_EXTENSIONS:
            raise ValueError(
                f"Invalid file extension: {extension}. "
                f"Allowed: {', '.join(settings.ALLOWED_LOGO_EXTENSIONS)}"
            )

        # Use symbol as filename
        filename = f"{symbol.upper()}.{extension}"
        filepath = self.logo_dir / filename

        # Remove existing logo for this symbol (any extension)
        self.delete_logo(symbol)

        # Save new logo
        try:
            with open(filepath, 'wb') as f:
                f.write(file_content)
            logger.info(f"Saved logo for {symbol}: {filename}")
            return filename
        except Exception as e:
            logger.error(f"Error saving logo for {symbol}: {e}")
            raise

    def get_logo_path(self, symbol: str) -> Optional[Path]:
        """
        Get the file path for a stock's logo.

        Args:
            symbol: Stock ticker symbol

        Returns:
            Path to logo file if it exists, None otherwise
        """
        # Check for any allowed extension
        for ext in settings.ALLOWED_LOGO_EXTENSIONS:
            filepath = self.logo_dir / f"{symbol.upper()}.{ext}"
            if filepath.exists():
                return filepath

        return None

    def get_logo_filename(self, symbol: str) -> Optional[str]:
        """
        Get the filename of a stock's logo.

        Args:
            symbol: Stock ticker symbol

        Returns:
            Filename if logo exists, None otherwise
        """
        logo_path = self.get_logo_path(symbol)
        return logo_path.name if logo_path else None

    def delete_logo(self, symbol: str) -> bool:
        """
        Delete a stock's logo file.

        Args:
            symbol: Stock ticker symbol

        Returns:
            True if logo was deleted, False if no logo existed
        """
        deleted = False

        # Remove any existing logo for this symbol (all extensions)
        for ext in settings.ALLOWED_LOGO_EXTENSIONS:
            filepath = self.logo_dir / f"{symbol.upper()}.{ext}"
            if filepath.exists():
                try:
                    os.remove(filepath)
                    logger.info(f"Deleted logo for {symbol}: {filepath.name}")
                    deleted = True
                except Exception as e:
                    logger.error(f"Error deleting logo {filepath}: {e}")

        return deleted

    def logo_exists(self, symbol: str) -> bool:
        """
        Check if a logo exists for a stock.

        Args:
            symbol: Stock ticker symbol

        Returns:
            True if logo exists, False otherwise
        """
        return self.get_logo_path(symbol) is not None


# Global logo service instance
logo_service = LogoService()

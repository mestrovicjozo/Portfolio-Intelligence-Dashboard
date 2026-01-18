"""
Script to create roboadvisor database tables.

Tables created:
- user_profiles: User investment profiles
- target_allocations: Target allocation weights
- recommendations: AI trading recommendations
- risk_scores: Historical risk scores
- paper_trades: Paper trading simulation

Run with: python -m backend.scripts.create_roboadvisor_tables
"""

import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import create_engine, text
from backend.app.core.config import settings
from backend.app.db.base import Base
from backend.app.models import (
    UserProfile, TargetAllocation, Recommendation,
    RiskScore, PaperTrade
)


def create_tables():
    """Create all roboadvisor tables."""
    print("Creating roboadvisor tables...")

    engine = create_engine(settings.DATABASE_URL)

    # Create all tables defined in models
    Base.metadata.create_all(bind=engine)

    print("Tables created successfully!")

    # Verify tables exist
    with engine.connect() as conn:
        tables = [
            'user_profiles',
            'target_allocations',
            'recommendations',
            'risk_scores',
            'paper_trades'
        ]

        for table in tables:
            result = conn.execute(text(
                f"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '{table}')"
            ))
            exists = result.scalar()
            status = "✓" if exists else "✗"
            print(f"  {status} {table}")


def drop_tables():
    """Drop all roboadvisor tables (use with caution!)."""
    print("Dropping roboadvisor tables...")

    engine = create_engine(settings.DATABASE_URL)

    with engine.connect() as conn:
        # Drop in correct order due to foreign keys
        tables = [
            'paper_trades',
            'recommendations',
            'risk_scores',
            'target_allocations',
            'user_profiles'
        ]

        for table in tables:
            try:
                conn.execute(text(f"DROP TABLE IF EXISTS {table} CASCADE"))
                print(f"  Dropped {table}")
            except Exception as e:
                print(f"  Error dropping {table}: {e}")

        conn.commit()

    print("Tables dropped!")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Manage roboadvisor database tables")
    parser.add_argument("--drop", action="store_true", help="Drop tables instead of creating")

    args = parser.parse_args()

    if args.drop:
        confirm = input("Are you sure you want to drop all roboadvisor tables? (yes/no): ")
        if confirm.lower() == "yes":
            drop_tables()
        else:
            print("Aborted.")
    else:
        create_tables()

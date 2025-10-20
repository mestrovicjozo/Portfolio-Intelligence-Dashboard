"""
Scheduler service for automated data collection and exports.

This service manages all scheduled tasks including:
- Daily stock price collection
- Daily news collection
- Weekly data exports
- Monthly database backups
"""

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.events import EVENT_JOB_EXECUTED, EVENT_JOB_ERROR
from datetime import datetime
from typing import Dict, List, Any
import logging
import pytz

from backend.app.core.config import settings

logger = logging.getLogger(__name__)


class SchedulerService:
    """Service for managing scheduled tasks."""

    def __init__(self):
        self.scheduler = AsyncIOScheduler(timezone=settings.SCHEDULER_TIMEZONE)
        self.job_history: List[Dict[str, Any]] = []
        self._is_running = False

        # Register event listeners
        self.scheduler.add_listener(self._job_executed, EVENT_JOB_EXECUTED)
        self.scheduler.add_listener(self._job_error, EVENT_JOB_ERROR)

    def _job_executed(self, event):
        """Log successful job execution."""
        job_info = {
            "job_id": event.job_id,
            "status": "success",
            "timestamp": datetime.now(pytz.timezone(settings.SCHEDULER_TIMEZONE)),
            "error": None
        }
        self.job_history.append(job_info)
        logger.info(f"Job {event.job_id} executed successfully")

        # Keep only last 100 job executions
        if len(self.job_history) > 100:
            self.job_history = self.job_history[-100:]

    def _job_error(self, event):
        """Log job execution errors."""
        job_info = {
            "job_id": event.job_id,
            "status": "error",
            "timestamp": datetime.now(pytz.timezone(settings.SCHEDULER_TIMEZONE)),
            "error": str(event.exception)
        }
        self.job_history.append(job_info)
        logger.error(f"Job {event.job_id} failed: {event.exception}")

        # Keep only last 100 job executions
        if len(self.job_history) > 100:
            self.job_history = self.job_history[-100:]

    def register_jobs(self):
        """Register all scheduled jobs."""
        logger.info("Registering scheduled jobs...")

        # Parse time strings
        price_hour, price_minute = map(int, settings.PRICE_COLLECTION_TIME.split(':'))
        news_hour, news_minute = map(int, settings.NEWS_COLLECTION_TIME.split(':'))
        export_hour, export_minute = map(int, settings.WEEKLY_EXPORT_TIME.split(':'))
        backup_hour, backup_minute = map(int, settings.MONTHLY_BACKUP_TIME.split(':'))

        # Job 1: Daily Price Collection (Monday-Friday at 5:00 PM ET)
        self.scheduler.add_job(
            self._collect_prices_job,
            trigger=CronTrigger(
                day_of_week='mon-fri',
                hour=price_hour,
                minute=price_minute,
                timezone=settings.SCHEDULER_TIMEZONE
            ),
            id='daily_price_collection',
            name='Daily Stock Price Collection',
            replace_existing=True
        )
        logger.info(f"Registered: Daily Price Collection (Mon-Fri at {settings.PRICE_COLLECTION_TIME} ET)")

        # Job 2: Daily News Collection (every day at 7:00 PM ET)
        self.scheduler.add_job(
            self._collect_news_job,
            trigger=CronTrigger(
                hour=news_hour,
                minute=news_minute,
                timezone=settings.SCHEDULER_TIMEZONE
            ),
            id='daily_news_collection',
            name='Daily News Collection',
            replace_existing=True
        )
        logger.info(f"Registered: Daily News Collection (Daily at {settings.NEWS_COLLECTION_TIME} ET)")

        # Job 3: Weekly Data Export (Sundays at 2:00 AM ET)
        self.scheduler.add_job(
            self._export_data_job,
            trigger=CronTrigger(
                day_of_week=settings.WEEKLY_EXPORT_DAY,
                hour=export_hour,
                minute=export_minute,
                timezone=settings.SCHEDULER_TIMEZONE
            ),
            id='weekly_data_export',
            name='Weekly Data Export',
            replace_existing=True
        )
        logger.info(f"Registered: Weekly Data Export ({settings.WEEKLY_EXPORT_DAY.capitalize()} at {settings.WEEKLY_EXPORT_TIME} ET)")

        # Job 4: Monthly Database Backup (1st of month at 3:00 AM ET)
        self.scheduler.add_job(
            self._backup_database_job,
            trigger=CronTrigger(
                day=settings.MONTHLY_BACKUP_DAY,
                hour=backup_hour,
                minute=backup_minute,
                timezone=settings.SCHEDULER_TIMEZONE
            ),
            id='monthly_database_backup',
            name='Monthly Database Backup',
            replace_existing=True
        )
        logger.info(f"Registered: Monthly Database Backup (Day {settings.MONTHLY_BACKUP_DAY} at {settings.MONTHLY_BACKUP_TIME} ET)")

    async def _collect_prices_job(self):
        """Job function for daily price collection."""
        logger.info("Starting daily price collection job...")
        try:
            # Import here to avoid circular dependencies
            from backend.app.services.price_collector import collect_all_prices
            result = await collect_all_prices()
            logger.info(f"Price collection completed: {result}")
        except Exception as e:
            logger.error(f"Price collection job failed: {e}")
            raise

    async def _collect_news_job(self):
        """Job function for daily news collection."""
        logger.info("Starting daily news collection job...")
        try:
            # Import here to avoid circular dependencies
            from backend.app.services.news_collector import collect_all_news
            result = await collect_all_news()
            logger.info(f"News collection completed: {result}")
        except Exception as e:
            logger.error(f"News collection job failed: {e}")
            raise

    async def _export_data_job(self):
        """Job function for weekly data export."""
        logger.info("Starting weekly data export job...")
        try:
            # Import here to avoid circular dependencies
            from backend.app.services.data_exporter import export_all_data
            result = await export_all_data()
            logger.info(f"Data export completed: {result}")
        except Exception as e:
            logger.error(f"Data export job failed: {e}")
            raise

    async def _backup_database_job(self):
        """Job function for monthly database backup."""
        logger.info("Starting monthly database backup job...")
        try:
            # Import here to avoid circular dependencies
            from backend.app.services.data_exporter import backup_database
            result = await backup_database()
            logger.info(f"Database backup completed: {result}")
        except Exception as e:
            logger.error(f"Database backup job failed: {e}")
            raise

    def start(self):
        """Start the scheduler."""
        if not self._is_running:
            self.register_jobs()
            self.scheduler.start()
            self._is_running = True
            logger.info("Scheduler started successfully")
        else:
            logger.warning("Scheduler is already running")

    def shutdown(self):
        """Shutdown the scheduler gracefully."""
        if self._is_running:
            self.scheduler.shutdown(wait=True)
            self._is_running = False
            logger.info("Scheduler shutdown successfully")
        else:
            logger.warning("Scheduler is not running")

    def get_status(self) -> Dict[str, Any]:
        """Get scheduler status and job information."""
        jobs = []
        for job in self.scheduler.get_jobs():
            jobs.append({
                "id": job.id,
                "name": job.name,
                "next_run_time": job.next_run_time.isoformat() if job.next_run_time else None,
                "trigger": str(job.trigger)
            })

        # Get recent job history (last 10)
        recent_history = sorted(
            self.job_history,
            key=lambda x: x['timestamp'],
            reverse=True
        )[:10]

        # Format timestamps for JSON serialization
        for item in recent_history:
            item['timestamp'] = item['timestamp'].isoformat()

        return {
            "is_running": self._is_running,
            "timezone": settings.SCHEDULER_TIMEZONE,
            "jobs": jobs,
            "recent_history": recent_history,
            "total_jobs_executed": len([h for h in self.job_history if h['status'] == 'success']),
            "total_jobs_failed": len([h for h in self.job_history if h['status'] == 'error'])
        }


# Global scheduler instance
scheduler_service = SchedulerService()

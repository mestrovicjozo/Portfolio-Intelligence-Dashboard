"""
Background job tracking and WebSocket notification system.

Provides:
- Job tracking for async operations
- WebSocket connection management
- Real-time notifications for completed jobs
"""

import asyncio
import logging
from typing import Dict, Any, Set, Optional
from datetime import datetime
from enum import Enum
from fastapi import WebSocket
from pydantic import BaseModel

logger = logging.getLogger(__name__)


class JobStatus(str, Enum):
    """Job status enum."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"


class Job(BaseModel):
    """Background job model."""
    job_id: str
    job_type: str
    status: JobStatus
    stock_symbol: Optional[str] = None
    created_at: datetime
    completed_at: Optional[datetime] = None
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None


class WebSocketManager:
    """Manages WebSocket connections and broadcasts."""

    def __init__(self):
        self.active_connections: Set[WebSocket] = set()

    async def connect(self, websocket: WebSocket):
        """Accept and register a new WebSocket connection."""
        await websocket.accept()
        self.active_connections.add(websocket)
        logger.debug(f"WebSocket connected. Total connections: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        """Remove a WebSocket connection."""
        self.active_connections.discard(websocket)
        logger.debug(f"WebSocket disconnected. Total connections: {len(self.active_connections)}")

    async def broadcast(self, message: Dict[str, Any]):
        """Broadcast message to all connected clients."""
        disconnected = set()

        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                logger.error(f"Error sending to WebSocket: {e}")
                disconnected.add(connection)

        # Remove disconnected clients
        for conn in disconnected:
            self.disconnect(conn)


class BackgroundJobService:
    """Service for managing background jobs and notifications."""

    def __init__(self):
        self.jobs: Dict[str, Job] = {}
        self.websocket_manager = WebSocketManager()

    def create_job(self, job_id: str, job_type: str, **kwargs) -> Job:
        """Create a new background job."""
        job = Job(
            job_id=job_id,
            job_type=job_type,
            status=JobStatus.PENDING,
            created_at=datetime.now(),
            **kwargs
        )
        self.jobs[job_id] = job
        logger.info(f"Created job: {job_id} ({job_type})")
        return job

    def get_job(self, job_id: str) -> Optional[Job]:
        """Get job by ID."""
        return self.jobs.get(job_id)

    async def update_job_status(
        self,
        job_id: str,
        status: JobStatus,
        result: Optional[Dict[str, Any]] = None,
        error: Optional[str] = None
    ):
        """Update job status and notify clients."""
        job = self.jobs.get(job_id)
        if not job:
            logger.warning(f"Job {job_id} not found")
            return

        job.status = status
        if status in [JobStatus.COMPLETED, JobStatus.FAILED]:
            job.completed_at = datetime.now()

        if result:
            job.result = result
        if error:
            job.error = error

        # Broadcast update to WebSocket clients
        await self.websocket_manager.broadcast({
            "type": "job_update",
            "job_id": job_id,
            "job_type": job.job_type,
            "status": job.status,
            "stock_symbol": job.stock_symbol,
            "result": result,
            "error": error,
            "timestamp": datetime.now().isoformat()
        })

        logger.info(f"Job {job_id} updated: {status}")

    def cleanup_old_jobs(self, max_age_hours: int = 24):
        """Remove completed jobs older than max_age_hours."""
        cutoff = datetime.now().timestamp() - (max_age_hours * 3600)
        to_remove = []

        for job_id, job in self.jobs.items():
            if job.status in [JobStatus.COMPLETED, JobStatus.FAILED]:
                if job.completed_at and job.completed_at.timestamp() < cutoff:
                    to_remove.append(job_id)

        for job_id in to_remove:
            del self.jobs[job_id]

        if to_remove:
            logger.info(f"Cleaned up {len(to_remove)} old jobs")


# Global instance
background_job_service = BackgroundJobService()

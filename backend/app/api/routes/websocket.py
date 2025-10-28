"""
WebSocket routes for real-time updates.
"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import logging

from backend.app.services.background_jobs import background_job_service

logger = logging.getLogger(__name__)

router = APIRouter()


@router.websocket("/ws/updates")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint for real-time job updates.

    Clients connect to receive notifications about:
    - Price fetch completion
    - News collection status
    - Background job progress
    """
    await background_job_service.websocket_manager.connect(websocket)

    try:
        # Keep connection alive and handle incoming messages
        while True:
            # Wait for any message from client (ping/pong, etc.)
            data = await websocket.receive_text()
            logger.debug(f"Received WebSocket message: {data}")

            # Optionally handle client messages here
            if data == "ping":
                await websocket.send_json({"type": "pong"})

    except WebSocketDisconnect:
        background_job_service.websocket_manager.disconnect(websocket)
        logger.debug("WebSocket client disconnected")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        background_job_service.websocket_manager.disconnect(websocket)

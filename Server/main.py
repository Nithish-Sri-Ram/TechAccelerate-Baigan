from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import json
import logging
import asyncio
from datetime import datetime
import uvicorn
from test import FallDetector

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()
connections = set()

# Initialize fall detector
detector = FallDetector()
detector_task = None

def handle_prediction(result):
    # Just log the prediction result - no extra processing
    if result["is_fall"]:
        logger.info(f"FALL DETECTED! Confidence: {result['confidence']:.4f}")
    
    # Send prediction to all connected clients
    message = json.dumps(result)
    for websocket in connections.copy():
        asyncio.create_task(websocket.send_text(message))

@app.get("/")
async def root():
    return {"message": "WebSocket Fall Detection Running"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    global detector_task
    
    await websocket.accept()
    connections.add(websocket)
    client_id = id(websocket)
    logger.info(f"Client {client_id} connected. Total connections: {len(connections)}")
    
    # Start detector processing loop if not already running
    if detector_task is None or detector_task.done():
        detector.running = True
        detector_task = asyncio.create_task(detector.start_processing(handle_prediction))
    
    try:
        while True:
            # Get data from client
            data_str = await websocket.receive_text()
            
            try:
                # Parse JSON to validate
                data = json.loads(data_str)
                
                # Update detector with latest data
                detector.update_data(data)
                
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON: {data_str}")
            except Exception as e:
                logger.error(f"Error: {str(e)}")
                
    except WebSocketDisconnect:
        connections.remove(websocket)
        logger.info(f"Client {client_id} disconnected. Remaining: {len(connections)}")
        
        # Stop detector if no connections left
        if len(connections) == 0 and detector_task is not None:
            detector.stop_processing()
            detector_task = None

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
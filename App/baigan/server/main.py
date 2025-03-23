from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import json
import logging
from datetime import datetime
import uvicorn

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Store active connections
connections = set()

@app.get("/")
async def root():
    return {"message": "WebSocket Server Running"}

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections.add(websocket)
    client_id = id(websocket)
    logger.info(f"Client {client_id} connected. Total connections: {len(connections)}")
    
    try:
        while True:
            # Receive text data from the client
            data_str = await websocket.receive_text()
            
            try:
                # Parse the data string to JSON
                data = json.loads(data_str)
                
                # Log the received data
                logger.info(f"Received data: {data}")
                
                # Send acknowledgment back to the client
                await websocket.send_json({
                    "status": "received",
                    "timestamp": datetime.now().isoformat()
                })
                    
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON received: {data_str}")
                await websocket.send_text("Error: Invalid JSON format")
            except Exception as e:
                logger.error(f"Error: {str(e)}")
                await websocket.send_text(f"Error: {str(e)}")
                
    except WebSocketDisconnect:
        connections.remove(websocket)
        logger.info(f"Client {client_id} disconnected. Remaining connections: {len(connections)}")

@app.websocket("/ws")
async def websocket_route(websocket: WebSocket):
    await websocket_endpoint(websocket)

# For running directly with Python
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
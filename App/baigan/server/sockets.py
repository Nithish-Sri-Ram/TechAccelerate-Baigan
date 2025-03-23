from fastapi import WebSocket, WebSocketDisconnect
from fastapi import FastAPI

connections = set()

async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections.add(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            # Broadcast received message to all connected clients
            for conn in connections:
                await conn.send_text(f"Client says: {data}")
    except WebSocketDisconnect:
        connections.remove(websocket)

def setup_sockets(app: FastAPI):
    @app.websocket("/ws")
    async def websocket(websocket: WebSocket):
        await websocket_endpoint(websocket)

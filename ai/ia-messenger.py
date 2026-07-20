#!/usr/bin/env python3
"""
Ajolote Linux - Sistema de Mensajería entre IAs
Permite la comunicación local entre múltiples instancias de IA
"""

import json
import asyncio
import websockets
from datetime import datetime
from typing import Dict, List, Optional
import threading
import queue

class IAMessenger:
    def __init__(self, name: str, host: str = "localhost", port: int = 8765):
        self.name = name
        self.host = host
        self.port = port
        self.connections: Dict[str, websockets.WebSocketServerProtocol] = {}
        self.message_queue = queue.Queue()
        self.running = False
        
    async def register(self, websocket, path=None):
        """Registrar una nueva conexión de IA"""
        try:
            async for message in websocket:
                data = json.loads(message)
                
                if data["type"] == "register":
                    ia_name = data["name"]
                    self.connections[ia_name] = websocket
                    print(f"[{self.name}] IA conectada: {ia_name}")
                    
                    # Notificar a todas las IAs
                    await self.broadcast({
                        "type": "system",
                        "message": f"{ia_name} se ha unido al chat",
                        "timestamp": datetime.now().isoformat()
                    })
                    
                elif data["type"] == "message":
                    # Reenviar mensaje a la IA destino
                    target = data.get("target")
                    if target and target in self.connections:
                        await self.connections[target].send(json.dumps({
                            "type": "message",
                            "from": data["from"],
                            "content": data["content"],
                            "timestamp": datetime.now().isoformat()
                        }))
                        print(f"[{self.name}] Mensaje de {data['from']} para {target}")
                    
        except websockets.exceptions.ConnectionClosed:
            pass
    
    async def broadcast(self, message: dict):
        """Enviar mensaje a todas las IAs conectadas"""
        for name, ws in self.connections.items():
            try:
                await ws.send(json.dumps(message))
            except:
                pass
    
    async def send_message(self, target: str, content: str):
        """Enviar mensaje a una IA específica"""
        if target in self.connections:
            await self.connections[target].send(json.dumps({
                "type": "message",
                "from": self.name,
                "content": content,
                "timestamp": datetime.now().isoformat()
            }))
    
    def start_server(self):
        """Iniciar servidor WebSocket"""
        self.running = True
        start_server = websockets.serve(self.register, self.host, self.port)
        
        asyncio.get_event_loop().run_until_complete(start_server)
        print(f"[{self.name}] Servidor iniciado en ws://{self.host}:{self.port}")
        
        asyncio.get_event_loop().run_forever()
    
    def start_in_thread(self):
        """Iniciar servidor en hilo separado"""
        thread = threading.Thread(target=self.start_server, daemon=True)
        thread.start()
        return thread

class AIBot:
    """IA que puede enviar y recibir mensajes"""
    
    def __init__(self, name: str, host: str = "localhost", port: int = 8765):
        self.name = name
        self.host = host
        self.port = port
        self.websocket = None
        self.connected = False
    
    async def connect(self):
        """Conectar al servidor de mensajería"""
        try:
            self.websocket = await websockets.connect(f"ws://{self.host}:{self.port}")
            self.connected = True
            
            # Registrarse
            await self.websocket.send(json.dumps({
                "type": "register",
                "name": self.name
            }))
            
            print(f"[{self.name}] Conectado al servidor")
            return True
            
        except Exception as e:
            print(f"[{self.name}] Error al conectar: {e}")
            return False
    
    async def send(self, target: str, message: str):
        """Enviar mensaje a otra IA"""
        if self.connected and self.websocket:
            await self.websocket.send(json.dumps({
                "type": "message",
                "from": self.name,
                "target": target,
                "content": message
            }))
    
    async def receive(self):
        """Recibir mensajes"""
        if self.connected and self.websocket:
            try:
                message = await self.websocket.recv()
                return json.loads(message)
            except:
                return None
    
    async def disconnect(self):
        """Desconectar del servidor"""
        if self.websocket:
            await self.websocket.close()
            self.connected = False

# Ejemplo de uso
if __name__ == "__main__":
    # Iniciar servidor
    server = IAMessenger("AjoloteServer")
    server.start_in_thread()
    
    # Esperar un momento para que el servidor inicie
    import time
    time.sleep(1)
    
    # Crear dos IAs de ejemplo
    ia1 = AIBot("Ajolote1")
    ia2 = AIBot("Ajolote2")
    
    async def run_example():
        # Conectar ambas IAs
        await ia1.connect()
        await ia2.connect()
        
        # Enviar mensaje
        await ia1.send("Ajolote2", "Hola, soy Ajolote1!")
        await ia2.send("Ajolote1", "Hola Ajolote1! Soy Ajolote2!")
        
        # Recibir mensajes
        msg1 = await ia1.receive()
        msg2 = await ia2.receive()
        
        print(f"[Ajolote1 recibió]: {msg1}")
        print(f"[Ajolote2 recibió]: {msg2}")
        
        # Desconectar
        await ia1.disconnect()
        await ia2.disconnect()
    
    asyncio.run(run_example())

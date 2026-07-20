#!/usr/bin/env python3
"""
Ajolote Linux - Configuración Híbrida de IA
Soporta Ollama local + APIs externas (OpenAI, Claude, etc.)
"""

import os
import json
import requests
from typing import Optional, Dict, Any
from dataclasses import dataclass
from enum import Enum

class AIProvider(Enum):
    OLLAMA_LOCAL = "ollama_local"
    OPENAI = "openai"
    CLAUDE = "claude"
    GEMINI = "gemini"
    HYBRID = "hybrid"

@dataclass
class AIConfig:
    provider: AIProvider
    model: str
    api_key: Optional[str] = None
    base_url: Optional[str] = None
    temperature: float = 0.7
    max_tokens: int = 2048

class HybridAI:
    def __init__(self):
        self.configs: Dict[str, AIConfig] = {}
        self.ollama_url = "http://localhost:11434"
        self._load_config()
    
    def _load_config(self):
        """Cargar configuración desde archivo"""
        config_path = os.path.expanduser("~/.config/ajolote/ai-config.json")
        
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                data = json.load(f)
                for name, config in data.items():
                    self.configs[name] = AIConfig(
                        provider=AIProvider(config["provider"]),
                        model=config["model"],
                        api_key=config.get("api_key"),
                        base_url=config.get("base_url"),
                        temperature=config.get("temperature", 0.7),
                        max_tokens=config.get("max_tokens", 2048)
                    )
        else:
            # Configuración por defecto: Ollama local
            self.configs["default"] = AIConfig(
                provider=AIProvider.OLLAMA_LOCAL,
                model="llama3"
            )
            self._save_config()
    
    def _save_config(self):
        """Guardar configuración en archivo"""
        config_path = os.path.expanduser("~/.config/ajolote/ai-config.json")
        os.makedirs(os.path.dirname(config_path), exist_ok=True)
        
        data = {}
        for name, config in self.configs.items():
            data[name] = {
                "provider": config.provider.value,
                "model": config.model,
                "api_key": config.api_key,
                "base_url": config.base_url,
                "temperature": config.temperature,
                "max_tokens": config.max_tokens
            }
        
        with open(config_path, 'w') as f:
            json.dump(data, f, indent=2)
    
    def add_config(self, name: str, config: AIConfig):
        """Agregar configuración de IA"""
        self.configs[name] = config
        self._save_config()
    
    async def query_ollama(self, prompt: str, model: str = "llama3") -> str:
        """Consultar Ollama local"""
        try:
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": model,
                    "prompt": prompt,
                    "stream": False
                },
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json()["response"]
            else:
                return f"Error: {response.status_code}"
                
        except Exception as e:
            return f"Error de conexión: {str(e)}"
    
    async def query_openai(self, prompt: str, config: AIConfig) -> str:
        """Consultar OpenAI API"""
        try:
            headers = {
                "Authorization": f"Bearer {config.api_key}",
                "Content-Type": "application/json"
            }
            
            data = {
                "model": config.model,
                "messages": [{"role": "user", "content": prompt}],
                "temperature": config.temperature,
                "max_tokens": config.max_tokens
            }
            
            response = requests.post(
                "https://api.openai.com/v1/chat/completions",
                headers=headers,
                json=data,
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json()["choices"][0]["message"]["content"]
            else:
                return f"Error: {response.status_code} - {response.text}"
                
        except Exception as e:
            return f"Error de conexión: {str(e)}"
    
    async def query(self, prompt: str, config_name: str = "default") -> str:
        """Consultar IA según configuración"""
        if config_name not in self.configs:
            return f"Configuración '{config_name}' no encontrada"
        
        config = self.configs[config_name]
        
        if config.provider == AIProvider.OLLAMA_LOCAL:
            return await self.query_ollama(prompt, config.model)
        elif config.provider == AIProvider.OPENAI:
            return await self.query_openai(prompt, config)
        else:
            return f"Proveedor {config.provider} no implementado aún"
    
    def list_configs(self) -> Dict[str, Dict]:
        """Listar todas las configuraciones"""
        result = {}
        for name, config in self.configs.items():
            result[name] = {
                "provider": config.provider.value,
                "model": config.model,
                "has_api_key": config.api_key is not None
            }
        return result

# Configuración de ejemplo
if __name__ == "__main__":
    ai = HybridAI()
    
    # Agregar configuración de OpenAI (opcional)
    # ai.add_config("openai", AIConfig(
    #     provider=AIProvider.OPENAI,
    #     model="gpt-4",
    #     api_key="tu-api-key-aqui"
    # ))
    
    print("Configuraciones disponibles:")
    print(json.dumps(ai.list_configs(), indent=2))
    
    # Ejemplo de consulta local
    # import asyncio
    # response = asyncio.run(ai.query("Hola, ¿cómo estás?"))
    # print(f"Respuesta: {response}")

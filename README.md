# Ajolote Linux 🦎

Una distribución de Linux personalizada con mascot ajolote e IA integrada.

## Características

- **XFCE** - Escritorio ligero y rápido
- **Mascota Ajolote** - Animación SVG que reacciona a eventos del sistema
- **IA Híbrida** - Ollama local + APIs externas (OpenAI, Claude, etc.)
- **Chat entre IAs** - Comunicación local via WebSocket
- **Tema personalizado** - Colores e iconos de ajolote

## Estructura del Proyecto

```
ajolote-linux/
├── config/           # Configuraciones de XFCE y sistema
├── scripts/          # Scripts de instalación y build
│   ├── install-base.sh    # Instalación base del sistema
│   └── build-iso.sh       # Build de ISO booteable
├── ai/               # Sistema de IA
│   ├── ia-messenger.py    # Mensajería entre IAs
│   └── ollama-config.py   # Configuración híbrida de IA
├── theme/            # Temas GTK, iconos, wallpapers
└── docs/             # Documentación
```

## Requisitos

### Para instalar en PC real
- 4GB+ RAM (8GB recomendado para IA)
- 20GB+ de espacio en disco
- Conexión a internet (para instalación)

### Para build de ISO
- Debian/Ubuntu como sistema anfitrión
- Paquetes: debootstrap, squashfs-tools, xorriso

## Instalación Rápida

### Opción 1: Instalar directamente
```bash
sudo ./scripts/install-base.sh
```

### Opción 2: Build de ISO
```bash
sudo ./scripts/build-iso.sh
```

## Configuración de IA

### IA Local (Ollama)
```bash
# Descargar modelo
ollama pull llama3

# Iniciar servidor
ollama serve
```

### IA en la Nube
```python
from ai.ollama_config import HybridAI, AIConfig, AIProvider

ai = HybridAI()
ai.add_config("openai", AIConfig(
    provider=AIProvider.OPENAI,
    model="gpt-4",
    api_key="tu-api-key"
))
```

## Chat entre IAs

```python
from ai.ia_messenger import IAMessenger, AIBot

# Iniciar servidor
server = IAMessenger("AjoloteServer")
server.start_in_thread()

# Conectar IAs
ia1 = AIBot("Ajolote1")
ia2 = AIBot("Ajolote2")

# Enviar mensajes
await ia1.send("Ajolote2", "Hola!")
```

## Personalización

### Cambiar modelo de Ollama
```bash
# Listar modelos disponibles
ollama list

# Descargar otro modelo
ollama pull mistral
ollama pull phi3
```

### Agregar modelos personalizados
Crea un archivo Modelfile:
```
FROM llama3
SYSTEM "Eres Ajolote, un asistente amigable con forma de ajolote"
```

Luego:
```bash
ollama create ajolote -f Modelfile
```

## Próximas Funcionalidades

- [ ] Interfaz gráfica para chat entre IAs
- [ ] Mascota animada en el escritorio
- [ ] Widgets de system tray
- [ ] Soporte para múltiples idiomas
- [ ] Installer gráfico (Calamares)

## Licencia

MIT License

## Contribuir

Las contribuciones son bienvenidas. Por favor abre un issue primero para discutir cambios.

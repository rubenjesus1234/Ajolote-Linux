#!/bin/bash
# Ajolote Linux - Instalar Tema de Iconos
# Copia los iconos a la ubicación correcta para XFCE

set -e

echo "=== Instalando Tema de Iconos Ajolote ==="

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS_DIR="$SCRIPT_DIR/../theme/icons"

# Verificar que existen los iconos
if [ ! -d "$ICONS_DIR" ]; then
    echo -e "${RED}No se encontró el directorio de iconos${NC}"
    exit 1
fi

# Directorio destino
DEST_DIR="$HOME/.icons/ajolote"

echo -e "${YELLOW}Copiando iconos a $DEST_DIR...${NC}"

# Crear directorio destino
mkdir -p "$DEST_DIR"

# Copiar iconos
cp -r "$ICONS_DIR"/* "$DEST_DIR/"

echo -e "${GREEN}Iconos instalados correctamente${NC}"
echo ""
echo -e "${GREEN}Para activar el tema:${NC}"
echo "1. Abre Configuración del Sistema"
echo "2. Ve a Apariencia > Iconos"
echo "3. Selecciona 'Ajolote'"
echo ""
echo -e "${GREEN}O ejecuta:${NC}"
echo "xfconf-query -c xsettings -p /Net/IconThemeName -s Ajolote"
echo ""

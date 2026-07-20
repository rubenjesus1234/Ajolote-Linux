#!/bin/bash
# Ajolote Linux - Convertir SVG a PNG
# Requiere: inkscape (sudo apt install inkscape)

set -e

echo "=== Conversor SVG a PNG ==="

ICON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../theme/icons"

# Verificar Inkscape
if ! command -v inkscape &> /dev/null; then
    echo "Instala Inkscape: sudo apt install inkscape"
    exit 1
fi

# Convertir todos los SVG a PNG
find "$ICON_DIR" -name "*.svg" | while read svg; do
    png="${svg%.svg}.png"
    echo "Convirtiendo: $(basename $svg)"
    inkscape "$svg" --export-filename="$png" -w 48 -h 48 2>/dev/null
done

echo "Conversión completada!"

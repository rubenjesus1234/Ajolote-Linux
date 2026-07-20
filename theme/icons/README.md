# Iconos Ajolote Linux

## Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Rosa pastel claro | `#FFC1CC` | Principal, carpetas |
| Rosa pastel | `#FFB5C5` | Secundario |
| Rosa oscuro | `#FF91A4` | Acentos, bordes |
| Gris claro | `#E8E8E8` | Fondos suaves |
| Gris medio | `#A9A9A9` | Elementos secundarios |
| Gris oscuro | `#808080` | Bordes, texto |
| Negro mate | `#2D2D2D` | Texto, sombras |
| Negro profundo | `#1A1A1A` | Fondo terminal |
| Verde | `#81C784` | Éxito, código |
| Azul | `#64B5F6` | Enlaces, imágenes |
| Amarillo | `#FFD54F` | Advertencias |
| Morado | `#CE93D8` | Música |

## Iconos Creados

### Places (Lugares)
- `folder.svg` - Carpeta base
- `folder-documents.svg` - Documentos
- `folder-download.svg` - Descargas
- `folder-music.svg` - Música
- `user-home.svg` - Casa/Inicio

### Apps (Aplicaciones)
- `terminal.svg` - Terminal
- `browser.svg` - Navegador
- `settings.svg` - Configuración

### MimeTypes (Archivos)
- `file.svg` - Archivo genérico
- `file-image.svg` - Imágenes
- `file-code.svg` - Código

### Status (Estado)
- `ok.svg` - Éxito/Confirmación
- `error.svg` - Error
- `warning.svg` - Advertencia
- `logout.svg` - Salir
- `shutdown.svg` - Apagar

## Agregar Más Iconos

1. Crear SVG con las dimensiones 48x48
2. Usar la paleta de colores definida
3. Guardar en la carpeta correspondiente
4. Actualizar `index.theme` si es necesario

## Convertir a PNG

```bash
sudo apt install inkscape
./scripts/convert-icons.sh
```

## Instalar Tema

```bash
cp -r theme/icons ~/.icons/ajolote
```

Luego seleccionar en Configuración > Apariencia > Iconos

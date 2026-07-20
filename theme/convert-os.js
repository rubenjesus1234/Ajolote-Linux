const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

async function convertOSIcon() {
    const pngPath = path.join(__dirname, 'Icono del OS.png');

    const size = 48;
    const resized = await sharp(pngPath)
        .resize(size, size, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
        .png()
        .toBuffer();

    const base64 = resized.toString('base64');

    const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" 
     xmlns:xlink="http://www.w3.org/1999/xlink"
     viewBox="0 0 ${size} ${size}" 
     width="${size}" height="${size}">
  <image x="0" y="0" width="${size}" height="${size}" 
         href="data:image/png;base64,${base64}"/>
</svg>`;

    fs.writeFileSync(path.join(__dirname, 'icons', '48x48', 'apps', 'ajolote-os.svg'), svg, 'utf8');
    fs.writeFileSync(path.join(__dirname, 'icons', '48x48', 'places', 'user-desktop.svg'), svg, 'utf8');
    console.log('Iconos 48x48 creados');
}

convertOSIcon().catch(e => console.error(e.message));

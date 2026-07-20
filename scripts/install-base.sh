#!/bin/bash
# Ajolote Linux - Instalación Base
# XFCE + Dependencias + Ollama

set -e

echo "=== Ajolote Linux - Instalación Base ==="
echo "Este script instala XFCE, Ollama y dependencias básicas"
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Por favor ejecuta como root: sudo ./install-base.sh${NC}"
    exit 1
fi

# Detectar distro
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
else
    echo -e "${RED}Gestor de paquetes no soportado${NC}"
    exit 1
fi

echo -e "${GREEN}Detectado gestor: $PKG_MANAGER${NC}"

# Actualizar sistema
echo -e "${YELLOW}Actualizando sistema...${NC}"
if [ "$PKG_MANAGER" = "apt" ]; then
    apt update && apt upgrade -y
elif [ "$PKG_MANAGER" = "dnf" ]; then
    dnf upgrade -y
elif [ "$PKG_MANAGER" = "pacman" ]; then
    pacman -Syu --noconfirm
fi

# Instalar XFCE y dependencias
echo -e "${YELLOW}Instalando XFCE4...${NC}"
if [ "$PKG_MANAGER" = "apt" ]; then
    apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
    apt install -y git curl wget build-essential python3 python3-pip
    apt install -y nodejs npm
    apt install -y network-manager network-manager-gnome
    apt install -y pulseaudio pavucontrol alsa-utils
    apt install -y thunar file-roller mousepad
elif [ "$PKG_MANAGER" = "dnf" ]; then
    dnf groupinstall -y "XFCE Desktop"
    dnf install -y lightdm lightdm-gtk-greeter
    dnf install -y git curl wget gcc gcc-c++ make python3 python3-pip
    dnf install -y nodejs npm
    dnf install -y NetworkManager network-manager-applet
    dnf install -y pulseaudio pavucontrol alsa-utils
elif [ "$PKG_MANAGER" = "pacman" ]; then
    pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
    pacman -S --noconfirm git curl wget base-devel python python-pip
    pacman -S --noconfirm nodejs npm
    pacman -S --noconfirm networkmanager network-manager-applet
    pacman -S --noconfirm pulseaudio pavucontrol alsa-utils
fi

# Instalar juegos
echo -e "${YELLOW}Instalando juegos preinstalados...${NC}"

# Juegos desde repos oficiales
if [ "$PKG_MANAGER" = "apt" ]; then
    # Luanti (Minetest) - Sandbox voxel
    apt install -y luanti 2>/dev/null || apt install -y minetest 2>/dev/null
    
    # Tuxemon - RPG monstruos (via flatpak o pip)
    apt install -y tuxemon 2>/dev/null || pip3 install tuxemon 2>/dev/null || true
    
    # Valyria Tear - JRPG
    apt install -y valyriatear 2>/dev/null || true
    
    # Taisei - Bullet hell Touhou-like
    apt install -y taisei 2>/dev/null || true
    
    # Feed Axel - Juego de axolotls (skip, repo no disponible)
fi

# Instalar XSpaceWar - space fighter
echo -e "${YELLOW}Instalando XSpaceWar-AI...${NC}"
mkdir -p /home/ajolote/juegos/xspacewar
wget -q "https://github.com/CryptoJones/XSpaceWar-AI/releases/download/v3.1.41/xspacewar-ai-linux-x86_64.zip" -O /tmp/xspacewar.zip 2>/dev/null || true
if [ -f /tmp/xspacewar.zip ]; then
    unzip -o /tmp/xspacewar.zip -d /home/ajolote/juegos/xspacewar/ 2>/dev/null || true
    chmod +x /home/ajolote/juegos/xspacewar/xspacewar-ai.x86_64 2>/dev/null || true
fi

# Crear acceso directo para XSpaceWar
cat > /home/ajolote/.local/share/applications/xspacewar.desktop << 'XSWDESKTOP'
[Desktop Entry]
Name=XSpaceWar-AI
Comment=Space fighter con IA
Exec=/home/ajolote/juegos/xspacewar/xspacewar-ai.x86_64
Icon=/home/ajolote/.themes/ajolote/icons/48x48/apps/ajolote-os.svg
Terminal=false
Type=Application
Categories=Game;Action;
XSWDESKTOP

# Instalar Konna - plataformero
echo -e "${YELLOW}Instalando Konna...${NC}"
mkdir -p /home/ajolote/juegos/konna
wget -q "https://tossu.itch.io/konna/download/eyJpZCI6MTI3OTIwOSwiZXhwaXJlcyI6MTc1MzAwNzkyMH0%3D.gYsrxI8UVrEQ61Kfj8BTpBQl9SI%3D" -O /tmp/konna.zip 2>/dev/null || true
if [ -f /tmp/konna.zip ]; then
    unzip -o /tmp/konna.zip -d /home/ajolote/juegos/konna/ 2>/dev/null || true
    chmod +x /home/ajolote/juegos/konna/KonnaLinux.x86_64 2>/dev/null || true
fi

# Crear acceso directo para Konna
cat > /home/ajolote/.local/share/applications/konna.desktop << 'KONNADESKTOP'
[Desktop Entry]
Name=Konna
Comment=Plataformero - una rana cerca del océano
Exec=/home/ajolote/juegos/konna/KonnaLinux.x86_64
Icon=/home/ajolote/.themes/ajolote/icons/48x48/apps/ajolote-os.svg
Terminal=false
Type=Application
Categories=Game;Platformer;
KONNADESKTOP

# Instalar Ruffle (emulador Flash) y PPGD
echo -e "${YELLOW}Instalando Ruffle y PPGD: Battle in Megaville...${NC}"
apt install -y ruffle 2>/dev/null || (
    mkdir -p /home/ajolote/juegos/ppgd
    # Descargar Ruffle standalone
    wget -q "https://github.com/ruffle-rs/ruffle/releases/latest/download/ruffle_standalone-linux-x86_64.tar.gz" -O /tmp/ruffle.tar.gz 2>/dev/null || true
    if [ -f /tmp/ruffle.tar.gz ]; then
        tar -xzf /tmp/ruffle.tar.gz -C /home/ajolote/juegos/ppgd/ 2>/dev/null || true
    fi
)

# Copiar PPGD si existe en los assets
if [ -f /tmp/ppgd/ppgd_battle_in_megaville.swf ]; then
    mkdir -p /home/ajolote/juegos/ppgd
    cp /tmp/ppgd/ppgd_battle_in_megaville.swf /home/ajolote/juegos/ppgd/
fi

# Crear acceso directo para PPGD
cat > /home/ajolote/.local/share/applications/ppgd.desktop << 'PPGDDESKTOP'
[Desktop Entry]
Name=PPGD: Battle in Megaville
Comment=Fighting game basado en Powerpuff Girls Doujinshi
Exec=ruffle /home/ajolote/juegos/ppgd/ppgd_battle_in_megaville.swf
Icon=/home/ajolote/.themes/ajolote/icons/48x48/apps/ajolote-os.svg
Terminal=false
Type=Application
Categories=Game;Action;
PPGDDESKTOP

# Crear Ajolote Pet (mini-juego propio)
echo -e "${YELLOW}Creando Ajolote Pet...${NC}"
mkdir -p /home/ajolote/ajolote-pet
cat > /home/ajolote/ajolote-pet/ajolote-pet.py << 'PYEOF'
#!/usr/bin/env python3
import tkinter as tk
import random
import time

class AjolotePet:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Ajolote Pet")
        self.root.geometry("300x350")
        self.root.configure(bg="#FFC1CC")
        
        self.hambre = 80
        self.felicidad = 50
        self.energia = 70
        
        self.canvas = tk.Canvas(self.root, width=200, height=180, bg="#FFC1CC", highlightthickness=0)
        self.canvas.pack(pady=10)
        
        # Dibujar ajolote
        self.body = self.canvas.create_oval(50, 40, 150, 140, fill="#FFB5C5", outline="#FF91A4", width=2)
        self.eye1 = self.canvas.create_oval(75, 60, 95, 80, fill="white", outline="#333", width=1)
        self.eye2 = self.canvas.create_oval(105, 60, 125, 80, fill="white", outline="#333", width=1)
        self.pup1 = self.canvas.create_oval(80, 65, 90, 75, fill="#333")
        self.pup2 = self.canvas.create_oval(110, 65, 120, 75, fill="#333")
        self.smile = self.canvas.create_line(85, 100, 100, 110, 115, 100, fill="#333", width=2)
        self.gill1 = self.canvas.create_line(55, 50, 35, 35, fill="#81C784", width=2)
        self.gill2 = self.canvas.create_line(55, 55, 30, 50, fill="#64B5F6", width=2)
        self.gill3 = self.canvas.create_line(145, 50, 165, 35, fill="#81C784", width=2)
        self.gill4 = self.canvas.create_line(145, 55, 170, 50, fill="#64B5F6", width=2)
        
        # Stats
        self.lbl_hambre = tk.Label(self.root, text=f"Hungry: {self.hambre}%", bg="#FFC1CC", fg="#333", font=("Arial", 10))
        self.lbl_hambre.pack()
        self.lbl_felicidad = tk.Label(self.root, text=f"Happy: {self.felicidad}%", bg="#FFC1CC", fg="#333", font=("Arial", 10))
        self.lbl_felicidad.pack()
        self.lbl_energia = tk.Label(self.root, text=f"Energy: {self.energia}%", bg="#FFC1CC", fg="#333", font=("Arial", 10))
        self.lbl_energia.pack()
        
        # Botones
        btn_frame = tk.Frame(self.root, bg="#FFC1CC")
        btn_frame.pack(pady=10)
        
        tk.Button(btn_frame, text=" Feed ", bg="#FF91A4", fg="white", command=self.feed, width=8).pack(side=tk.LEFT, padx=3)
        tk.Button(btn_frame, text=" Play ", bg="#64B5F6", fg="white", command=self.play, width=8).pack(side=tk.LEFT, padx=3)
        tk.Button(btn_frame, text=" Sleep ", bg="#81C784", fg="white", command=self.sleep, width=8).pack(side=tk.LEFT, padx=3)
        
        self.update_loop()
        self.root.mainloop()
    
    def update_stats(self):
        self.lbl_hambre.config(text=f"Hungry: {self.hambre}%")
        self.lbl_felicidad.config(text=f"Happy: {self.felicidad}%")
        self.lbl_energia.config(text=f"Energy: {self.energia}%")
        
        # Cambiar color segun estado
        if self.hambre < 30 or self.felicidad < 30 or self.energia < 30:
            self.canvas.itemconfig(self.body, fill="#FFC1CC")
        else:
            self.canvas.itemconfig(self.body, fill="#FFB5C5")
    
    def feed(self):
        self.hambre = min(100, self.hambre + 15)
        self.felicidad = min(100, self.felicidad + 5)
        self.update_stats()
    
    def play(self):
        if self.energia > 20:
            self.felicidad = min(100, self.felicidad + 15)
            self.energia = max(0, self.energia - 10)
            self.hambre = max(0, self.hambre - 5)
            self.canvas.move(self.body, 0, -10)
            self.root.after(200, lambda: self.canvas.move(self.body, 0, 10))
        self.update_stats()
    
    def sleep(self):
        self.energia = min(100, self.energia + 25)
        self.hambre = max(0, self.hambre - 5)
        self.update_stats()
    
    def update_loop(self):
        self.hambre = max(0, self.hambre - 1)
        self.felicidad = max(0, self.felicidad - 0.5)
        self.energia = max(0, self.energia - 0.5)
        self.update_stats()
        self.root.after(5000, self.update_loop)

if __name__ == "__main__":
    AjolotePet()
PYEOF
chmod +x /home/ajolote/ajolote-pet/ajolote-pet.py

# Crear acceso directo
mkdir -p /home/ajolote/.local/share/applications
cat > /home/ajolote/.local/share/applications/ajolote-pet.desktop << 'DESKTOPFILE'
[Desktop Entry]
Name=Ajolote Pet
Comment=Cuida a tu mascota ajolote
Exec=python3 /home/ajolote/ajolote-pet/ajolote-pet.py
Icon=/home/ajolote/.themes/ajolote/icons/48x48/apps/ajolote-os.svg
Terminal=false
Type=Application
Categories=Game;Simulation;
DESKTOPFILE

# Instalar Ollama
echo -e "${YELLOW}Instalando Ollama...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Descargar modelo básico
echo -e "${YELLOW}Descargando modelo de IA (llama3)...${NC}"
ollama pull llama3

# Habilitar servicios
echo -e "${YELLOW}Habilitando servicios...${NC}"
systemctl enable lightdm
systemctl enable NetworkManager
# Ollama no se habilita por defecto para ahorrar recursos
# systemctl enable ollama

# Configurar usuario
echo -e "${YELLOW}Configurando usuario ajolote...${NC}"
useradd -m -s /bin/bash ajolote 2>/dev/null || true
usermod -aG sudo ajolote 2>/dev/null || true

# Copiar configuraciones
echo -e "${YELLOW}Copiando configuraciones de Ajolote Linux...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$SCRIPT_DIR/../theme"
CONFIG_DIR="$SCRIPT_DIR/../config"

if [ -d "$CONFIG_DIR/xfce4" ]; then
    cp -r "$CONFIG_DIR/xfce4" "/home/ajolote/.config/"
fi

if [ -d "$THEME_DIR" ]; then
    mkdir -p "/home/ajolote/.themes/ajolote"
    cp -r "$THEME_DIR"/* "/home/ajolote/.themes/ajolote/"
fi

chown -R ajolote:ajolote /home/ajolote

echo ""
echo -e "${GREEN}=== Instalación completada ===${NC}"
echo -e "${GREEN}Reinicia el sistema para iniciar XFCE${NC}"
echo -e "${GREEN}Usuario: ajolote${NC}"
echo ""

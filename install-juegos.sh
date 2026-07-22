#!/bin/bash
# Ajolote Linux - Paquete de Juegos
# Solo instala los juegos seleccionados

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Ajolote Linux - Paquete de Juegos ===${NC}"
echo ""

# Verificar root
if [ "$EUID" -ne 0 ]; then
    echo "Ejecuta como root: sudo bash install-juegos.sh"
    exit 1
fi

# Crear usuario si no existe
id ajolote &>/dev/null || useradd -m -s /bin/bash ajolote

# Crear directorios
mkdir -p /home/ajolote/juegos
mkdir -p /home/ajolote/.local/share/applications
mkdir -p /home/ajolote/.themes/ajolote
mkdir -p /home/ajolote/.icons/ajolote

echo -e "${YELLOW}Instalando dependencias...${NC}"
apt update
apt install -y git curl wget unzip python3 python3-pip

# 1. Luanti (Minetest)
echo -e "${YELLOW}[1/8] Instalando Luanti...${NC}"
apt install -y luanti 2>/dev/null || apt install -y minetest 2>/dev/null || true

# 2. Tuxemon
echo -e "${YELLOW}[2/8] Instalando Tuxemon...${NC}"
pip3 install tuxemon 2>/dev/null || apt install -y tuxemon 2>/dev/null || true

# 3. Valyria Tear
echo -e "${YELLOW}[3/8] Instalando Valyria Tear...${NC}"
apt install -y valyriatear 2>/dev/null || true

# 4. Taisei
echo -e "${YELLOW}[4/8] Instalando Taisei...${NC}"
apt install -y taisei 2>/dev/null || true

# 5. XSpaceWar-AI
echo -e "${YELLOW}[5/8] Instalando XSpaceWar-AI...${NC}"
mkdir -p /home/ajolote/juegos/xspacewar
wget -q "https://github.com/CryptoJones/XSpaceWar-AI/releases/download/v3.1.41/xspacewar-ai-linux-x86_64.zip" -O /tmp/xspacewar.zip 2>/dev/null || true
if [ -f /tmp/xspacewar.zip ]; then
    unzip -o /tmp/xspacewar.zip -d /home/ajolote/juegos/xspacewar/ 2>/dev/null || true
    chmod +x /home/ajolote/juegos/xspacewar/xspacewar-ai.x86_64 2>/dev/null || true
fi

# 6. Ruffle + PPGD (Powerpuff Girls Doujinshi)
echo -e "${YELLOW}[6/8] Instalando Ruffle + PPGD...${NC}"
mkdir -p /home/ajolote/juegos/ppgd
wget -q "https://github.com/ruffle-rs/ruffle/releases/latest/download/ruffle_standalone-linux-x86_64.tar.gz" -O /tmp/ruffle.tar.gz 2>/dev/null || true
if [ -f /tmp/ruffle.tar.gz ]; then
    tar -xzf /tmp/ruffle.tar.gz -C /home/ajolote/juegos/ppgd/ 2>/dev/null || true
fi

# 7. Konna
echo -e "${YELLOW}[7/8] Instalando Konna...${NC}"
mkdir -p /home/ajolote/juegos/konna

# 8. Juegos Flash (via Ruffle)
echo -e "${YELLOW}[8/13] Descargando juegos Flash...${NC}"
mkdir -p /home/ajolote/juegos/flash

# Alien Hominid (2002, Newgrounds)
wget -q "https://archive.org/download/flash_alien_hominid/alien%20hominid.swf" -O /home/ajolote/juegos/flash/alien-hominid.swf 2>/dev/null || true

# Learn to Fly (2004)
wget -q "https://archive.org/download/flash_learn-to-fly/learn%20to%20fly.swf" -O /home/ajolote/juegos/flash/learn-to-fly.swf 2>/dev/null || true

# Fancy Pants Adventure (2006, Brad Borne)
wget -q "https://archive.org/download/fancypantsadventure_202011/Fancy%20Pants%20Adventure.swf" -O /home/ajolote/juegos/flash/fancy-pants-adventure.swf 2>/dev/null || true

# Super Smash Flash (2006, McLeodGaming)
wget -q "https://archive.org/download/supersmashflash_swf/Super%20Smash%20Flash.swf" -O /home/ajolote/juegos/flash/super-smash-flash.swf 2>/dev/null || true

# Plants vs Zombies Flash (2009, PopCap)
wget -q "https://archive.org/download/plants-vs-zombies-swf/Plants%20vs.%20Zombies.swf" -O /home/ajolote/juegos/flash/plants-vs-zombies.swf 2>/dev/null || true

# Crear accesos directos para juegos Flash
for swf in /home/ajolote/juegos/flash/*.swf; do
    name=$(basename "$swf" .swf)
    cat > "/home/ajolote/.local/share/applications/flash-${name}.desktop" << DESKTOP
[Desktop Entry]
Name=${name}
Comment=Juego Flash - via Ruffle
Exec=ruffle ${swf}
Terminal=false
Type=Application
Categories=Game;
DESKTOP
done

echo "Juegos Flash instalados:" 2>/dev/null || true
ls /home/ajolote/juegos/flash/*.swf 2>/dev/null | wc -l 2>/dev/null || true

# 8. Ajolote Pet (mascota virtual)
echo -e "${YELLOW}[8/8] Creando Ajolote Pet...${NC}"
mkdir -p /home/ajolote/ajolote-pet
cat > /home/ajolote/ajolote-pet/ajolote-pet.py << 'PYEOF'
#!/usr/bin/env python3
import tkinter as tk
import random

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

        self.body = self.canvas.create_oval(50, 40, 150, 140, fill="#FFB5C5", outline="#FF91A4", width=2)
        self.eye1 = self.canvas.create_oval(75, 60, 95, 80, fill="white", outline="#333", width=1)
        self.eye2 = self.canvas.create_oval(105, 60, 125, 80, fill="white", outline="#333", width=1)
        self.pup1 = self.canvas.create_oval(80, 65, 90, 75, fill="#333")
        self.pup2 = self.canvas.create_oval(110, 65, 120, 75, fill="#333")
        self.smile = self.canvas.create_line(85, 100, 100, 110, 115, 100, fill="#333", width=2)

        self.lbl_hambre = tk.Label(self.root, text=f"Hambre: {self.hambre}%", bg="#FFC1CC", fg="#333", font=("Arial", 10))
        self.lbl_hambre.pack()
        self.lbl_felicidad = tk.Label(self.root, text=f"Felicidad: {self.felicidad}%", bg="#FFC1CC", fg="#333", font=("Arial", 10))
        self.lbl_felicidad.pack()
        self.lbl_energia = tk.Label(self.root, text=f"Energia: {self.energia}%", bg="#FFC1CC", fg="#333", font=("Arial", 10))
        self.lbl_energia.pack()

        btn_frame = tk.Frame(self.root, bg="#FFC1CC")
        btn_frame.pack(pady=10)

        tk.Button(btn_frame, text=" Comer ", bg="#FF91A4", fg="white", command=self.feed, width=8).pack(side=tk.LEFT, padx=3)
        tk.Button(btn_frame, text=" Jugar ", bg="#64B5F6", fg="white", command=self.play, width=8).pack(side=tk.LEFT, padx=3)
        tk.Button(btn_frame, text=" Dormir ", bg="#81C784", fg="white", command=self.sleep, width=8).pack(side=tk.LEFT, padx=3)

        self.update_loop()
        self.root.mainloop()

    def update_stats(self):
        self.lbl_hambre.config(text=f"Hambre: {self.hambre}%")
        self.lbl_felicidad.config(text=f"Felicidad: {self.felicidad}%")
        self.lbl_energia.config(text=f"Energia: {self.energia}%")

    def feed(self):
        self.hambre = min(100, self.hambre + 15)
        self.felicidad = min(100, self.felicidad + 5)
        self.update_stats()

    def play(self):
        if self.energia > 20:
            self.felicidad = min(100, self.felicidad + 15)
            self.energia = max(0, self.energia - 10)
            self.hambre = max(0, self.hambre - 5)
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

# Crear accesos directos
cat > /home/ajolote/.local/share/applications/ajolote-pet.desktop << 'EOF'
[Desktop Entry]
Name=Ajolote Pet
Comment=Cuida a tu mascota ajolote
Exec=python3 /home/ajolote/ajolote-pet/ajolote-pet.py
Terminal=false
Type=Application
Categories=Game;Simulation;
EOF

cat > /home/ajolote/.local/share/applications/xspacewar.desktop << 'EOF'
[Desktop Entry]
Name=XSpaceWar-AI
Comment=Space fighter con IA
Exec=/home/ajolote/juegos/xspacewar/xspacewar-ai.x86_64
Terminal=false
Type=Application
Categories=Game;Action;
EOF

# Permisos
chown -R ajolote:ajolote /home/ajolote/juegos
chown -R ajolote:ajolote /home/ajolote/.local
chown -R ajolote:ajolote /home/ajolote/ajolote-pet

echo ""
echo -e "${GREEN}=== Paquete de juegos instalado ===${NC}"
echo ""
echo "Juegos instalados:"
echo "  - Luanti (Minetest)"
echo "  - Tuxemon (RPG tipo Pokemon)"
echo "  - Valyria Tear (JRPG)"
echo "  - Taisei (Bullet hell)"
echo "  - XSpaceWar-AI (Space fighter)"
echo "  - Ruffle + PPGD (Powerpuff Girls)"
echo "  - Konna (Plataformero)"
echo "  - Ajolote Pet (Mascota virtual)"

#!/bin/bash
# Ajolote Linux - Script de Build para ISO
# Genera una ISO booteable con todo configurado

set -e

echo "=== Ajolote Linux - Build de ISO ==="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar dependencias
check_dependencies() {
    echo -e "${YELLOW}Verificando dependencias...${NC}"
    
    DEPS=("debootstrap" "mksquashfs" "xorriso" "mtools" "mkfs.vfat")
    
    for dep in "${DEPS[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${RED}Falta: $dep${NC}"
            echo "Instala con: sudo apt install ${DEPS[*]}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}Dependencias OK${NC}"
}

# Estructura de directorios
WORK_DIR="/tmp/ajolote-build"
ROOT_DIR="$WORK_DIR/root"
IMAGE_DIR="$WORK_DIR/image"

setup_directories() {
    echo -e "${YELLOW}Preparando directorios...${NC}"
    
    sudo rm -rf $WORK_DIR
    mkdir -p $ROOT_DIR $IMAGE_DIR
}

# Instalar sistema base
install_base_system() {
    echo -e "${YELLOW}Instalando sistema base...${NC}"
    
    sudo debootstrap --arch=amd64 bookworm $ROOT_DIR http://deb.debian.org/debian
    
    # Montar sistemas de archivos
    sudo mount --bind /dev $ROOT_DIR/dev
    sudo mount --bind /dev/pts $ROOT_DIR/dev/pts
    sudo mount -t proc proc $ROOT_DIR/proc
    sudo mount -t sysfs sysfs $ROOT_DIR/sys
    
    # Chroot e instalar paquetes
    sudo chroot $ROOT_DIR /bin/bash << 'EOF'
        export DEBIAN_FRONTEND=noninteractive
        
        # Actualizar
        apt update
        
        # Instalar XFCE y escritorio
        apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        
        # Instalar utilidades
        apt install -y network-manager network-manager-gnome
        apt install -y pulseaudio pavucontrol alsa-utils
        apt install -y thunar file-roller mousepad
        apt install -y git curl wget build-essential
        
        # Instalar Node.js
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs
        
        # Instalar Python
        apt install -y python3 python3-pip python3-venv
        
        # Instalar Ollama
        curl -fsSL https://ollama.com/install.sh | sh
        
        # Crear usuario
        useradd -m -s /bin/bash ajolote
        echo "ajolote:ajolote" | chpasswd
        usermod -aG sudo ajolote
        
        # Configurar login automático
        mkdir -p /etc/lightdm/lightdm.conf.d
        cat > /etc/lightdm/lightdm.conf.d/50-ajolote.conf << 'LIGHTDM'
[Seat:*]
autologin-user=ajolote
autologin-session=xfce
LIGHTDM
        
        # Habilitar servicios
        systemctl enable lightdm
        systemctl enable NetworkManager
        systemctl enable ollama
        
        # Limpiar caché
        apt clean
        apt autoremove
EOF
    
    # Desmontar sistemas de archivos
    sudo umount $ROOT_DIR/dev/pts
    sudo umount $ROOT_DIR/dev
    sudo umount $ROOT_DIR/proc
    sudo umount $ROOT_DIR/sys
}

# Copiar configuraciones de Ajolote
copy_ajolote_files() {
    echo -e "${YELLOW}Copiando archivos de Ajolote Linux...${NC}"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_DIR="$SCRIPT_DIR/.."
    
    # Copiar configuraciones
    if [ -d "$PROJECT_DIR/config" ]; then
        sudo cp -r $PROJECT_DIR/config/* $ROOT_DIR/home/ajolote/.config/ 2>/dev/null || true
    fi
    
    # Copiar temas
    if [ -d "$PROJECT_DIR/theme" ]; then
        sudo mkdir -p $ROOT_DIR/home/ajolote/.themes/ajolote
        sudo cp -r $PROJECT_DIR/theme/* $ROOT_DIR/home/ajolote/.themes/ajolote/
    fi
    
    # Copiar scripts de IA
    if [ -d "$PROJECT_DIR/ai" ]; then
        sudo mkdir -p $ROOT_DIR/home/ajolote/ajolote-ai
        sudo cp -r $PROJECT_DIR/ai/* $ROOT_DIR/home/ajolote/ajolote-ai/
    fi
    
    # Copiar juegos y assets
    if [ -d "$PROJECT_DIR/assets/games" ]; then
        sudo mkdir -p $ROOT_DIR/home/ajolote/juegos
        sudo cp -r $PROJECT_DIR/assets/games/* $ROOT_DIR/home/ajolote/juegos/
    fi
    
    # Permisos
    sudo chown -R 1000:1000 $ROOT_DIR/home/ajolote/
}

# Crear filesystem squashfs
create_squashfs() {
    echo -e "${YELLOW}Creando imagen squashfs...${NC}"
    
    sudo mksquashfs $ROOT_DIR $IMAGE_DIR/casper/filesystem.squashfs -comp xz -e boot
    
    # Copiar kernel
    sudo cp $ROOT_DIR/boot/vmlinuz-* $IMAGE_DIR/casper/vmlinuz
    sudo cp $ROOT_DIR/boot/initrd.img-* $IMAGE_DIR/casper/initrd
    
    # Crear info
    echo "Ajolote Linux 1.0" > $IMAGE_DIR/README.txt
    echo "Una distribución con mascota ajolote e IA integrada" >> $IMAGE_DIR/README.txt
}

# Crear imagen ISO
create_iso() {
    echo -e "${YELLOW}Creando imagen ISO...${NC}"
    
    sudo xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "AJOLOTE_LINUX" \
        -output "$WORK_DIR/ajolote-linux-1.0.iso" \
        -eltorito-boot isolinux/boot.cat \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            --eltorito-catalog isolinux/boot.cat \
        $IMAGE_DIR
    
    echo -e "${GREEN}ISO creada en: $WORK_DIR/ajolote-linux-1.0.iso${NC}"
}

# Limpiar
cleanup() {
    echo -e "${YELLOW}Limpiando...${NC}"
    sudo umount $ROOT_DIR/dev/pts 2>/dev/null || true
    sudo umount $ROOT_DIR/dev 2>/dev/null || true
    sudo umount $ROOT_DIR/proc 2>/dev/null || true
    sudo umount $ROOT_DIR/sys 2>/dev/null || true
}

# Main
main() {
    check_dependencies
    setup_directories
    install_base_system
    copy_ajolote_files
    create_squashfs
    create_iso
    cleanup
    
    echo ""
    echo -e "${GREEN}=== Build completado ===${NC}"
    echo -e "${GREEN}ISO: $WORK_DIR/ajolote-linux-1.0.iso${NC}"
    echo ""
}

# Manejar errores
trap cleanup EXIT

# Ejecutar
main "$@"

#!/bin/bash
# WSL GUI Setup Script for Ubuntu/Debian
# Run with: sudo bash gui-setup.sh

set -e

echo "=================================="
echo "  WSL GUI Desktop Setup Script"
echo "=================================="
echo

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    echo "Detected distribution: $DISTRO"
else
    echo "Cannot detect distribution"
    exit 1
fi

# Update system
echo
echo "[1/5] Updating system packages..."
apt update && apt upgrade -y

# Install common dependencies
echo
echo "[2/5] Installing common dependencies..."
apt install -y \
    dbus-x11 \
    x11-apps \
    x11-utils \
    x11-xserver-utils \
    mesa-utils \
    libgl1-mesa-glx \
    fonts-noto \
    fonts-noto-cjk \
    locales

# Generate locales
locale-gen en_US.UTF-8

# Select and install desktop environment
echo
echo "[3/5] Select desktop environment:"
echo "  1) XFCE (Lightweight, Recommended)"
echo "  2) GNOME (Full Featured)"
echo "  3) KDE Plasma (Beautiful)"
echo "  4) LXQt (Very Lightweight)"
echo "  5) MATE (Traditional)"
echo "  6) Cinnamon (Modern)"
echo
read -p "Enter choice [1-6]: " DE_CHOICE

case $DE_CHOICE in
    1)
        echo "Installing XFCE..."
        DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies xfce4-terminal
        DE_START="startxfce4"
        ;;
    2)
        echo "Installing GNOME..."
        DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop gnome-terminal
        DE_START="gnome-session"
        ;;
    3)
        echo "Installing KDE Plasma..."
        DEBIAN_FRONTEND=noninteractive apt install -y kde-plasma-desktop konsole
        DE_START="startplasma-x11"
        ;;
    4)
        echo "Installing LXQt..."
        DEBIAN_FRONTEND=noninteractive apt install -y lxqt qterminal
        DE_START="startlxqt"
        ;;
    5)
        echo "Installing MATE..."
        DEBIAN_FRONTEND=noninteractive apt install -y mate-desktop-environment mate-terminal
        DE_START="mate-session"
        ;;
    6)
        echo "Installing Cinnamon..."
        DEBIAN_FRONTEND=noninteractive apt install -y cinnamon-desktop-environment gnome-terminal
        DE_START="cinnamon-session"
        ;;
    *)
        echo "Invalid choice, installing XFCE..."
        DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies
        DE_START="startxfce4"
        ;;
esac

# Configure display
echo
echo "[4/5] Configuring display settings..."

cat > /etc/profile.d/wsl-display.sh << 'EOF'
# WSL Display Configuration
export DISPLAY=:0
export LIBGL_ALWAYS_INDIRECT=1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

# Create runtime directory if needed
if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    sudo mkdir -p "$XDG_RUNTIME_DIR"
    sudo chmod 700 "$XDG_RUNTIME_DIR"
    sudo chown $(id -u):$(id -g) "$XDG_RUNTIME_DIR"
fi
EOF

chmod +x /etc/profile.d/wsl-display.sh

# Create start script
echo
echo "[5/5] Creating start script..."

cat > /usr/local/bin/start-gui << EOF
#!/bin/bash
source /etc/profile.d/wsl-display.sh
dbus-launch --exit-with-session $DE_START
EOF

chmod +x /usr/local/bin/start-gui

echo
echo "=================================="
echo "  GUI Installation Complete!"
echo "=================================="
echo
echo "To start GUI:"
echo "  From Windows: Run start-gui.bat"
echo "  From WSL: start-gui"
echo
echo "Make sure you have an X Server running:"
echo "  - VcXsrv or GWSL on Windows"
echo "  - Or use WSLg on Windows 11"
echo

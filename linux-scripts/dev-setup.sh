#!/bin/bash
# Development Environment Setup Script
# Run with: sudo bash dev-setup.sh

set -e

echo "=================================="
echo "  Development Environment Setup"
echo "=================================="
echo

# Update system
echo "[1/8] Updating system..."
apt update && apt upgrade -y

# Install build essentials
echo
echo "[2/8] Installing build tools..."
apt install -y \
    build-essential \
    gcc g++ make cmake \
    gdb valgrind \
    pkg-config \
    autoconf automake libtool

# Install Git and version control
echo
echo "[3/8] Installing Git..."
apt install -y git git-lfs curl wget
git config --global init.defaultBranch main

# Install Node.js
echo
echo "[4/8] Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g yarn pnpm npm@latest

# Install Python
echo
echo "[5/8] Installing Python..."
apt install -y python3 python3-pip python3-venv python3-dev
pip3 install --upgrade pip
pip3 install virtualenv pipenv

# Install Go
echo
echo "[6/8] Installing Go..."
wget -q https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
rm go1.22.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh

# Install Rust
echo
echo "[7/8] Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Install Java
echo
echo "[8/8] Installing Java..."
apt install -y openjdk-17-jdk maven gradle

# Install additional tools
echo
echo "Installing additional tools..."
apt install -y \
    jq vim nano \
    htop tree \
    net-tools \
    zip unzip \
    sqlite3 \
    redis-tools \
    postgresql-client

echo
echo "=================================="
echo "  Development Setup Complete!"
echo "=================================="
echo
echo "Installed:"
echo "  - GCC/G++, Make, CMake"
echo "  - Git"
echo "  - Node.js $(node --version)"
echo "  - Python $(python3 --version)"
echo "  - Go 1.22"
echo "  - Rust"
echo "  - Java 17"
echo

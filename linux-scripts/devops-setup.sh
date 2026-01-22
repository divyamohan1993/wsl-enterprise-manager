#!/bin/bash
# DevOps Environment Setup Script
# Run with: sudo bash devops-setup.sh

set -e

echo "=================================="
echo "  DevOps Environment Setup"
echo "=================================="
echo

# Update system
echo "[1/10] Updating system..."
apt update && apt upgrade -y

# Install base tools
echo
echo "[2/10] Installing base tools..."
apt install -y curl wget git vim nano jq yq unzip

# Install Docker
echo
echo "[3/10] Installing Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker $SUDO_USER
systemctl enable docker 2>/dev/null || true

# Install Docker Compose
echo
echo "[4/10] Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install kubectl
echo
echo "[5/10] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Helm
echo
echo "[6/10] Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Terraform
echo
echo "[7/10] Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform

# Install Ansible
echo
echo "[8/10] Installing Ansible..."
apt install -y ansible

# Install cloud CLIs
echo
echo "[9/10] Installing cloud CLIs..."

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install k9s
echo
echo "[10/10] Installing k9s..."
curl -sS https://webinstall.dev/k9s | bash

echo
echo "=================================="
echo "  DevOps Setup Complete!"
echo "=================================="
echo
echo "Installed:"
echo "  - Docker & Docker Compose"
echo "  - kubectl & Helm"
echo "  - Terraform"
echo "  - Ansible"
echo "  - AWS CLI & Azure CLI"
echo "  - k9s"
echo

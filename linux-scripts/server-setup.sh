#!/bin/bash
# Server Hardening Script
# Run with: sudo bash server-setup.sh

set -e

echo "=================================="
echo "  Server Security Setup"
echo "=================================="
echo

# Update system
echo "[1/8] Updating system..."
apt update && apt upgrade -y

# Install security packages
echo
echo "[2/8] Installing security packages..."
apt install -y \
    ufw \
    fail2ban \
    unattended-upgrades \
    apt-listchanges \
    logwatch \
    rkhunter \
    clamav

# Configure firewall
echo
echo "[3/8] Configuring UFW firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable
ufw status

# Configure SSH
echo
echo "[4/8] Hardening SSH..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply SSH hardening
cat >> /etc/ssh/sshd_config.d/hardening.conf << 'EOF'
PermitRootLogin no
MaxAuthTries 3
PasswordAuthentication yes
PubkeyAuthentication yes
AuthenticationMethods publickey,password
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
TCPKeepAlive yes
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

# Configure Fail2Ban
echo
echo "[5/8] Configuring Fail2Ban..."
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
ignoreip = 127.0.0.1/8

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# Configure automatic updates
echo
echo "[6/8] Configuring automatic updates..."
dpkg-reconfigure -f noninteractive unattended-upgrades

# Set proper permissions
echo
echo "[7/8] Setting file permissions..."
chmod 700 /root
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

# Configure logging
echo
echo "[8/8] Configuring logging..."
apt install -y rsyslog
systemctl enable rsyslog

echo
echo "=================================="
echo "  Security Setup Complete!"
echo "=================================="
echo
echo "Applied:"
echo "  - UFW firewall (SSH allowed)"
echo "  - SSH hardening"
echo "  - Fail2Ban (SSH protection)"
echo "  - Automatic security updates"
echo "  - Enhanced logging"
echo
echo "Restart SSH to apply changes: sudo service ssh restart"
echo

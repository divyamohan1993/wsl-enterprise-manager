# WSL Forensics Directory

This directory stores forensic reports collected before WSL distribution destruction.

## Report Contents

Each forensic report includes:

### Host System Information
- Computer name
- Windows version
- System specifications
- Current user
- Network configuration

### WSL Environment
- WSL version
- All installed distributions
- WSL status

### Per-Distribution Data
- OS release information
- Kernel version
- System uptime

### User Information
- All users (/etc/passwd)
- Groups (/etc/group)
- Sudo users
- Login history
- Failed login attempts

### Shell History
- Bash history (root and user)
- Zsh history (root and user)

### Installed Packages
- APT packages (Debian/Ubuntu)
- RPM packages (RHEL/Fedora)
- Snap packages
- Pip packages
- NPM global packages

### Network Configuration
- Network interfaces
- Routing table
- DNS configuration
- Hosts file
- Open ports
- Active connections

### Filesystem Information
- Disk usage
- Mount points
- Home directory contents
- Recently modified files

### Security Information
- SSH configuration
- Authorized SSH keys
- Firewall status
- SUID files

### Docker Information
- Docker containers
- Docker images

### Services
- Enabled services
- Running services

### Logs
- Authentication logs (last 100 lines)
- System logs (last 50 lines)

## File Naming

Reports are named using the format:
```
{distribution_name}_forensic_{YYYYMMDD_HHMMSS}.txt
```

## Usage

Forensic reports are automatically generated when using:
- `destructor.bat` - Single or all distribution removal
- `wsl-manager.bat` → Option 7 → Uninstall & Cleanup

## Retention

It is recommended to:
1. Review forensic reports after destruction if needed
2. Archive important reports to secure storage
3. Delete old reports periodically to save space

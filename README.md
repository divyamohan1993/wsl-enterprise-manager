> **⚠️ DEVELOPMENT STATUS: ALPHA**
>
> This project is currently **in development** and **more than 80% of the functions are currently failing**. Many things may not work as expected. Please report any issues you encounter.
>
> This is an **Aatmnirbhar Bharat public welfare initiative by dmj.one**, similar to our other initiatives. Feel free to research dmj.one for more information.

# WSL Enterprise Manager v2.0

![WSL Manager](https://img.shields.io/badge/WSL-Enterprise%20Manager-blue)
![Version](https://img.shields.io/badge/Version-2.0.0-green)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

A comprehensive, enterprise-grade Windows Subsystem for Linux (WSL) management suite. One-click installation, GUI desktop environments, advanced configuration, and production-ready deployment tools.

## ✨ Features

### 🚀 Quick Setup
- **One-Click Installation**: Set up WSL in minutes
- **GUI or Headless**: Choose between desktop environments or CLI-only
- **Multi-OS Support**: Ubuntu, Debian, Kali, Fedora, Alpine, Arch, and more
- **GUI Desktop Environments**: GNOME, KDE Plasma, XFCE, LXQt, MATE, Cinnamon

### 💼 Enterprise Features
- **Backup & Export**: Full distribution backup with scheduling
- **Import & Restore**: Easy migration and disaster recovery
- **Multi-Instance**: Run multiple instances of the same distribution
- **Resource Monitoring**: Real-time CPU, memory, and disk monitoring
- **Forensic Collection**: Complete system dump before destruction for auditing

### 🔧 Advanced Management
- **Storage Management**: VHD compaction, resize, and relocation
- **Network Configuration**: Port forwarding, DNS, SSH setup
- **Security Hardening**: Firewall, Fail2Ban, SSH hardening
- **Docker Integration**: Container setup and management

### 📦 Development Presets
- **Full Stack Web**: Node.js, Python, Docker, Databases
- **Data Science**: Python, Jupyter, Scientific libraries
- **DevOps/SRE**: Docker, Kubernetes, Terraform, Ansible
- **System Programming**: C/C++, Rust, Go

## 📁 Directory Structure

```
wsl-gui/
├── wsl-manager.bat          # Main management interface
├── README.md                 # This documentation
│
├── scripts/                  # Windows batch scripts
│   ├── quick-setup.bat       # One-click WSL installation
│   ├── install-gui.bat       # GUI desktop installer
│   ├── start-gui.bat         # Launch GUI desktop
│   ├── destructor.bat        # Uninstall with forensic dump
│   ├── backup.bat            # Backup & export manager
│   ├── dev-setup.bat         # Development environment
│   ├── docker-setup.bat      # Docker/container setup
│   ├── security.bat          # Security hardening
│   ├── network.bat           # Network configuration
│   ├── storage.bat           # Storage management
│   ├── config.bat            # Global WSL configuration
│   ├── monitor.bat           # Resource monitoring
│   ├── scheduler.bat         # Scheduled tasks manager
│   ├── multi-instance.bat    # Multi-instance management
│   ├── healthcheck.bat       # System diagnostics
│   └── update.bat            # Update manager
│
├── linux-scripts/            # Linux shell scripts
│   ├── gui-setup.sh          # Comprehensive GUI setup
│   ├── dev-setup.sh          # Development tools
│   ├── devops-setup.sh       # DevOps environment
│   └── server-setup.sh       # Server hardening
│
├── config/                   # Configuration files
│   └── wslconfig.template    # .wslconfig template
│
├── forensics/                # Forensic reports (before destruction)
├── logs/                     # Operation logs
├── exports/                  # Distribution backups
└── backups/                  # Configuration backups
```

## 🚀 Quick Start

### Prerequisites
- Windows 10 version 2004+ or Windows 11
- Administrator privileges
- Internet connection

### Installation

1. **Clone or Download** this repository:
   ```cmd
   git clone https://github.com/yourusername/wsl-gui.git
   cd wsl-gui
   ```

2. **Run the Quick Setup** (as Administrator):
   ```cmd
   scripts\quick-setup.bat
   ```

3. **Or use the full manager**:
   ```cmd
   wsl-manager.bat
   ```

### First-Time WSL Setup

If WSL is not installed, the script will:
1. Enable Windows Subsystem for Linux feature
2. Enable Virtual Machine Platform
3. Set WSL 2 as default
4. Prompt for system restart

After restart, run the script again to install your preferred distribution.

## 📖 Usage Guide

### Main Menu Options

| Option | Description |
|--------|-------------|
| **1** | Quick Install (GUI/Headless) - Choose OS and installation type |
| **2** | List All Installations - View installed and available distributions |
| **3** | Advanced Installation - Custom paths, cloning, presets |
| **4** | Manage Existing WSL - Start, stop, configure distributions |
| **5** | Backup & Export - Create distribution backups |
| **6** | Import & Restore - Restore from backups |
| **7** | Uninstall & Cleanup - Remove with forensic data collection |
| **8** | Update All - Update all distributions |
| **9** | GUI Environments - Install/configure desktop environments |
| **10** | Docker Integration - Container setup |
| **11** | Security Hardening - Enhance security |
| **12** | Resource Monitor - Real-time monitoring |
| **13** | Global Settings - Configure .wslconfig |
| **14** | Network Configuration - Ports, DNS, SSH |
| **15** | Storage Management - Disk and VHD management |
| **16** | View Logs - Operation history |

### Installing a GUI Desktop

1. Run `wsl-manager.bat` → Option **9** (GUI Environments)
2. Enter the distribution name
3. Select your preferred desktop environment
4. Wait for installation (10-30 minutes)

#### Starting the GUI

**Method 1: WSLg (Windows 11)**
- GUI apps work automatically with WSLg
- No additional X server needed

**Method 2: X Server (Windows 10/11)**
1. Install [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or [GWSL](https://www.microsoft.com/store/apps/9NL6KD1H33V3)
2. Start the X server with these settings:
   - Multiple windows mode
   - Disable access control
3. Run `scripts\start-gui.bat`

### Backup and Restore

**Creating a Backup:**
```cmd
scripts\backup.bat
```
- Select Option 1 to backup single distribution
- Select Option 2 to backup all distributions
- Backups are stored in the `exports/` folder

**Restoring from Backup:**
```cmd
scripts\backup.bat
```
- Select Option 3 to import from backup
- Provide the backup filename and new distribution name

### Development Presets

Pre-configured development environments:

```cmd
scripts\dev-setup.bat
```

**Available Presets:**
1. **Full Stack Web**: Node.js, npm, Python, Docker, PostgreSQL, Redis
2. **Python/Data Science**: Python, pip, Jupyter, NumPy, Pandas, Matplotlib
3. **DevOps/SRE**: Docker, kubectl, Helm, Terraform, Ansible, AWS/Azure CLIs
4. **System Programming**: GCC, G++, CMake, Rust, Go, GDB
5. **Java Enterprise**: OpenJDK 17, Maven, Gradle

## ⚙️ Configuration

### Global WSL Settings (.wslconfig)

Edit global settings using:
```cmd
scripts\config.bat
```

Or manually edit `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=4GB
processors=2
swap=4GB
localhostForwarding=true

[experimental]
sparseVhd=true
autoMemoryReclaim=gradual
```

**Apply changes:**
```cmd
wsl --shutdown
```

### Per-Distribution Settings

Create `/etc/wsl.conf` inside the distribution:

```ini
[boot]
systemd=true

[automount]
enabled=true
root=/mnt/
options="metadata,umask=22,fmask=11"

[network]
hostname=my-wsl
generateResolvConf=true

[interop]
enabled=true
appendWindowsPath=true
```

## 🔒 Security

### Security Hardening

Run the security setup:
```cmd
scripts\security.bat
```

**Features:**
- UFW Firewall configuration
- SSH hardening (disable root, limit attempts)
- Fail2Ban for intrusion prevention
- Automatic security updates
- Security audit tools

### Best Practices

1. **Keep Updated**: Regularly run `scripts\update.bat`
2. **Use Backups**: Schedule regular exports
3. **Limit Resources**: Configure memory/CPU limits in .wslconfig
4. **Firewall**: Enable UFW inside WSL
5. **SSH Keys**: Use key-based authentication

## 🔍 Forensic Data Collection

### Automatic Forensics Before Destruction

When you uninstall a WSL distribution using the destructor, comprehensive forensic data is automatically collected and saved to `forensics/` before deletion.

### Data Collected

| Category | Information |
|----------|-------------|
| **Host System** | Computer name, Windows version, system specs, user info |
| **WSL Environment** | WSL version, all distributions, status |
| **Users** | /etc/passwd, /etc/group, sudo users, login history |
| **Shell History** | Bash and Zsh history for root and regular users |
| **Packages** | APT, RPM, Snap, Pip, NPM packages |
| **Network** | Interfaces, routes, DNS, hosts, open ports, connections |
| **Filesystem** | Disk usage, mounts, recent files |
| **Security** | SSH config, authorized keys, firewall, SUID files |
| **Docker** | Containers, images |
| **Services** | Enabled and running systemd services |
| **Logs** | Auth logs (last 100 lines), syslog (last 50 lines) |

### Report Location

Reports are saved with timestamps:
```
forensics/{distro_name}_forensic_{YYYYMMDD_HHMMSS}.txt
```

### Usage

```cmd
scripts\destructor.bat
```

Or from main menu: `wsl-manager.bat` → Option **7**

## 🐳 Docker Integration

### Install Docker in WSL

```cmd
scripts\docker-setup.bat
```

Select Option 1 to install Docker Engine directly in WSL.

### Docker Desktop Integration

For Docker Desktop users:
1. Install Docker Desktop for Windows
2. Enable WSL 2 backend in Docker Desktop settings
3. Enable integration for your WSL distributions

## 🌐 Network Configuration

### Port Forwarding

Forward ports from Windows to WSL:
```cmd
scripts\network.bat
```

**Manual port forwarding:**
```cmd
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=<WSL-IP>
```

### SSH Access

Configure SSH server:
```cmd
scripts\network.bat
```

Select Option 3 to set up SSH access to your WSL instance.

## 💾 Storage Management

### Compact VHD Files

WSL VHD files grow but don't automatically shrink:

```cmd
scripts\storage.bat
```

Select Option 2 to compact VHD files and reclaim disk space.

### Move Distribution

Relocate a distribution to a different drive:
```cmd
scripts\storage.bat
```

Select Option 3 to move a distribution.

## 🔧 Troubleshooting

### WSL Won't Start
```cmd
wsl --shutdown
wsl --update
```

### Network Issues
```cmd
wsl --shutdown
netsh winsock reset
netsh int ip reset
```

### GUI Not Displaying
1. Check X server is running
2. Verify DISPLAY variable: `echo $DISPLAY`
3. Test with: `xeyes` or `xclock`

### Reset Distribution
```cmd
wsl --unregister <distro>
wsl --install <distro>
```

## 📋 System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Windows | 10 v2004+ | 11 |
| RAM | 4 GB | 8+ GB |
| Storage | 10 GB | 50+ GB |
| Processor | 64-bit | Multi-core |

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details.

## 🙏 Acknowledgments

- Microsoft WSL Team
- VcXsrv developers
- Linux community

---

**Made with ❤️ for the WSL community**

# Podmania - WSL2/Ubuntu Deployment Guide

A Podman-based RHEL 9 server farm environment for infrastructure testing on Windows WSL2 with Ubuntu.

## Overview

This guide covers deploying Podmania on Ubuntu running under Windows WSL2. Unlike macOS which requires a Podman VM, WSL2 runs Podman natively with better performance and simpler setup.

### Key Advantages on WSL2/Ubuntu

- **Native Performance**: No VM overhead - containers run directly on WSL2's Linux kernel
- **Simpler Setup**: No Podman machine initialization required
- **Direct Integration**: Seamless integration with Windows filesystem and tools
- **Lower Resource Usage**: More efficient than running through a VM layer

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Windows 11/10 with WSL2                                 │
│                                                         │
│  ┌────────────────────────────────────────────────┐   │
│  │  Ubuntu WSL2 Instance                          │   │
│  │                                                │   │
│  │  ┌────────────────────────────────────┐       │   │
│  │  │  jumpnet (172.25.0.0/16)           │       │   │
│  │  │                                    │       │   │
│  │  │  jump-server    (172.25.0.10)      │       │   │
│  │  │  target-server-1 (172.25.0.11)     │       │   │
│  │  │  target-server-2 (172.25.0.12)     │       │   │
│  │  │  target-server-3 (172.25.0.13)     │       │   │
│  │  │  target-server-4 (172.25.0.14)     │       │   │
│  │  │                                    │       │   │
│  │  └────────────────────────────────────┘       │   │
│  │                                                │   │
│  │  Accessible via:                               │   │
│  │  - localhost:2222-2226 (from Windows)          │   │
│  │  - 172.25.0.x (from within WSL2)               │   │
│  └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

### 1. Enable WSL2 on Windows

If you haven't already set up WSL2:

**Open PowerShell as Administrator:**

```powershell
# Enable WSL
wsl --install

# Or if already installed, ensure WSL2 is default
wsl --set-default-version 2

# Install Ubuntu (if not already installed)
wsl --install -d Ubuntu-22.04
```

**Verify WSL2 is running:**

```powershell
wsl --list --verbose
```

You should see Ubuntu with version 2.

### 2. Update Ubuntu

Open your Ubuntu WSL2 terminal and update the system:

```bash
sudo apt update && sudo apt upgrade -y
```

## Installation Methods

### Method 1: Automated Setup Script (Recommended)

The fastest way to get started:

```bash
# Download and run the automated setup script
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/podmania/main/setup-wsl2.sh | bash

# Or clone the repo first
git clone https://github.com/YOUR_USERNAME/podmania.git
cd podmania
chmod +x setup-wsl2.sh
./setup-wsl2.sh
```

The script will:
- Install Podman and podman-compose
- Configure Podman for rootless operation
- Build the RHEL 9 images
- Start all 5 servers
- Display connection information

### Method 2: Manual Installation

#### Step 1: Install Podman

```bash
# Add Podman repository
sudo apt update
sudo apt install -y curl wget ca-certificates gnupg lsb-release

# Install Podman
sudo apt install -y podman

# Verify installation
podman --version
```

#### Step 2: Install podman-compose

```bash
# Install pip if not already installed
sudo apt install -y python3-pip

# Install podman-compose
pip3 install podman-compose

# Verify installation
podman-compose --version
```

#### Step 3: Configure Podman for Rootless Mode (Recommended)

```bash
# Enable user namespaces
echo "kernel.unprivileged_userns_clone=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure subuid and subgid for your user
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER

# Enable lingering (keeps user services running)
loginctl enable-linger $USER

# Reboot WSL2 to apply changes
exit
# In PowerShell: wsl --shutdown
# Then reopen Ubuntu
```

#### Step 4: Clone Repository and Build

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/podmania.git
cd podmania

# Build and start the environment
podman-compose build
podman-compose up -d

# Verify containers are running
podman-compose ps
```

## Alternative: Using Docker Instead of Podman

WSL2 also supports Docker Desktop. If you prefer Docker:

```bash
# Install Docker Engine
sudo apt update
sudo apt install -y docker.io

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Start Docker service
sudo service docker start

# Use docker-compose instead of podman-compose
docker-compose build
docker-compose up -d
```

## Quick Start

### 1. Start the Environment

```bash
cd podmania

# Start all 5 servers
podman-compose up -d

# Check status
podman-compose ps
```

### 2. SSH Access

**From Windows (PowerShell, cmd, or Windows Terminal):**

```powershell
# Jump server
ssh -p 2222 jay@localhost

# Target servers
ssh -p 2223 jay@localhost  # target-server-1
ssh -p 2224 jay@localhost  # target-server-2
ssh -p 2225 jay@localhost  # target-server-3
ssh -p 2226 jay@localhost  # target-server-4

# Default password: password
```

**From WSL2 Ubuntu terminal:**

```bash
# Jump server
ssh -p 2222 jay@localhost

# Or use the container network directly
ssh jay@172.25.0.10  # jump-server
ssh jay@172.25.0.11  # target-server-1
```

### 3. Set Up SSH Key-Based Authentication

**Option A: From Windows**

```powershell
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096

# Copy to containers
ssh-copy-id -p 2222 jay@localhost  # jump-server
ssh-copy-id -p 2223 jay@localhost  # target-server-1
ssh-copy-id -p 2224 jay@localhost  # target-server-2
ssh-copy-id -p 2225 jay@localhost  # target-server-3
ssh-copy-id -p 2226 jay@localhost  # target-server-4
```

**Option B: From WSL2**

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096

# Copy to all containers
for port in {2222..2226}; do
  ssh-copy-id -p $port jay@localhost
done
```

## Management Commands

All standard podman-compose commands work:

```bash
# Stop all servers
podman-compose down

# Start all servers
podman-compose up -d

# Restart all servers
podman-compose restart

# View logs
podman-compose logs -f jump-server

# Rebuild images
podman-compose build --no-cache

# Execute command in container
podman exec -it jump-server bash

# Check network
podman network inspect jumpnet
```

## WSL2-Specific Considerations

### Accessing Containers from Windows

Containers are accessible from Windows on `localhost` using the mapped ports:
- Jump Server: `localhost:2222`
- Target Server 1: `localhost:2223`
- Target Server 2: `localhost:2224`
- Target Server 3: `localhost:2225`
- Target Server 4: `localhost:2226`

### File Sharing Between Windows and WSL2

Your Windows drives are mounted under `/mnt/`:
- `C:\` → `/mnt/c/`
- `D:\` → `/mnt/d/`

To share files with containers, you can mount Windows directories:

```yaml
# In docker-compose.yml
volumes:
  - /mnt/c/Users/YourName/projects:/home/jay/projects
```

### Resource Limits

WSL2 resource usage is controlled by `.wslconfig` in your Windows user directory:

**C:\Users\YourName\.wslconfig:**

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

After creating/editing this file, restart WSL2:

```powershell
wsl --shutdown
```

### Systemd Support

Modern WSL2 supports systemd. Enable it if not already enabled:

**/etc/wsl.conf** (inside WSL2):

```ini
[boot]
systemd=true
```

Restart WSL2 after making this change.

## Troubleshooting

### Containers won't start

```bash
# Check Podman service status
systemctl --user status podman.socket

# Check logs
podman-compose logs

# Verify network configuration
podman network ls
podman network inspect jumpnet

# Restart WSL2 if needed (from PowerShell)
wsl --shutdown
```

### SSH connection refused

```bash
# Check if SSH is running in container
podman exec jump-server systemctl status sshd

# Check port mappings
podman port jump-server

# Verify firewall isn't blocking (from Windows PowerShell as Admin)
New-NetFirewallRule -DisplayName "Podman SSH" -Direction Inbound -LocalPort 2222-2226 -Protocol TCP -Action Allow
```

### Permission denied errors

```bash
# Reset Podman
podman system reset

# Reconfigure subuid/subgid
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER

# Restart WSL2
exit
# In PowerShell: wsl --shutdown
```

### Network connectivity issues

```bash
# Recreate network
podman network rm jumpnet
podman network create jumpnet --subnet 172.25.0.0/16

# Or rebuild everything
podman-compose down
podman-compose up -d
```

### Out of space

```bash
# Check disk usage
df -h

# Clean up Podman
podman system prune -a -f

# Check WSL2 disk usage (from Windows PowerShell)
wsl --list --verbose
```

To reclaim space in the WSL2 virtual disk:

```powershell
# In PowerShell
wsl --shutdown
diskpart
# In diskpart:
select vdisk file="C:\Users\YourName\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04onWindows_...\LocalState\ext4.vhdx"
compact vdisk
exit
```

## Performance Tips

### 1. Store Project Files in WSL2

For better performance, keep your project in the WSL2 filesystem (`~/podmania`) rather than in Windows filesystem (`/mnt/c/...`).

```bash
# Good (fast)
cd ~/podmania

# Slower
cd /mnt/c/Users/YourName/podmania
```

### 2. Use Rootless Podman

Rootless Podman is more secure and performs better on WSL2:

```bash
# Run as regular user (not sudo)
podman-compose up -d
```

### 3. Disable Docker Desktop if Using Podman

To avoid conflicts and reduce resource usage:
- Uninstall Docker Desktop, or
- Disable Docker Desktop auto-start in settings

## Advanced Configuration

### Using Windows SSH Client

Add to your Windows SSH config (`C:\Users\YourName\.ssh\config`):

```
Host jump
    HostName localhost
    Port 2222
    User jay

Host target1
    HostName localhost
    Port 2223
    User jay

Host target2
    HostName localhost
    Port 2224
    User jay

Host target3
    HostName localhost
    Port 2225
    User jay

Host target4
    HostName localhost
    Port 2226
    User jay
```

Now you can: `ssh jump` or `ssh target1` from Windows.

### VS Code Integration

Install "Remote - SSH" extension in VS Code and connect to containers:

```json
// In VS Code Remote SSH settings
{
  "remote.SSH.configFile": "C:\\Users\\YourName\\.ssh\\config"
}
```

Then: `Ctrl+Shift+P` → "Remote-SSH: Connect to Host" → Select `jump` or `target1`

## Next Steps

- Review the main [README.md](README.md) for general usage, automation examples, and use cases
- Check out the example readme files for specific tasks
- Set up Ansible inventory for managing all servers
- Install additional tools and packages in the containers

## Contributing

Found WSL2-specific issues or improvements? Open an issue or submit a pull request!

## Additional Resources

- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Podman Documentation](https://docs.podman.io/)
- [Docker on WSL2](https://docs.docker.com/desktop/wsl/)

# Podmania WSL2 - Quick Start Guide

Get your RHEL 9 server farm running in minutes on WSL2/Ubuntu!

## TL;DR - Super Quick Start

```bash
# Clone the repository
git clone <your-repo-url> ~/podmania
cd ~/podmania

# Run automated setup (installs everything)
./setup-wsl2.sh

# Start using!
ssh -p 2222 jay@localhost
# Password: password
```

## Prerequisites Check

**Do you have WSL2 with Ubuntu?**

```powershell
# Run in PowerShell
wsl --list --verbose
```

You should see Ubuntu with VERSION 2.

**Don't have WSL2 yet?**

```powershell
# Run in PowerShell as Administrator
wsl --install -d Ubuntu-22.04
```

## Installation Options

### Option 1: One-Command Install (Easiest)

```bash
# From your WSL2 Ubuntu terminal
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/podmania/main/setup-wsl2.sh | bash
```

This will:
- ✓ Install Podman
- ✓ Install podman-compose
- ✓ Configure rootless mode
- ✓ Build RHEL 9 images
- ✓ Start all 5 servers
- ✓ Test connectivity

### Option 2: Manual Install (5 Minutes)

```bash
# 1. Install Podman
sudo apt update
sudo apt install -y podman python3-pip
pip3 install podman-compose

# 2. Clone and setup
git clone <your-repo-url> ~/podmania
cd ~/podmania

# 3. Build and start
podman-compose build
podman-compose up -d

# 4. Verify
podman-compose ps
```

## First Connection

### From Windows

Open PowerShell, cmd, or Windows Terminal:

```powershell
# Connect to jump server
ssh -p 2222 jay@localhost
# Password: password

# Or connect to target servers
ssh -p 2223 jay@localhost  # target-server-1
ssh -p 2224 jay@localhost  # target-server-2
```

### From WSL2 Ubuntu

```bash
# Using localhost ports
ssh -p 2222 jay@localhost

# Or using container IPs directly
ssh jay@172.25.0.10  # jump-server
ssh jay@172.25.0.11  # target-server-1
```

## Set Up SSH Keys (Recommended)

Skip typing passwords every time:

```bash
# Generate key if you don't have one
ssh-keygen -t rsa -b 4096

# Copy to all servers
for port in {2222..2226}; do
  ssh-copy-id -p $port jay@localhost
done

# Now SSH without passwords!
ssh -p 2222 jay@localhost
```

## Essential Commands

### Start/Stop/Restart

```bash
# Start all servers
podman-compose up -d

# Stop all servers
podman-compose down

# Restart all servers
podman-compose restart

# Restart single server
podman-compose restart jump-server
```

### View Status and Logs

```bash
# Check what's running
podman-compose ps

# View all logs (live)
podman-compose logs -f

# View logs for one server
podman-compose logs -f jump-server

# View last 50 lines
podman-compose logs --tail=50 target-server-1
```

### Execute Commands

```bash
# Get a shell in jump-server
podman exec -it jump-server bash

# Run a command in target-server-1
podman exec target-server-1 whoami

# Check SSH status
podman exec jump-server systemctl status sshd
```

### Rebuild After Changes

```bash
# Rebuild all images
podman-compose build --no-cache

# Rebuild and restart
podman-compose down
podman-compose build --no-cache
podman-compose up -d
```

## All Server Ports

| Server | SSH Port | IP Address |
|--------|----------|------------|
| Jump Server | 2222 | 172.25.0.10 |
| Target Server 1 | 2223 | 172.25.0.11 |
| Target Server 2 | 2224 | 172.25.0.12 |
| Target Server 3 | 2225 | 172.25.0.13 |
| Target Server 4 | 2226 | 172.25.0.14 |

## Common Tasks

### Jump Server Workflow

```bash
# 1. SSH to jump server from Windows/WSL2
ssh -p 2222 jay@localhost

# 2. From jump server, SSH to targets (no port needed!)
ssh jay@target-server-1
ssh jay@target-server-2

# Or by IP
ssh jay@172.25.0.11
```

### Install Software in Containers

```bash
# SSH into any server
ssh -p 2223 jay@localhost

# Install packages
sudo dnf install -y python3 git htop

# Create Python venv
python3 -m venv ~/myapp
source ~/myapp/bin/activate
pip install flask requests
```

### Copy Files to Containers

**From Windows:**

```powershell
# Copy file to jump server
scp -P 2222 myfile.txt jay@localhost:/home/jay/

# Copy directory
scp -P 2222 -r myproject jay@localhost:/home/jay/
```

**From WSL2:**

```bash
# Same as above, or use volume mounts in docker-compose.yml
scp -P 2222 myfile.txt jay@localhost:/home/jay/
```

### Configure Ansible

Create `inventory.ini`:

```ini
[jump_server]
jump ansible_host=localhost ansible_port=2222 ansible_user=jay

[target_servers]
target1 ansible_host=localhost ansible_port=2223 ansible_user=jay
target2 ansible_host=localhost ansible_port=2224 ansible_user=jay
target3 ansible_host=localhost ansible_port=2225 ansible_user=jay
target4 ansible_host=localhost ansible_port=2226 ansible_user=jay
```

Test it:

```bash
ansible all -i inventory.ini -m ping
```

## Troubleshooting

### Can't connect via SSH

```bash
# Check containers are running
podman-compose ps

# Check SSH service in container
podman exec jump-server systemctl status sshd

# Restart SSH if needed
podman exec jump-server systemctl restart sshd

# Check port is listening
sudo netstat -tlnp | grep 2222
```

### Containers won't start

```bash
# View error logs
podman-compose logs

# Restart WSL2 (from Windows PowerShell)
wsl --shutdown
# Then reopen Ubuntu terminal

# Or reset everything
podman-compose down
podman system prune -a -f
podman-compose up -d
```

### Out of space

```bash
# Check disk usage
df -h

# Clean up Podman
podman system prune -a -f

# Clean up old images
podman image prune -a -f
```

### Slow performance

**Are your files on /mnt/c/?**

Move them to WSL2 filesystem for better performance:

```bash
# Instead of: /mnt/c/Users/YourName/podmania
# Use:        ~/podmania

# Move your project
cd ~
git clone <repo> podmania
cd podmania
```

### WSL2 using too much RAM

Create/edit `C:\Users\YourName\.wslconfig`:

```ini
[wsl2]
memory=4GB
processors=2
```

Then restart WSL2:

```powershell
wsl --shutdown
```

## What's Next?

### Explore the Documentation

- **README-WSL2.md** - Complete WSL2 deployment guide with advanced topics
- **README.md** - General usage, automation, and use cases
- **readme_*.txt** - Specific task examples

### Try These Use Cases

1. **Test Ansible Playbooks**
   ```bash
   ansible-playbook -i inventory.ini your-playbook.yml
   ```

2. **Vulnerability Scanning**
   ```bash
   # Install OpenSCAP and scan servers
   ```

3. **Python Deployment Testing**
   ```bash
   # Deploy Flask/Django apps across servers
   ```

4. **Infrastructure as Code**
   ```bash
   # Test Terraform or other IaC tools
   ```

### Customize Your Environment

Edit `docker-compose.yml` to:
- Add more servers
- Change IP addresses
- Mount additional volumes
- Expose more ports

## Pro Tips

1. **Use SSH config** for easier connections:
   ```bash
   # Add to ~/.ssh/config
   Host jump
       HostName localhost
       Port 2222
       User jay

   # Then just: ssh jump
   ```

2. **Keep terminal open** when developing:
   ```bash
   # Follow logs in one terminal
   podman-compose logs -f

   # Work in another terminal
   ssh -p 2222 jay@localhost
   ```

3. **Snapshot your setup**:
   ```bash
   # After customizing, commit your containers as images
   podman commit jump-server my-custom-jump-server
   ```

4. **Access from VS Code**:
   - Install "Remote - SSH" extension
   - Connect to localhost:2222
   - Code directly in containers!

## Getting Help

- Check **README-WSL2.md** for detailed troubleshooting
- Review Podman logs: `podman-compose logs`
- Check systemd: `podman exec jump-server systemctl status sshd`
- Verify network: `podman network inspect jumpnet`

## Quick Reference Card

```bash
# Daily Commands
podman-compose up -d      # Start
podman-compose down       # Stop
podman-compose ps         # Status
podman-compose logs -f    # Logs

# SSH Access
ssh -p 2222 jay@localhost  # Jump server
ssh -p 2223 jay@localhost  # Target 1

# Management
podman exec -it jump-server bash  # Shell access
podman-compose restart            # Restart all
podman system prune -a -f         # Clean up

# WSL2 Control (PowerShell)
wsl --shutdown            # Restart WSL2
wsl --list --verbose      # Check status
```

---

**Ready to go?** Run `./setup-wsl2.sh` and you'll be up and running in minutes!

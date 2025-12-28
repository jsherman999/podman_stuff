# Podmania

A Podman-based RHEL 9 server farm environment for infrastructure testing, patch management validation, entitlement review, vulnerability scanning, and other enterprise Linux testing workflows.

## Platform Support

- **macOS**: Uses Podman Machine (VM-based) - see instructions below
- **Windows WSL2/Ubuntu**: Native Podman support - see [README-WSL2.md](README-WSL2.md) and [QUICKSTART-WSL2.md](QUICKSTART-WSL2.md)
- **Linux**: Native Podman support (same instructions as WSL2)

> **Running on Windows WSL2?** Check out the [WSL2 Quick Start Guide](QUICKSTART-WSL2.md) for automated setup!

## Overview

Podmania creates a lightweight, reproducible RHEL 9 server farm using Podman containers orchestrated by `podman-compose`. It provides a jump server architecture with multiple target servers, all running in an isolated network environment - perfect for testing automation scripts, deployment procedures, security scans, and infrastructure changes before production deployment.

### Key Features

- **5 RHEL 9 Servers**: One jump server + four target servers, all fully functional RHEL 9 environments
- **Isolated Network**: Private bridge network (172.25.0.0/16) with static IP assignments
- **SSH-Enabled**: All servers accessible via SSH with key-based or password authentication
- **Full Package Management**: Real RHEL 9 userspace with DNF, systemd, and access to UBI repositories
- **Python-Ready**: Supports venv environments and pip package installation
- **Persistent or Ephemeral**: Optionally mount volumes for persistent storage across container lifecycles
- **Multi-Platform**: Works on macOS, Windows WSL2, and Linux

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Your Mac (Control Node)                                 │
│ SSH Keys → All Containers                               │
└──────────────┬──────────────────────────────────────────┘
               │
    ┌──────────┴─────────────────────────────┐
    │    Podman VM (Apple Hypervisor)        │
    │                                        │
    │  ┌────────────────────────────────┐   │
    │  │  jumpnet (172.25.0.0/16)       │   │
    │  │                                │   │
    │  │  jump-server    (172.25.0.10)  │   │  Port 2222
    │  │  target-server-1 (172.25.0.11) │   │  Port 2223
    │  │  target-server-2 (172.25.0.12) │   │  Port 2224
    │  │  target-server-3 (172.25.0.13) │   │  Port 2225
    │  │  target-server-4 (172.25.0.14) │   │  Port 2226
    │  │                                │   │
    │  └────────────────────────────────┘   │
    └────────────────────────────────────────┘
```

## Use Cases

- **Patch Testing**: Push and test patches across multiple RHEL servers before production deployment
- **Entitlement Review**: Validate RHEL subscription and entitlement configurations
- **Vulnerability Scanning**: Test security scanning tools (OpenSCAP, Nessus, etc.) against RHEL targets
- **Ansible/Automation Testing**: Validate playbooks and automation scripts in a safe environment
- **Jump Server Workflows**: Practice and test jump server/bastion host patterns
- **Python Deployment**: Test Python applications, venv setups, and pip dependencies
- **Infrastructure as Code**: Test Terraform, Ansible, SaltStack, or other IaC tools
- **Security Hardening**: Validate CIS benchmarks, STIG configurations, or custom security policies

## Prerequisites

> **Note**: These instructions are for **macOS**. If you're on **Windows WSL2/Ubuntu** or **Linux**, see [README-WSL2.md](README-WSL2.md) for platform-specific instructions and automated setup.

### Install Podman

**macOS (using Homebrew):**
```bash
brew install podman
```

**Windows WSL2/Ubuntu/Linux:**
See [README-WSL2.md](README-WSL2.md) or run the automated setup:
```bash
./setup-wsl2.sh
```

### Install podman-compose

**Using pip:**
```bash
pip3 install podman-compose
```

**Using Homebrew:**
```bash
brew install podman-compose
```

### Initialize Podman Machine

First-time setup on macOS:

```bash
# Initialize the Podman machine (creates the VM)
podman machine init

# Start the Podman machine
podman machine start

# Verify it's running
podman machine list
```

#### Optional: Customize VM Resources

```bash
# Remove default machine
podman machine stop
podman machine rm

# Create with custom resources (4 CPUs, 8GB RAM, 50GB disk)
podman machine init --cpus 4 --memory 8192 --disk-size 50

# Start it
podman machine start
```

## Quick Start

### 1. Build the Environment

```bash
# Build the RHEL 9 image
podman-compose build

# Start all 5 servers in detached mode
podman-compose up -d

# Check they're running
podman-compose ps
```

### 2. SSH Access

**From your Mac (using password authentication):**
```bash
# Jump server
ssh -p 2222 jay@localhost

# Target servers
ssh -p 2223 jay@localhost  # target-server-1
ssh -p 2224 jay@localhost  # target-server-2
ssh -p 2225 jay@localhost  # target-server-3
ssh -p 2226 jay@localhost  # target-server-4

# Default password: password
```

**From jump-server to target servers:**
```bash
# SSH into jump-server first
ssh -p 2222 jay@localhost

# Then SSH to target servers by hostname or IP
ssh jay@target-server-1    # or ssh jay@172.25.0.11
ssh jay@target-server-2    # or ssh jay@172.25.0.12
ssh jay@target-server-3    # or ssh jay@172.25.0.13
ssh jay@target-server-4    # or ssh jay@172.25.0.14
```

### 3. Set Up SSH Key-Based Authentication

**Option A: From your Mac to all containers**

```bash
# Copy your Mac's public key to each server
ssh-copy-id -p 2222 jay@localhost  # jump-server
ssh-copy-id -p 2223 jay@localhost  # target-server-1
ssh-copy-id -p 2224 jay@localhost  # target-server-2
ssh-copy-id -p 2225 jay@localhost  # target-server-3
ssh-copy-id -p 2226 jay@localhost  # target-server-4

# Now SSH without passwords
ssh -p 2223 jay@localhost
```

**Option B: From jump-server to target servers**

```bash
# SSH into jump-server
ssh -p 2222 jay@localhost

# Generate SSH key (accept defaults)
ssh-keygen -t rsa -b 4096

# Copy to all target servers
for i in {1..4}; do
  ssh-copy-id jay@target-server-$i
done
```

## Management Commands

### Container Lifecycle

```bash
# Stop all servers
podman-compose down

# Start all servers
podman-compose up -d

# Restart all servers
podman-compose restart

# View logs (follow mode)
podman-compose logs -f jump-server
podman-compose logs -f target-server-1

# View logs for all containers
podman-compose logs -f
```

### Rebuild and Maintenance

```bash
# Rebuild after Dockerfile changes (no cache)
podman-compose build --no-cache

# Pull latest RHEL 9 base image
podman pull registry.access.redhat.com/ubi9/ubi-init

# Execute command in a running container
podman exec -it jump-server bash
podman exec -it target-server-1 bash

# Check container status
podman ps
podman-compose ps
```

### Network Inspection

```bash
# Inspect the jumpnet network
podman network inspect jumpnet

# View network connectivity
podman exec jump-server ping target-server-1
```

### Podman Machine Management

```bash
# Check Podman VM status
podman machine list

# SSH into the Podman VM (for troubleshooting)
podman machine ssh

# Stop the Podman machine when done
podman machine stop

# Start the Podman machine
podman machine start
```

## Installing Software in Containers

All containers are fully functional RHEL 9 environments. You can install packages, create Python virtual environments, and treat them like real RHEL servers.

### Install Packages with DNF

```bash
# SSH into any server
ssh -p 2223 jay@localhost

# Install packages
sudo dnf install -y python3 python3-pip python3-devel git gcc make

# Install EPEL for additional packages
sudo dnf install -y epel-release
sudo dnf install -y htop ansible

# Install database clients
sudo dnf install -y postgresql redis
```

### Python Virtual Environments

```bash
# SSH into a target server
ssh -p 2223 jay@localhost

# Install Python development tools
sudo dnf install -y python3 python3-pip python3-devel

# Create a virtual environment
python3 -m venv ~/myproject

# Activate the venv
source ~/myproject/bin/activate

# Install Python packages
pip install requests flask ansible boto3 pytest

# Deactivate when done
deactivate
```

## Configuration Files

### Dockerfile.rhel9-server

Defines the RHEL 9 server image with SSH enabled:
- Base image: `registry.access.redhat.com/ubi9/ubi-init`
- Installs: openssh-server, sudo, vim, networking tools
- Creates user `jay` with sudo privileges
- Enables systemd and SSH service

### docker-compose.yml

Orchestrates 5 RHEL 9 containers:
- **jump-server**: 172.25.0.10 (port 2222)
- **target-server-1**: 172.25.0.11 (port 2223)
- **target-server-2**: 172.25.0.12 (port 2224)
- **target-server-3**: 172.25.0.13 (port 2225)
- **target-server-4**: 172.25.0.14 (port 2226)

All containers run in privileged mode on the `jumpnet` bridge network.

## Adding Persistent Storage

To preserve data across container rebuilds, add volume mounts to `docker-compose.yml`:

```yaml
target-server-1:
  build:
    context: .
    dockerfile: Dockerfile.rhel9-server
  container_name: target-server-1
  hostname: target-server-1
  ports:
    - "2223:22"
  volumes:
    - ./projects/server1:/home/jay/projects  # Persistent storage
  networks:
    jumpnet:
      ipv4_address: 172.25.0.11
  privileged: true
  restart: unless-stopped
```

## Automation Examples

### Ansible Inventory

Create an inventory file to manage all servers with Ansible:

```ini
# inventory.ini
[jump_server]
jump ansible_host=localhost ansible_port=2222 ansible_user=jay

[target_servers]
server1 ansible_host=localhost ansible_port=2223 ansible_user=jay
server2 ansible_host=localhost ansible_port=2224 ansible_user=jay
server3 ansible_host=localhost ansible_port=2225 ansible_user=jay
server4 ansible_host=localhost ansible_port=2226 ansible_user=jay

[rhel_servers:children]
jump_server
target_servers
```

**Test connectivity:**
```bash
ansible all -i inventory.ini -m ping
```

**Run playbooks:**
```bash
ansible-playbook -i inventory.ini setup_python_env.yml
ansible-playbook -i inventory.ini patch_servers.yml
```

### SSH Config

Add to `~/.ssh/config` for easier access:

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

Now you can simply: `ssh jump` or `ssh target1`

## Limitations

While these containers provide nearly complete RHEL 9 functionality, there are some limitations:

- **No Kernel Modules**: Containers share the host kernel, so you can't load kernel modules or modify kernel parameters in the same way as a VM
- **Systemd Constraints**: Some systemd features may have limitations in containerized environments (though `ubi-init` handles most common use cases)
- **Performance Overhead**: Running through the Podman VM on macOS adds some performance overhead compared to native Linux
- **No SELinux Enforcement**: SELinux is typically disabled or in permissive mode in containers

## Troubleshooting

### Container won't start

```bash
# Check logs for errors
podman-compose logs jump-server

# Verify Podman machine is running
podman machine list

# Restart Podman machine if needed
podman machine stop
podman machine start
```

### SSH connection refused

```bash
# Check if SSHD is running in the container
podman exec jump-server systemctl status sshd

# Start SSHD if needed
podman exec jump-server systemctl start sshd

# Check port mappings
podman port jump-server
```

### Network connectivity issues

```bash
# Inspect network configuration
podman network inspect jumpnet

# Test connectivity between containers
podman exec jump-server ping target-server-1

# Restart containers if needed
podman-compose restart
```

### Out of disk space

```bash
# Check Podman machine disk usage
podman machine ssh
df -h

# Clean up unused images and containers
podman system prune -a

# Or increase VM disk size (requires recreation)
podman machine rm
podman machine init --disk-size 100
```

## Contributing

This is a personal testing environment, but suggestions and improvements are welcome! Feel free to open issues or submit pull requests.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Built on Red Hat Universal Base Image (UBI) 9
- Powered by Podman and podman-compose
- Designed for infrastructure testing and learning

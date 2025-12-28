#!/bin/bash

# Podmania WSL2/Ubuntu Automated Setup Script
# This script automates the installation and setup of Podmania on Ubuntu WSL2

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if running on WSL2
check_wsl2() {
    print_header "Checking WSL2 Environment"

    if ! grep -q microsoft /proc/version; then
        print_error "This script is designed for WSL2/Ubuntu"
        print_info "Detected environment: $(uname -a)"
        exit 1
    fi

    print_success "Running on WSL2"

    # Check for systemd support
    if ! command -v systemctl &> /dev/null; then
        print_warning "Systemd not detected. Some features may not work."
        print_info "Consider enabling systemd in /etc/wsl.conf"
    else
        print_success "Systemd is available"
    fi
}

# Update system
update_system() {
    print_header "Updating System Packages"

    sudo apt update
    sudo apt upgrade -y

    print_success "System updated"
}

# Install Podman
install_podman() {
    print_header "Installing Podman"

    if command -v podman &> /dev/null; then
        print_warning "Podman is already installed ($(podman --version))"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    print_info "Installing required dependencies..."
    sudo apt install -y curl wget ca-certificates gnupg lsb-release

    print_info "Installing Podman..."
    sudo apt install -y podman

    # Verify installation
    if command -v podman &> /dev/null; then
        print_success "Podman installed successfully ($(podman --version))"
    else
        print_error "Podman installation failed"
        exit 1
    fi
}

# Install podman-compose
install_podman_compose() {
    print_header "Installing podman-compose"

    if command -v podman-compose &> /dev/null; then
        print_warning "podman-compose is already installed ($(podman-compose --version))"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    print_info "Installing Python3 and pip..."
    sudo apt install -y python3 python3-pip

    print_info "Installing podman-compose via pip..."
    pip3 install --user podman-compose

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
        print_info "Added ~/.local/bin to PATH in ~/.bashrc"
    fi

    # Verify installation
    if command -v podman-compose &> /dev/null; then
        print_success "podman-compose installed successfully ($(podman-compose --version))"
    else
        print_error "podman-compose installation failed"
        print_info "Try running: source ~/.bashrc"
        exit 1
    fi
}

# Configure Podman for rootless mode
configure_rootless() {
    print_header "Configuring Rootless Podman"

    print_info "Enabling unprivileged user namespaces..."
    if ! grep -q "kernel.unprivileged_userns_clone=1" /etc/sysctl.conf; then
        echo "kernel.unprivileged_userns_clone=1" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        print_success "User namespaces enabled"
    else
        print_success "User namespaces already enabled"
    fi

    print_info "Configuring subuid and subgid..."
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER 2>/dev/null || \
        print_warning "Subuid/subgid may already be configured"

    print_success "Rootless configuration complete"
    print_info "Note: You may need to restart WSL2 for all changes to take effect"
}

# Create necessary directories
create_directories() {
    print_header "Creating Project Directories"

    mkdir -p ~/podmania/{apps,data,logs,nginx,ssh-keys/{root,jay}}

    print_success "Directories created"
}

# Clone or update repository
setup_repository() {
    print_header "Setting Up Repository"

    if [ -d ~/podmania/.git ]; then
        print_info "Repository already exists, pulling latest changes..."
        cd ~/podmania
        git pull
        print_success "Repository updated"
    else
        print_info "Cloning repository..."
        if [ -d ~/podmania ] && [ "$(ls -A ~/podmania)" ]; then
            print_warning "~/podmania directory exists and is not empty"
            read -p "Do you want to remove it and clone fresh? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf ~/podmania
                git clone https://github.com/YOUR_USERNAME/podmania.git ~/podmania
                cd ~/podmania
                print_success "Repository cloned"
            else
                cd ~/podmania
                print_warning "Using existing directory"
            fi
        else
            # If we're running the script from the repo directory
            if [ -f "$(pwd)/setup-wsl2.sh" ]; then
                print_success "Already in repository directory"
                cd "$(pwd)"
            else
                print_error "Please clone the repository first or cd to the repository directory"
                exit 1
            fi
        fi
    fi
}

# Build containers
build_containers() {
    print_header "Building RHEL 9 Container Images"

    cd ~/podmania 2>/dev/null || cd "$(dirname "$0")"

    print_info "This may take several minutes..."

    if podman-compose build; then
        print_success "Container images built successfully"
    else
        print_error "Failed to build container images"
        exit 1
    fi
}

# Start containers
start_containers() {
    print_header "Starting Container Environment"

    cd ~/podmania 2>/dev/null || cd "$(dirname "$0")"

    print_info "Starting all 5 RHEL 9 servers..."

    if podman-compose up -d; then
        print_success "All containers started"
    else
        print_error "Failed to start containers"
        exit 1
    fi

    # Wait a bit for containers to initialize
    print_info "Waiting for services to initialize..."
    sleep 5
}

# Verify deployment
verify_deployment() {
    print_header "Verifying Deployment"

    print_info "Checking container status..."
    podman-compose ps

    echo
    print_info "Checking SSH ports..."

    local all_ports_open=true
    for port in 2222 2223 2224 2225 2226; do
        if timeout 2 bash -c "cat < /dev/null > /dev/tcp/localhost/$port" 2>/dev/null; then
            print_success "Port $port is accessible"
        else
            print_error "Port $port is not accessible"
            all_ports_open=false
        fi
    done

    echo
    if [ "$all_ports_open" = true ]; then
        print_success "All SSH ports are accessible"
    else
        print_warning "Some SSH ports are not accessible yet. Containers may still be initializing."
        print_info "Wait a few moments and try: ssh -p 2222 jay@localhost"
    fi
}

# Display connection information
show_connection_info() {
    print_header "Setup Complete!"

    cat << EOF

${GREEN}Your RHEL 9 server farm is ready!${NC}

${BLUE}SSH Connection Information:${NC}
  Jump Server:       ssh -p 2222 jay@localhost
  Target Server 1:   ssh -p 2223 jay@localhost
  Target Server 2:   ssh -p 2224 jay@localhost
  Target Server 3:   ssh -p 2225 jay@localhost
  Target Server 4:   ssh -p 2226 jay@localhost

  Default password:  ${YELLOW}password${NC}

${BLUE}From Windows (PowerShell/cmd):${NC}
  You can SSH to the servers using the same commands above!

${BLUE}Management Commands:${NC}
  Stop all:          podman-compose down
  Start all:         podman-compose up -d
  View logs:         podman-compose logs -f
  Restart:           podman-compose restart
  Rebuild:           podman-compose build --no-cache

${BLUE}Next Steps:${NC}
  1. SSH into the jump server: ssh -p 2222 jay@localhost
  2. Set up SSH keys: ssh-copy-id -p 2222 jay@localhost
  3. From jump server, SSH to targets: ssh jay@target-server-1
  4. Review README-WSL2.md for more information

${BLUE}Network Information:${NC}
  Network:           jumpnet (172.25.0.0/16)
  Jump Server IP:    172.25.0.10
  Target Server 1:   172.25.0.11
  Target Server 2:   172.25.0.12
  Target Server 3:   172.25.0.13
  Target Server 4:   172.25.0.14

${GREEN}Happy testing!${NC}

EOF
}

# Main installation flow
main() {
    clear

    cat << "EOF"
    ____            __                  _
   / __ \____  ____/ /___ ___  ____ _  (_)___ _
  / /_/ / __ \/ __  / __ `__ \/ __ `/ / / __ `/
 / ____/ /_/ / /_/ / / / / / / /_/ / / / /_/ /
/_/    \____/\__,_/_/ /_/ /_/\__,_/ /_/\__,_/

    WSL2/Ubuntu Automated Setup

EOF

    print_info "This script will install and configure Podmania on WSL2/Ubuntu"
    print_warning "You may be prompted for your sudo password during installation"
    echo
    read -p "Press Enter to continue or Ctrl+C to cancel..."

    # Run installation steps
    check_wsl2
    update_system
    install_podman
    install_podman_compose
    configure_rootless

    # Setup project
    if [ -f "$(dirname "$0")/docker-compose.yml" ]; then
        print_info "Running from repository directory"
        cd "$(dirname "$0")"
    else
        setup_repository
    fi

    create_directories
    build_containers
    start_containers
    verify_deployment
    show_connection_info

    print_header "Installation Notes"
    print_warning "If you encounter any issues:"
    echo "  1. Restart WSL2: Run 'wsl --shutdown' in PowerShell, then restart"
    echo "  2. Check logs: podman-compose logs -f"
    echo "  3. Review README-WSL2.md for troubleshooting"
    echo ""
    print_info "For best performance, keep your project files in WSL2 filesystem (~/podmania)"
    print_info "rather than Windows filesystem (/mnt/c/...)"
}

# Run main function
main "$@"

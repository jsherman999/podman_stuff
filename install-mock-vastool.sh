#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Mock Vastool Installation Script"
echo "================================================"
echo ""

# Containers to install
CONTAINERS=(
    "jump-server"
    "target-server-1"
    "target-server-2"
    "target-server-3"
    "target-server-4"
)

# Check if containers are running
echo "Checking container status..."
for container in "${CONTAINERS[@]}"; do
    if ! podman ps --format "{{.Names}}" | grep -q "^${container}$"; then
        echo -e "${RED}ERROR: Container ${container} is not running${NC}"
        echo "Please start containers with: podman-compose up -d"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} ${container} is running"
done
echo ""

# Install jq in containers if needed
echo "Installing jq in containers (if not present)..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman exec "$container" bash -c "command -v jq &> /dev/null || dnf install -y jq" &> /dev/null || true
done
echo -e "${GREEN}✓${NC} jq installation complete"
echo ""

# Create directory structure
echo "Creating directory structure in containers..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman exec "$container" mkdir -p /opt/quest/bin /opt/quest/etc
done
echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Copy vastool script
echo "Copying vastool script to containers..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman cp mock-vastool/vastool "${container}:/opt/quest/bin/vastool"
    podman exec "$container" chmod 755 /opt/quest/bin/vastool
done
echo -e "${GREEN}✓${NC} Vastool script copied"
echo ""

# Copy JSON data files
echo "Copying JSON data files to containers..."
DATA_FILES=(
    "domain.json"
    "users.json"
    "groups.json"
    "computers.json"
    "access-control.json"
)

for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    for datafile in "${DATA_FILES[@]}"; do
        podman cp "mock-vastool/data/${datafile}" "${container}:/opt/quest/etc/${datafile}"
        podman exec "$container" chmod 644 "/opt/quest/etc/${datafile}"
    done
done
echo -e "${GREEN}✓${NC} JSON data files copied"
echo ""

# Create symlink for PATH access
echo "Creating symlinks for easy access..."
for container in "${CONTAINERS[@]}"; do
    echo "  - ${container}"
    podman exec "$container" bash -c "ln -sf /opt/quest/bin/vastool /usr/local/bin/vastool" || true
done
echo -e "${GREEN}✓${NC} Symlinks created"
echo ""

# Verify installation
echo "Verifying installation..."
ALL_OK=true

for container in "${CONTAINERS[@]}"; do
    echo "  Testing ${container}:"

    # Test version
    if podman exec "$container" vastool -v &> /dev/null; then
        echo -e "    ${GREEN}✓${NC} vastool -v"
    else
        echo -e "    ${RED}✗${NC} vastool -v FAILED"
        ALL_OK=false
    fi

    # Test info domain
    DOMAIN=$(podman exec "$container" vastool info domain 2>/dev/null || echo "FAILED")
    if [[ "$DOMAIN" == "EXAMPLE.COM" ]]; then
        echo -e "    ${GREEN}✓${NC} vastool info domain"
    else
        echo -e "    ${RED}✗${NC} vastool info domain FAILED (got: $DOMAIN)"
        ALL_OK=false
    fi

    # Test status
    if podman exec "$container" vastool status &> /dev/null; then
        echo -e "    ${GREEN}✓${NC} vastool status"
    else
        echo -e "    ${RED}✗${NC} vastool status FAILED"
        ALL_OK=false
    fi

    # Test list users
    USER_COUNT=$(podman exec "$container" vastool list users 2>/dev/null | wc -l)
    if [[ "$USER_COUNT" -ge 5 ]]; then
        echo -e "    ${GREEN}✓${NC} vastool list users (${USER_COUNT} users)"
    else
        echo -e "    ${RED}✗${NC} vastool list users FAILED (got ${USER_COUNT} users)"
        ALL_OK=false
    fi

    echo ""
done

if [[ "$ALL_OK" == "true" ]]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "You can now use vastool in any container:"
    echo "  ssh -p 2222 jay@localhost"
    echo "  vastool status"
    echo "  vastool list users"
    echo "  vastool user checkaccess jsmith"
else
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}Installation completed with errors${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    echo "Please check the errors above and retry"
    exit 1
fi

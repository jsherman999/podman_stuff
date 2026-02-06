#!/bin/bash

# Podmania Auto-Start Script
# This script is called by launchd to start the Podman environment

set -euo pipefail

LOGFILE="/Users/jay/podman_stuff/podmania-startup.log"
COMPOSE_DIR="/Users/jay/podman_stuff"

# Redirect all output to log file
exec > >(tee -a "$LOGFILE") 2>&1

echo "================================================"
echo "$(date): Starting Podmania environment"
echo "================================================"

# Function to check if podman machine is running
is_machine_running() {
    /opt/homebrew/bin/podman machine list --format "{{.Running}}" 2>/dev/null | grep -q "true"
}

# Function to wait for podman machine to be ready
wait_for_machine() {
    local max_attempts=30
    local attempt=0

    echo "Waiting for Podman machine to be ready..."
    while [ $attempt -lt $max_attempts ]; do
        if /opt/homebrew/bin/podman ps &>/dev/null; then
            echo "Podman machine is ready!"
            return 0
        fi
        attempt=$((attempt + 1))
        echo "Attempt $attempt/$max_attempts - waiting..."
        sleep 2
    done

    echo "ERROR: Podman machine failed to start within timeout"
    return 1
}

# Start Podman machine if not running
if ! is_machine_running; then
    echo "Starting Podman machine..."
    /opt/homebrew/bin/podman machine start || {
        echo "ERROR: Failed to start Podman machine"
        exit 1
    }

    # Wait for machine to be ready
    if ! wait_for_machine; then
        exit 1
    fi
else
    echo "Podman machine is already running"
fi

# Change to compose directory
cd "$COMPOSE_DIR" || {
    echo "ERROR: Failed to change to directory $COMPOSE_DIR"
    exit 1
}

# Start containers with podman-compose
echo "Starting containers..."
/opt/homebrew/bin/podman-compose up -d || {
    echo "ERROR: Failed to start containers"
    exit 1
}

# Wait for containers to be fully ready
echo "Waiting for containers to initialize..."
sleep 5

# Verify containers are running
echo "Verifying container status..."
RUNNING_COUNT=$(/opt/homebrew/bin/podman ps --format "{{.Names}}" | wc -l)
echo "Running containers: $RUNNING_COUNT"

if [ "$RUNNING_COUNT" -ge 5 ]; then
    echo "SUCCESS: Podmania environment is running!"
    echo "  - jump-server: ssh jump"
    echo "  - target-server-1: ssh ts1"
    echo "  - target-server-2: ssh ts2"
    echo "  - target-server-3: ssh ts3"
    echo "  - target-server-4: ssh ts4"
else
    echo "WARNING: Expected 5 containers but found $RUNNING_COUNT"
fi

echo "$(date): Startup complete"
echo "================================================"

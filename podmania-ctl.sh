#!/bin/bash

# Podmania Control Script
# Manage the Podmania launchd service

set -euo pipefail

PLIST_PATH="$HOME/Library/LaunchAgents/com.podmania.startup.plist"
SERVICE_NAME="com.podmania.startup"

show_usage() {
    cat << EOF
Podmania Control Script

Usage: $0 <command>

Commands:
    status      - Show service status
    start       - Start the service (load and run)
    stop        - Stop containers and unload service
    restart     - Restart the service
    enable      - Enable auto-start at login
    disable     - Disable auto-start at login
    logs        - Show startup logs
    containers  - Show container status
    help        - Show this help message

Examples:
    $0 status
    $0 restart
    $0 logs

EOF
}

check_service_loaded() {
    launchctl list | grep -q "$SERVICE_NAME"
}

cmd_status() {
    echo "=== Podmania Service Status ==="
    echo ""

    if check_service_loaded; then
        echo "✓ Service is loaded"
        launchctl list | grep "$SERVICE_NAME" || true
    else
        echo "✗ Service is not loaded"
    fi

    echo ""
    echo "=== Podman Machine Status ==="
    podman machine list || true

    echo ""
    echo "=== Container Status ==="
    podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No containers running"
}

cmd_start() {
    echo "Starting Podmania service..."

    if check_service_loaded; then
        echo "Service already loaded, triggering startup..."
        launchctl kickstart -k "gui/$(id -u)/$SERVICE_NAME"
    else
        echo "Loading service..."
        launchctl load "$PLIST_PATH"
    fi

    echo "Waiting for startup to complete..."
    sleep 3
    cmd_status
}

cmd_stop() {
    echo "Stopping Podmania environment..."

    # Stop containers first
    cd "$HOME/podman_stuff"
    podman-compose down || true

    # Unload service
    if check_service_loaded; then
        echo "Unloading service..."
        launchctl unload "$PLIST_PATH" || true
    fi

    echo "✓ Podmania stopped"
}

cmd_restart() {
    echo "Restarting Podmania..."
    cmd_stop
    sleep 2
    cmd_start
}

cmd_enable() {
    if [ -f "$PLIST_PATH" ]; then
        echo "Enabling auto-start at login..."
        launchctl load "$PLIST_PATH"
        echo "✓ Podmania will start automatically at login"
    else
        echo "ERROR: plist file not found at $PLIST_PATH"
        exit 1
    fi
}

cmd_disable() {
    echo "Disabling auto-start at login..."
    if check_service_loaded; then
        launchctl unload "$PLIST_PATH"
        echo "✓ Auto-start disabled (containers will remain running)"
    else
        echo "Service is not loaded"
    fi
}

cmd_logs() {
    echo "=== Recent Startup Logs ==="
    if [ -f "$HOME/podman_stuff/podmania-startup.log" ]; then
        tail -50 "$HOME/podman_stuff/podmania-startup.log"
    else
        echo "No logs found"
    fi

    echo ""
    echo "=== LaunchD Logs ==="
    if [ -f "$HOME/podman_stuff/launchd-stdout.log" ]; then
        echo "--- stdout ---"
        tail -20 "$HOME/podman_stuff/launchd-stdout.log"
    fi
    if [ -f "$HOME/podman_stuff/launchd-stderr.log" ]; then
        echo "--- stderr ---"
        tail -20 "$HOME/podman_stuff/launchd-stderr.log"
    fi
}

cmd_containers() {
    echo "=== Container Status ==="
    podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Main command dispatch
case "${1:-help}" in
    status)
        cmd_status
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    enable)
        cmd_enable
        ;;
    disable)
        cmd_disable
        ;;
    logs)
        cmd_logs
        ;;
    containers)
        cmd_containers
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo "ERROR: Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac

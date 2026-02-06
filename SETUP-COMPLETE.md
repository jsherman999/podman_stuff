# Podmania Setup Complete! 🎉

Your Podmania environment is now fully configured with SSH access, host aliases, and auto-start capabilities.

## Quick Access

You can now SSH into any server using short aliases:

```bash
ssh jump    # Jump server
ssh ts1     # Target Server 1
ssh ts2     # Target Server 2
ssh ts3     # Target Server 3
ssh ts4     # Target Server 4
```

No passwords required - SSH keys are configured!

## Host Aliases

The following aliases are configured in `/etc/hosts` and `~/.ssh/config`:

| Alias | Full Name         | Port | IP Address   |
|-------|-------------------|------|--------------|
| jump  | jump-server       | 2222 | 172.25.0.10  |
| ts1   | target-server-1   | 2223 | 172.25.0.11  |
| ts2   | target-server-2   | 2224 | 172.25.0.12  |
| ts3   | target-server-3   | 2225 | 172.25.0.13  |
| ts4   | target-server-4   | 2226 | 172.25.0.14  |

## SSH Key Configuration

✅ **Mac (jay) → All containers**: Passwordless SSH enabled
✅ **jump-server (jay) → All target servers**: Passwordless SSH enabled
✅ **jump-server (root) → All target servers**: Passwordless SSH enabled

### Example Usage

**From your Mac:**
```bash
# Direct access to any server
ssh jump
ssh ts1
ssh ts2

# Run commands remotely
ssh jump "vastool status"
ssh ts1 "vastool list users"
```

**From inside jump-server:**
```bash
# SSH into jump-server first
ssh jump

# Then access target servers (as jay)
ssh target-server-1
ssh ts1  # Using alias

# Or as root
sudo ssh target-server-1
sudo ssh ts1
```

**Chained commands:**
```bash
# Run vastool on ts1 from your Mac through jump-server
ssh jump "ssh ts1 'vastool user checkaccess jsmith'"
```

## Auto-Start at Login

Your Podmania environment will automatically start when you log in to macOS!

### Control Script

Use the `podmania-ctl.sh` script to manage the environment:

```bash
cd ~/podman_stuff

# Check status
./podmania-ctl.sh status

# Show container status
./podmania-ctl.sh containers

# View logs
./podmania-ctl.sh logs

# Restart environment
./podmania-ctl.sh restart

# Stop environment
./podmania-ctl.sh stop

# Start environment
./podmania-ctl.sh start

# Disable auto-start at login
./podmania-ctl.sh disable

# Re-enable auto-start at login
./podmania-ctl.sh enable
```

### LaunchD Service Details

- **Service Name**: `com.podmania.startup`
- **Plist Location**: `~/Library/LaunchAgents/com.podmania.startup.plist`
- **Startup Script**: `~/podman_stuff/start-podmania.sh`
- **Logs**: `~/podman_stuff/podmania-startup.log`

The service:
- ✅ Runs at login (RunAtLoad = true)
- ✅ Starts Podman machine if needed
- ✅ Starts all 5 containers
- ✅ Logs all output for debugging

## Testing Your Setup

Run these commands to verify everything works:

```bash
# Test Mac → all servers
echo "=== Testing direct access ==="
ssh jump "echo Connected to jump-server"
ssh ts1 "echo Connected to ts1"
ssh ts2 "echo Connected to ts2"
ssh ts3 "echo Connected to ts3"
ssh ts4 "echo Connected to ts4"

# Test jump → targets
echo "=== Testing jump-server to targets ==="
ssh jump "ssh ts1 'echo jay@jump can access ts1'"
ssh jump "sudo ssh ts2 'echo root@jump can access ts2'"

# Test vastool through chain
echo "=== Testing vastool ==="
ssh jump "ssh ts1 'vastool status'"
ssh ts2 "vastool list users"
```

## Network Architecture

```
Your Mac
    │
    ├─ ssh jump  (localhost:2222) ─────┐
    ├─ ssh ts1   (localhost:2223)      │
    ├─ ssh ts2   (localhost:2224)      │
    ├─ ssh ts3   (localhost:2225)      │
    └─ ssh ts4   (localhost:2226)      │
                                        │
           Podman Network (jumpnet)     │
           172.25.0.0/16                │
                                        │
    ┌──────────────────────────────────┘
    │
    ├─ jump-server     (172.25.0.10)
    │    └─ Can SSH to all targets
    │
    ├─ target-server-1 (172.25.0.11)
    ├─ target-server-2 (172.25.0.12)
    ├─ target-server-3 (172.25.0.13)
    └─ target-server-4 (172.25.0.14)
```

## What Happens on Reboot?

1. **macOS boots** → launchd starts
2. **launchd runs** → `com.podmania.startup` service
3. **Service starts** → Podman machine (if not running)
4. **Service runs** → `podman-compose up -d`
5. **Containers start** → All 5 servers come online
6. **You can SSH** → Immediately after login!

## Troubleshooting

### Containers not starting at login

Check the logs:
```bash
cat ~/podman_stuff/podmania-startup.log
cat ~/podman_stuff/launchd-stdout.log
cat ~/podman_stuff/launchd-stderr.log
```

Check if service is loaded:
```bash
launchctl list | grep podmania
```

Manually trigger the service:
```bash
launchctl kickstart -k gui/$(id -u)/com.podmania.startup
```

### SSH connection refused

Ensure containers are running:
```bash
podman ps
```

Check SSH daemon status in container:
```bash
podman exec jump-server systemctl status sshd
```

### Can't SSH without password

Verify keys are in place:
```bash
ssh jump "cat ~/.ssh/authorized_keys"
```

## Files Created/Modified

### Configuration Files
- `~/.ssh/config` - SSH host aliases and settings
- `/etc/hosts` - Local hostname resolution
- `~/Library/LaunchAgents/com.podmania.startup.plist` - Auto-start service

### Scripts
- `~/podman_stuff/start-podmania.sh` - Startup script
- `~/podman_stuff/podmania-ctl.sh` - Management script

### Logs
- `~/podman_stuff/podmania-startup.log` - Startup activity
- `~/podman_stuff/launchd-stdout.log` - LaunchD output
- `~/podman_stuff/launchd-stderr.log` - LaunchD errors

### SSH Keys
- All containers have `~/.ssh/authorized_keys` configured
- jump-server has keys for jay and root users
- All target servers accept keys from Mac and jump-server

## Next Steps

Your environment is ready! Here are some things to try:

1. **Test automation**: Create Ansible playbooks using the SSH aliases
2. **Multi-hop SSH**: Practice jump-server patterns
3. **Vastool testing**: Test AD integration scenarios
4. **Python deployment**: Deploy apps across all servers
5. **Security testing**: Practice security scanning tools

Enjoy your Podmania environment! 🚀

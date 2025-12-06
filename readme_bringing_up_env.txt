

Useful commands:

# Stop all servers
podman-compose down

# Start them again
podman-compose up -d

# View logs
podman-compose logs -f jump-server

# Rebuild after changes
podman-compose build --no-cache

# Execute command in a container
podman exec -it jump-server bash

# Check network
podman network inspect jumpnet


-----


I'll create a complete setup with a Dockerfile and docker-compose file for 5 RHEL 9 servers. You can use `podman-compose` to manage them all together.

## Step 1: Create the Dockerfile

```bash
cat > Dockerfile.rhel9-server <<'EOF'
FROM registry.access.redhat.com/ubi9/ubi-init

# Install SSH and basic tools
RUN dnf install -y \
    openssh-server \
    sudo \
    vim \
    net-tools \
    iproute \
    iputils \
    procps-ng \
    && dnf clean all

# Generate SSH host keys
RUN ssh-keygen -A

# Create user 'jay' with sudo access
RUN useradd -m -s /bin/bash jay && \
    echo "jay:password" | chpasswd && \
    echo "jay ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable SSH service
RUN systemctl enable sshd

EXPOSE 22

CMD ["/sbin/init"]
EOF
```

## Step 2: Create the docker-compose.yml

```bash
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  jump-server:
    build:
      context: .
      dockerfile: Dockerfile.rhel9-server
    container_name: jump-server
    hostname: jump-server
    ports:
      - "2222:22"
    networks:
      jumpnet:
        ipv4_address: 172.25.0.10
    privileged: true
    restart: unless-stopped

  target-server-1:
    build:
      context: .
      dockerfile: Dockerfile.rhel9-server
    container_name: target-server-1
    hostname: target-server-1
    ports:
      - "2223:22"
    networks:
      jumpnet:
        ipv4_address: 172.25.0.11
    privileged: true
    restart: unless-stopped

  target-server-2:
    build:
      context: .
      dockerfile: Dockerfile.rhel9-server
    container_name: target-server-2
    hostname: target-server-2
    ports:
      - "2224:22"
    networks:
      jumpnet:
        ipv4_address: 172.25.0.12
    privileged: true
    restart: unless-stopped

  target-server-3:
    build:
      context: .
      dockerfile: Dockerfile.rhel9-server
    container_name: target-server-3
    hostname: target-server-3
    ports:
      - "2225:22"
    networks:
      jumpnet:
        ipv4_address: 172.25.0.13
    privileged: true
    restart: unless-stopped

  target-server-4:
    build:
      context: .
      dockerfile: Dockerfile.rhel9-server
    container_name: target-server-4
    hostname: target-server-4
    ports:
      - "2226:22"
    networks:
      jumpnet:
        ipv4_address: 172.25.0.14
    privileged: true
    restart: unless-stopped

networks:
  jumpnet:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/16
EOF
```

## Step 3: Install podman-compose (if you don't have it)

```bash
# Using pip
pip3 install podman-compose

# Or using brew
brew install podman-compose
```

## Step 4: Build and Start Everything

```bash
# Build the image
podman-compose build

# Start all 5 servers
podman-compose up -d

# Check they're running
podman-compose ps
```

## Step 5: SSH Into Your Servers

```bash
# SSH into jump-server
ssh -p 2222 jay@localhost

# SSH into target-server-1
ssh -p 2223 jay@localhost

# SSH into target-server-2
ssh -p 2224 jay@localhost

# SSH into target-server-3
ssh -p 2225 jay@localhost

# SSH into target-server-4
ssh -p 2226 jay@localhost

# Password for all: password
```

## From Jump Server to Target Servers

Once you SSH into the jump-server, you can SSH to other servers by hostname:

```bash
# From your Mac
ssh -p 2222 jay@localhost

# Now inside jump-server, SSH to target servers
ssh jay@target-server-1  # or 172.25.0.11
ssh jay@target-server-2  # or 172.25.0.12
# etc.
```

## Useful Commands

```bash
# Stop all servers
podman-compose down

# Start them again
podman-compose up -d

# View logs
podman-compose logs -f jump-server

# Rebuild after changes
podman-compose build --no-cache

# Execute command in a container
podman exec -it jump-server bash

# Check network
podman network inspect jumpnet
```

## Optional: Set Up SSH Keys

To avoid typing passwords when jumping between servers:

```bash
# SSH into jump-server
ssh -p 2222 jay@localhost

# Generate SSH key (press Enter for defaults)
ssh-keygen -t rsa -b 4096

# Copy to target servers
for i in {1..4}; do
  ssh-copy-id jay@target-server-$i
done
```

This gives you a realistic jump server environment with 5 RHEL 9 servers all on their own network. Perfect for testing your jump server project!

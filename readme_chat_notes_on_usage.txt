helpful commands:

# Check machine status
podman machine list

# SSH into the Podman VM (if you need to troubleshoot)
podman machine ssh

# Stop the machine when done
podman machine stop

# Start it again later
podman machine start

-----

initializing first time


# 1. Initialize a Podman machine (creates the VM)
podman machine init

# 2. Start the Podman machine
podman machine start

# 3. Verify it's running
podman machine list
```

You should see output showing the machine is running:
```
NAME                     VM TYPE     CREATED      LAST UP            CPUS        MEMORY      DISK SIZE
podman-machine-default*  applehv     2 hours ago  Currently running  2           2GiB        100GiB


More resources:


# Remove the default machine if you want to customize
podman machine stop
podman machine rm

# Create with custom resources
podman machine init --cpus 4 --memory 8192 --disk-size 50

# Start it
podman machine start


Pull rhel9 public image:

--

# Verify connection
podman system connection list

# Pull the image
podman pull registry.access.redhat.com/ubi9/ubi-init

# Test it
podman run --rm registry.access.redhat.com/ubi9/ubi-init cat /etc/redhat-release

----




------
The `cat` test already finished and exited (the `--rm` flag removed it). To get an interactive RHEL 9 container you can SSH into, here's what to do:

## Quick Interactive Shell (easiest for testing)

```bash
# Just get a shell directly
podman run -it --rm registry.access.redhat.com/ubi9/ubi-init /bin/bash
```

This drops you right into the container. Exit with `exit` or Ctrl+D.

## Running Container with SSH Access (for jump server simulation)

For a persistent container you can SSH into:

```bash
# 1. Run a container in the background
podman run -d --name rhel9-test \
  -p 2222:22 \
  registry.access.redhat.com/ubi9/ubi-init

# 2. Install and configure SSH inside it
podman exec -it rhel9-test bash

# Now you're inside the container, run:
dnf install -y openssh-server sudo
ssh-keygen -A
useradd -m -s /bin/bash jay
echo "jay:password" | chpasswd
echo "jay ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
systemctl enable sshd
systemctl start sshd
exit

# 3. SSH into it from your Mac
ssh -p 2222 jay@localhost
# password: password
```

## Better Approach: Create a Custom Image

Since you'll want this setup repeatedly, create a Dockerfile:

```bash
# Create the Dockerfile
cat > Dockerfile.rhel9-ssh <<'EOF'
FROM registry.access.redhat.com/ubi9/ubi-init

RUN dnf install -y openssh-server sudo vim && \
    dnf clean all && \
    ssh-keygen -A && \
    useradd -m -s /bin/bash jay && \
    echo "jay:password" | chpasswd && \
    echo "jay ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

EXPOSE 22
CMD ["/sbin/init"]
EOF

# Build it
podman build -t rhel9-ssh -f Dockerfile.rhel9-ssh .

# Run it
podman run -d --name jump-server -p 2222:22 rhel9-ssh

# SSH in
ssh -p 2222 jay@localhost
```

## Check Running Containers

```bash
# See what's running
podman ps

# Stop a container
podman stop rhel9-test

# Start it again
podman start rhel9-test

# Remove it
podman rm -f rhel9-test
```

Which approach fits better for your jump server testing - the quick interactive shell or the SSH-enabled setup?

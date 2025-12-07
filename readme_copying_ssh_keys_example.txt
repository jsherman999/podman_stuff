
Rebuild of jump server with more packages would wipe out existing ssh key pair, so copy it out and back in after rebuild:

# Copy the SSH keys out of the running container to your Mac
podman cp jump-server:/root/.ssh/id_rsa ./id_rsa.backup
podman cp jump-server:/root/.ssh/id_rsa.pub ./id_rsa.pub.backup

# Now rebuild/recreate the jump-server
podman-compose up -d --force-recreate jump-server

# Copy the keys back into the new container
podman cp ./id_rsa.backup jump-server:/root/.ssh/id_rsa
podman cp ./id_rsa.pub.backup jump-server:/root/.ssh/id_rsa.pub

# Fix permissions
podman exec jump-server chmod 600 /root/.ssh/id_rsa
podman exec jump-server chmod 644 /root/.ssh/id_rsa.pub


Copying root pub key to target servers as authorized_keys:


jay@jmini podman_stuff % podman cp ./id_rsa.pub.backup target-server-1:/root/.ssh/authorized_keys
jay@jmini podman_stuff % podman cp ./id_rsa.pub.backup target-server-2:/root/.ssh/authorized_keys
jay@jmini podman_stuff % podman cp ./id_rsa.pub.backup target-server-3:/root/.ssh/authorized_keys
jay@jmini podman_stuff % podman cp ./id_rsa.pub.backup target-server-4:/root/.ssh/authorized_keys

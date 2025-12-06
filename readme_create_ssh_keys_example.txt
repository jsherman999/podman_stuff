
# SSH into jump-server
ssh -p 2222 jay@localhost

# Generate SSH key (press Enter for defaults)
ssh-keygen -t rsa -b 4096

# Copy to target servers
for i in {1..4}; do
  ssh-copy-id jay@target-server-$i
done

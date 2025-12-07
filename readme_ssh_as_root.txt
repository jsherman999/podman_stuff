


  695  podman exec jump-server chmod 600 /root/.ssh/id_rsa
  696  podman exec jump-server chmod 644 /root/.ssh/id_rsa.pub
  697  ssh -p 2222 jay@localhost
  699  podman cp ./id_rsa.pub.backup target-server-1:/root/.ssh/authorized_keys
  700  podman cp ./id_rsa.pub.backup target-server-2:/root/.ssh/authorized_keys
  701  podman cp ./id_rsa.pub.backup target-server-3:/root/.ssh/authorized_keys
  702  podman cp ./id_rsa.pub.backup target-server-4:/root/.ssh/authorized_keys
  706  ls -latr ~/.ssh
  709  cp ~/.ssh/id_ed25519.pub id_jay.pub
  711  podman cp ./id_jay.pub jump_server:/root/.ssh/authorized_keys
  712  podman cp ./id_jay.pub jump-server:/root/.ssh/authorized_keys
  713  ssh -p 2222 root@localhost

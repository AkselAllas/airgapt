#!/usr/bin/env bash
set -e
set -u

ssh -t ${SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} <<:
sudo su
cat <<EOT > /etc/apt/apt.conf.d/proxy.conf 
Acquire {
  HTTP::proxy "socks5h://127.0.0.1:$TARGET_PORT";
  HTTPS::proxy "socks5h://127.0.0.1:$TARGET_PORT";
}
EOT
:
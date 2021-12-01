#!/usr/bin/env bash
set -e
set -u

test_ssh_socks_proxy(){
  if curl -sL --fail --socks5 localhost:"${SOCKS_PORT}" http://google.com -o /dev/null; then
    success "[+] SOCKS proxy working correctly"
  else
    error "[ ] SOCKS proxy setup failed" 
  fi
}

create_ssh_socks_proxy(){
  info "[ ] Creating local SOCKS proxy to ${LOCAL_USER}@localhost (Allows dynamic outgoing port from airgapped server)";
  set -x
  ssh -f -N -D${SOCKS_PORT} ${SSH_KEY_ARGUMENT} ${LOCAL_USER}@localhost
  set +x
  test_ssh_socks_proxy
}

ensure_ssh_socks_proxy_is_up(){
  if curl -sL --fail --socks5 localhost:"${SOCKS_PORT}" http://google.com -o /dev/null; then
    success "[+] SOCKS proxy working correctly"
  else
    create_ssh_socks_proxy
  fi
}

ensure_remote_ssh_forward_is_up(){
  SSH_FORWARD_UP=$(sudo ss -tulpna | grep 127.0.0.1:${SOCKS_PORT} | wc -l)
  if [ $SSH_FORWARD_UP = 1 ]; then
    success "[+] Remote SSH already forwarded"
  else
    info "[ ] Creating remote SSH forward to ${TARGET_USER}@${TARGET} -R${TARGET_PORT}:localhost:${SOCKS_PORT}";
    set -x
    ssh ${SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} -f -N -R${TARGET_PORT}:localhost:${SOCKS_PORT} 2>/dev/null
    SSH_FORWARD_UP=$(sudo ss -tulpna | grep 127.0.0.1:${SOCKS_PORT} | wc -l)
    set +x
    if [ $SSH_FORWARD_UP = 1 ]; then
      success "[+] Remote SSH forward successfully made"
    else
      error "[-] Remote SSH forward to ${TARGET_USER}@${TARGET} -R${TARGET_PORT}:localhost:${SOCKS_PORT} failed"
    fi
  fi
}

ensure_ssh_socks_proxy_is_up
ensure_remote_ssh_forward_is_up

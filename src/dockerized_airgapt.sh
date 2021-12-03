#!/usr/bin/env bash
set -e
set -u

#Next lines are function definitions for ~200 lines.
#Functions get called at main function at end of script
#### UTILITY FUNCTIONS #####################################################################
C=$(printf '\033')
YELLOW="${C}[1;33m"
RED="${C}[1;31m"
BLUE="${C}[1;34m"
GREEN="${C}[1;32m"
NC="${C}[0m"
LOCAL_SSH_KEY_ARGUMENT="-i ${LOCAL_SSH_KEY_PATH}" 
REMOTE_SSH_KEY_ARGUMENT="-i ${REMOTE_SSH_KEY_PATH}" 

error(){
  printf "${RED}$1\n"
  exit
}
info(){
  printf "${YELLOW}$1$NC\n"
}
success(){
  printf "${GREEN}$1$NC\n"
}
print_title(){
  printf ${BLUE}"-=//=-  $GREEN$1${BLUE}  -=//=-$NC\n"
}

ensure_root(){
  if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "$(whoami 2>/dev/null)" = "root" ]; then
    IAMROOT="1"
  else
    error "You need to run this as root"
  fi
}
############################################################################################


#### LOCAL PROXY FUNCTIONS #################################################################
test_ssh_socks_proxy(){
  if curl -sL --fail --socks5 localhost:"${LOCAL_SOCKS_PORT}" http://google.com -o /dev/null; then
    success "[+] SOCKS proxy working correctly"
  else
    error "[ ] SOCKS proxy setup failed"
  fi
}
create_ssh_socks_proxy(){
  info "[ ] Creating local SOCKS proxy to ${LOCAL_USER}@localhost (Allows dynamic outgoing IP & port from airgapped server)";
  set -x
  ssh -f -N -D${LOCAL_SOCKS_PORT} ${LOCAL_SSH_KEY_ARGUMENT} ${LOCAL_USER}@localhost
  set +x
  test_ssh_socks_proxy
}
ensure_ssh_socks_proxy_is_up(){
  if curl -sL --fail --socks5 localhost:"${LOCAL_SOCKS_PORT}" http://google.com -o /dev/null; then
    success "[+] SOCKS proxy working correctly"
  else
    create_ssh_socks_proxy
  fi
}

ensure_remote_ssh_forward_is_up(){
  SSH_FORWARD_UP=$(ssh ${REMOTE_SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} "sudo ss -tulpna | grep 127.0.0.1:${TARGET_FORWARDED_PORT} | grep LISTEN | wc -l")
  if [ $SSH_FORWARD_UP = 1 ]; then
    success "[+] Remote SSH already forwarded"
  else
    info "[ ] Creating remote SSH forward to ${TARGET_USER}@${TARGET} -R${TARGET_FORWARDED_PORT}:localhost:${LOCAL_SOCKS_PORT}";
    set -x
    ssh ${REMOTE_SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} -f -N -R${TARGET_FORWARDED_PORT}:localhost:${LOCAL_SOCKS_PORT} 2>/dev/null
    set +x
    SSH_FORWARD_UP=$(ssh ${REMOTE_SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} "sudo ss -tulpna | grep 127.0.0.1:${TARGET_FORWARDED_PORT} | grep LISTEN | wc -l")
    if [ $SSH_FORWARD_UP = 1 ]; then
      success "[+] Remote SSH forward successfully made"
    else
      error "[-] Remote SSH forward to ${TARGET_USER}@${TARGET} -R${TARGET_FORWARDED_PORT}:localhost:${LOCAL_SOCKS_PORT} failed"
    fi
  fi
}
############################################################################################


#### REMOTE PROXY FUNCTIONS ################################################################
ensure_remote_server_has_proxy_config(){
ssh_output=$(ssh -q ${REMOTE_SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} <<:
sudo su
cat <<EOT > /etc/apt/apt.conf.d/airgapt_proxy.conf 
Acquire {
  HTTP::proxy "socks5h://127.0.0.1:$TARGET_FORWARDED_PORT";
  HTTPS::proxy "socks5h://127.0.0.1:$TARGET_FORWARDED_PORT";
}
EOT
:
)
success "[+] Remote server has proxy config"
}
############################################################################################


#### MAIN ##################################################################################
ensure_root
print_title "airgapt start"
ensure_ssh_socks_proxy_is_up
ensure_remote_ssh_forward_is_up
ensure_remote_server_has_proxy_config 
print_title "airgapt finish"

#!/usr/bin/env bash
set -e
set -u

#### VARIABLES TO CHANGE ###################################################################
LOCAL_SOCKS_PORT=44444
LOCAL_USER="kali"
TARGET="example.domain"
TARGET_USER="ubuntu"
TARGET_FORWARDED_PORT="6666"
LOCAL_SSH_KEY_PATH="/home/${LOCAL_USER}/.ssh/id_rsa"
REMOTE_SSH_KEY_PATH="/home/${LOCAL_USER}/.ssh/custom_key"
############################################################################################

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
    export IAMROOT="1"
  else
    error "You need to run this as root"
  fi
}
############################################################################################


#### DEPENDENCY SETUP FUNCTIONS ############################################################
does_valid_config_line_exist(){
  STRING=$1
  FILE=$2
  grepRES=$(grep "$STRING" "$FILE" | grep --perl-regexp --invert-match '(?:^;)|(?:^\s*/\*.*\*/)|(?:^\s*#|//|\*)')
  if [ ${#grepRES} -ge 1 ] ; then
    # true
    return 0
  else
    # false
    return 1
  fi
}
ensure_ssh_config_line_exists(){
  STRING=$1
  FILE=$2
  if does_valid_config_line_exist "$STRING" "$FILE";
  then
    success "[+] sshd_config has $STRING";
  else
    info "[ ] adding $STRING";
    set -x
    echo "$STRING" >> "$FILE";
    set +x
    if does_valid_config_line_exist "$STRING" "$FILE";
    then
      success "[+] sshd_config now has $STRING";
      RESTART_SSH="true"
    else
      error "[-] Failed to setup $FILE"
    fi
  fi
}
install_openssh_server(){
  if whereis -b sshd|awk -F: '{print $2}'|awk '{print $1}' | grep -q '/'
  then
    success "[+] Openssh-server already installed";
  else
    info "[ ] Installing openssh-server";
    set -x
    apt-get install -y openssh-server
    set +x
    success "[+] Openssh-server install succeeded";
  fi
}
test_sshd_service(){
  if systemctl status ssh.service | grep -q "masked"; then
      error "[-] SSH service is masked, you need to unmask it.

      e.g run:
        systemctl unmask ssh.service
        systemctl enable ssh.service
        systemctl start ssh.service
        systemctl status ssh.service
      "
  fi
  if systemctl status ssh.service | grep -q "Active: active"; then
      success "[+] ssh server working"
  else
      info "[+] restarted ssh.service"
      systemctl restart ssh.service
      if systemctl status ssh.service | grep -q "Active: active"; then
          success "[+] ssh server working"
      else
         error "[-] ssh.service isn't active"
      fi
  fi
}
setup_sshd_config(){
  RESTART_SSH="false"
  ensure_ssh_config_line_exists 'AllowTcpForwarding yes' '/etc/ssh/sshd_config'
  if [ $RESTART_SSH = "true" ] ; then
    info "[ ] Restarting SSH"
    set -x
    systemctl restart ssh.socket
    systemctl start ssh.service
    set +x
  fi
  test_sshd_service
}
############################################################################################


#### LOCAL PROXY FUNCTIONS #################################################################
ensure_local_authorized_keys_is_fine(){
  if cat "${LOCAL_SSH_KEY_PATH}.pub" | xargs -I{} grep -q {} "/home/${LOCAL_USER}/.ssh/authorized_keys"; then
    success "[+] ${LOCAL_SSH_KEY_PATH}.pub is in authorized keys"
  else
    info "[ ] Concatenating ${LOCAL_SSH_KEY_PATH}.pub to /home/${LOCAL_USER}/.ssh/authorized_keys"
    read -p "Are you sure you want to add ${LOCAL_SSH_KEY_PATH}.pub to /home/${LOCAL_USER}/.ssh/authorized_keys (y/n)?" choice
    case "$choice" in 
      y|Y ) 
            set -x
            cat "${LOCAL_SSH_KEY_PATH}.pub" >> "/home/${LOCAL_USER}/.ssh/authorized_keys"
            set +x
            if cat "${LOCAL_SSH_KEY_PATH}.pub" | xargs -I{} grep -q {} "/home/${LOCAL_USER}/.ssh/authorized_keys"; then
              success "[+] ${LOCAL_SSH_KEY_PATH}.pub is in authorized keys"
            fi;;
      n|N ) 
            echo "skipping";;
      * ) 
            echo "invalid - skipping";;
    esac
  fi
}
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
ssh_output=$(ssh -q ${REMOTE_SSH_KEY_ARGUMENT} ${TARGET_USER}@${TARGET} <<":"
sudo su
cat <<EOT > /etc/apt/apt.conf.d/airgapt_proxy.conf 
Acquire {
  HTTP::proxy "socks5h://127.0.0.1:$TARGET_FORWARDED_PORT";
  HTTPS::proxy "socks5h://127.0.0.1:$TARGET_FORWARDED_PORT";
}
EOT
:
) ; echo $ssh_output > /dev/null
success "[+] Remote server has proxy config"
}
############################################################################################


#### MAIN ##################################################################################
ensure_root
print_title "airgapt start"
install_openssh_server
setup_sshd_config
ensure_local_authorized_keys_is_fine
ensure_ssh_socks_proxy_is_up
ensure_remote_ssh_forward_is_up
ensure_remote_server_has_proxy_config 
print_title "airgapt finish"

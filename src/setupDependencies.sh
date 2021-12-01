#!/usr/bin/env bash
set -e
set -u

install_openssh_server(){
  if dpkg --list | grep -q openssh-server 
  then
    success "[+] Openssh-server already installed";
  else
    info "[ ] Installing openssh-server";
    apt-get install -y openssh-server
    success "[+] Openssh-server install succeeded";
  fi
}

setup_sshd_config(){
  ensure_config_line_exists 'AllowTcpForwarding yes' '/etc/ssh/sshd_config'
  ensure_config_line_exists 'GatewayPorts yes' '/etc/ssh/sshd_config'
}

install_openssh_server
setup_sshd_config

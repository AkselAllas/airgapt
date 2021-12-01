#!/usr/bin/env bash
set -e
set -u

install_openssh_server(){
  if dpkg --list | grep -q openssh-server 
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
      error "[-] ssh.service isn't active"
  fi
}

setup_sshd_config(){
  RESTART_SSH="false"
  ensure_ssh_config_line_exists 'AllowTcpForwarding yes' '/etc/ssh/sshd_config'
  ensure_ssh_config_line_exists 'GatewayPorts yes' '/etc/ssh/sshd_config'
  if [ $RESTART_SSH = "true" ] ; then
    info "[ ] Restarting SSH"
    set -x
    systemctl restart ssh.socket
    systemctl start ssh.service
    set +x
  fi
  test_sshd_service
}


install_openssh_server
setup_sshd_config




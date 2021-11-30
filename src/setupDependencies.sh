#!/usr/bin/env bash
set -e
set -u

if dpkg --list | grep -q openssh-server 
then
  success "[+] Openssh-server already installed";
else
  info "[ ] Installing openssh-server";
  apt-get install -y openssh-server
  success "[+] Openssh-server install succeeded";
fi

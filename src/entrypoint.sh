#!/usr/bin/env bash

run_airgapt_after_sshd_up(){
  ss -tulpna | grep -q ":22"
  while [ $? -gt 0 ]
  do
    sleep 0.1
    ss -tulpna | grep -q ":22"
  done
  sh /app/dockerized_airgapt.sh
}

(/entry.sh /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config) & run_airgapt_after_sshd_up

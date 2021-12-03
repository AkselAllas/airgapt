#!/usr/bin/env bash

run_airgapt_after_sshd_up(){
  ss -tulpna | grep -q ":22"
  while [ $? -gt 0 ]
  do
    sleep 0.1
    ss -tulpna | grep -q ":22"
  done
  sh /app/dockerized_airgapt.sh
  echo "Proxy listening remotely on port $TARGET_FORWARDED_PORT and proxy-ing through docker container port $LOCAL_SOCKS_PORT"
  sleep infinity
}

(/entry.sh /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config) & run_airgapt_after_sshd_up

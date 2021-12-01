#!/usr/bin/env bash
set -e
set -u

error(){
  printf "${RED}$1\n"
  exit
}

SOCKS_PORT=44444
LOCAL_USER="aksel"
SSH_KEY_ARGUMENT=""
TARGET=""
TARGET_USER="ubuntu"
TARGET_PORT="6666"

source src/utilities.sh
ensure_root
print_title airgapt

source src/setupDependencies.sh
source src/localProxySetup.sh
source src/remoteProxySetup.sh

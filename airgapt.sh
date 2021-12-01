#!/usr/bin/env bash
set -e
set -u

#### VARIABLES TO CHANGE ####
SOCKS_PORT=44444
LOCAL_USER="kali"
SSH_KEY_ARGUMENT=""
TARGET="changeme"
TARGET_USER="ubuntu"
TARGET_PORT="6666"
#############################

error(){
  printf "${RED}$1\n"
  exit
}

source src/utilities.sh
ensure_root
print_title airgapt

source src/setupDependencies.sh
source src/localProxySetup.sh
source src/remoteProxySetup.sh

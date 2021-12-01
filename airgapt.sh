#!/usr/bin/env bash
set -e
set -u

error(){
  printf "${RED}$1\n"
  exit
}

PORT=44444
LOCAL_USER="aksel"
SSH_KEY_ARGUMENT=""

source src/utilities.sh
ensure_root
print_title airgapt

source src/setupDependencies.sh

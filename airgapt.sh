#!/usr/bin/env bash
set -e
set -u

error(){
  printf "${RED}$1\n"
  exit
}
source src/utilities.sh
ensure_root
print_title airgapt

source src/setupDependencies.sh


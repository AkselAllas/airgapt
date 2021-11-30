#!/usr/bin/env bash
set -e
set -u

C=$(printf '\033')
YELLOW="${C}[1;33m"
RED="${C}[1;31m"
BLUE="${C}[1;34m"
GREEN="${C}[1;32m"
NC="${C}[0m"

info(){
  printf "${YELLOW}$1$NC\n"
}
success(){
  printf "${GREEN}$1$NC\n"
}
print_title(){
  printf ${BLUE}"-=//=- $GREEN$1 ${BLUE}-=//=-$NC\n" #There are 10 "═"
}

ensure_root(){
  if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "`whoami 2>/dev/null`" = "root" ]; then
    IAMROOT="1"
  else
    error "You need to run this as root"
  fi
}
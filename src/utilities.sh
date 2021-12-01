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
  printf ${BLUE}"-=//=- $GREEN$1 ${BLUE}-=//=-$NC\n"
}

ensure_root(){
  if ([ -f /usr/bin/id ] && [ "$(/usr/bin/id -u)" -eq "0" ]) || [ "$(whoami 2>/dev/null)" = "root" ]; then
    IAMROOT="1"
  else
    error "You need to run this as root"
  fi
}

does_valid_config_line_exist(){
  STRING=$1
  FILE=$2 
  grepRES=$(grep "$STRING" "$FILE" | grep --perl-regexp --invert-match '(?:^;)|(?:^\s*/\*.*\*/)|(?:^\s*#|//|\*)')
  if [ ${#grepRES} -ge 1 ] ; then
    # true
    return 0 
  else
    # false
    return 1
  fi 
}

ensure_ssh_config_line_exists(){
  STRING=$1
  FILE=$2 
  if does_valid_config_line_exist "$STRING" "$FILE"; 
  then
    success "[+] sshd_config has $STRING";
  else
    info "[ ] adding $STRING";
    set -x
    echo "$STRING" >> "$FILE"; 
    set +x
    if does_valid_config_line_exist "$STRING" "$FILE";
    then
      success "[+] sshd_config now has $STRING";
      RESTART_SSH="true"
    else
      error "[-] Failed to setup $FILE"
    fi
  fi
}
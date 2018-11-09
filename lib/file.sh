#!/usr/bin/env bash

mkd() {
  if [[ $# == 0 ]]; then
    print_error "${FUNCNAME[0]} : need target_path"
    return 1
  elif [[ $# -gt 1 ]]; then
    print_error "${FUNCNAME[0]} : too many arguments"
    return 1
  fi
  if [[ -e "$1" ]]; then
    if [[ ! -d "$1" ]]; then
      print_error "${FUNCNAME[0]} : file with the same name already exists : $1"
      return 1
    else
      print_info "directory already exists : $1"
    fi
  else
    if ! mkdir -p "$1"; then
      print_error "${FUNCNAME[0]} : create directory failed : $1"
      return 1
    fi
    print_success "create directory : $1"
  fi
}

#return absolute path
get_abs_path() {
  if [[ $# == 0 ]]; then
    print_error "${FUNCNAME[0]} : need target_path"
    return 1
  elif [[ $# -gt 1 ]]; then
    print_error "${FUNCNAME[0]} : too many arguments"
    return 1
  fi

  #https://unix.stackexchange.com/questions/101080/realpath-command-not-found
  local f=$1
  local base
  local dir
  if [ -d "$f" ]; then
    base=""
    dir="$f"
  else
    base="/$(basename "$f")"
    dir=$(dirname "$f")
  fi
  if [[ ! -e $dir ]]; then
    print_error "${FUNCNAME[0]} : $dir does not exists"
    return 1
  fi
  dir=$(cd "$dir" && pwd)
  if [[ ! -e $dir$base ]]; then
    print_error "${FUNCNAME[0]} : $dir$base does not exists"
    return 1
  fi
  echo "$dir$base"
}

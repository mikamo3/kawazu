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
  if [[ ! -L $dir$base && ! -e $dir$base ]]; then
    print_error "${FUNCNAME[0]} : $dir$base does not exists"
    return 1
  fi
  echo "$dir$base"
}

get_symlink_abs_path() {
  if [[ $# == 0 ]]; then
    print_error "${FUNCNAME[0]} : need target_path"
    return 1
  elif [[ $# -gt 1 ]]; then
    print_error "${FUNCNAME[0]} : too many arguments"
    return 1
  fi

  local target_path=$1
  local target_abs_path
  local target_symlink_path

  if [[ ! -e $target_path ]]; then
    print_error "${FUNCNAME[0]} : $target_path does not exists"
    return 1
  fi

  if [[ ! -L $target_path ]]; then
    print_error "${FUNCNAME[0]} : $target_path is not symbolic link"
    return 1
  fi
  target_symlink_path=$(readlink "$target_path")
  if [[ $target_symlink_path =~ ^/.* ]]; then
    echo "$target_symlink_path"
    return 0
  fi
  target_abs_path=$(get_abs_path "$target_path")
  [[ ! -d $target_abs_path ]] && target_abs_path=$(dirname "$target_abs_path")
  get_abs_path "${target_abs_path}/$(readlink "$target_path")"
}

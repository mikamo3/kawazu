#!/usr/bin/env bash

get_abs_path() {
  [[ "$1" == "not_found" ]] && return 1
  echo "$HOME/abs/path/$1"
}

get_symlink_abs_path() {
  print_mock_info "$@"
}

dot_slash() {
  print_mock_info "$@"
}

get_common_path() {
  print_mock_info "$@"
}

get_rel_path() {
  print_mock_info "$@"
}

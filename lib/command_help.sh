#!/usr/bin/env bash
#TODO: write help
command_help() {
  if [[ $# != 0 ]]; then
    "_help_$1"
  else
    cat <<EOF
usage: kawazu [options] <command> [<args}]
Simple dotfiles manager.
EOF
  fi
  return 0
}

_help_add() {
  cat <<EOF
EOF
}

_help_clone() {
  cat <<EOF
EOF
}

_help_init() {
  cat <<EOF
EOF
}

_help_link() {
  cat <<EOF
EOF
}

_help_unlink() {
  cat <<EOF
EOF
}

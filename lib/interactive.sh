#!/usr/bin/env bash
question() {
  print_question "${1} : "
  read -r
}

confirm() {
  print_question "${1} (y/n) : "
  read -r -n1
  echo ""
}

confirm_is_yes() {
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

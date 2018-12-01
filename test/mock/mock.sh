#!/usr/bin/env bash
print_mock_info() {
  echo "called from : ${FUNCNAME[1]}"
  printf "parameters :"
  for i in "$@"; do
    printf " \"%s\"" "$i"
  done
  printf "\\n"
}

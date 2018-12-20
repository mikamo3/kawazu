#!/usr/bin/env bash
print_mock_info() {
  echo "called from : ${FUNCNAME[1]}"
  printf "parameters :"
  for i in "$@"; do
    printf " \"%s\"" "$i"
  done
  printf "\\n"
  printf "options :\
 OPT_DEBUG=%s,\
 OPT_FORCE=%s,\
 OPT_SKIP=%s\\n" "${OPT_DEBUG:-false}" "${OPT_FORCE:-false}" "${OPT_SKIP:-false}"
  [[ "$1" == "fail" ]] && return 1
  return 0
}

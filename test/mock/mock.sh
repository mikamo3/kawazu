#!/usr/bin/env bash
print_mock_info() {
  if [[ "$1" == "fail" ]]; then
    return 1
  fi
  echo "called from : ${FUNCNAME[1]}"
  printf "parameters :"
  for i in "$@"; do
    printf " \"%s\"" "$i"
  done
  printf "\\n"
  printf "options:\
 OPT_DEBUG=%s,\
 OPT_FORCE=%s,\
 OPT_SKIP=%s\\n" "${OPT_DEBUG:-false}" "${OPT_FORCE:-false}" "${OPT_SKIP:-false}"
}

#!/usr/bin/env bash
is_git_managed_file() {
  if [[ $# != 1 ]]; then
    print_error "${FUNCNAME[0]} : need target_path"
    return 1
  fi
  local target_path
  local result
  target_path="$(dot_slash "$1")"
  [[ -d "$target_path" ]] && return 1
  result=$(
    cd "$(dirname "$target_path")" || return 1
    git ls-files --recurse-submodules "$target_path" 2>/dev/null
  )
  [[ -z "$result" ]] && return 1
  return 0
}

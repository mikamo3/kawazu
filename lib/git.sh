#!/usr/bin/env bash
is_git_managed_file() {
  if [[ $# != 1 ]]; then
    print_error "${FUNCNAME[0]} : need target_path"
    return 1
  fi
  local target_path
  local result

  if [[ ! -L "$1" && ! -e "$1" ]]; then
    print_error "${FUNCNAME[0]} : $1 does not exist"
    return 1
  fi
  if [[ -d "$1" ]]; then
    print_error "${FUNCNAME[0]} : $1 is directory. Please specify a file."
    return 1
  fi
  target_path="$(dot_slash "$1")"
  result=$(
    cd "$(dirname "$target_path")" || return 1
    git ls-files --recurse-submodules "$(basename "$target_path")" 2>/dev/null
  )
  [[ -z "$result" ]] && return 1
  return 0
}

is_git_worktree_root() {
  if [[ $# != 1 ]]; then
    print_error "${FUNCNAME[0]} : need target_path"
  fi
  local target_path="$1"

  if [[ ! -d "$target_path" ]]; then
    print_error "${FUNCNAME[0]} : $target_path does not directory"
    return 1
  fi

  (
    cd "$target_path" || return 1
    [[ $(git rev-parse --show-toplevel 2>/dev/null) != $(get_abs_path "$target_path") ]] && return 1
    return 0
  )
}

list_git_managed_files() {
  if [[ $# != 1 ]]; then
    print_error "${FUNCNAME[0]} : need worktree_path"
    return 1
  fi
  local worktree_path
  if [[ ! -d "$1" ]]; then
    print_error "${FUNCNAME[0]} : $1 is not directory. Please specify a directory."
    return 1
  fi
  worktree_path=$(get_abs_path "$1") || return 1

  (
    cd "$worktree_path" || return 1
    git rev-parse --is-inside-work-tree &>/dev/null || {
      print_error "${FUNCNAME[0]} : $worktree_path is not git worktree"
      return 1
    }

    while IFS= read -r file; do
      local file_path
      file=${file#\"}
      file=${file%\"}
      file_path=$(printf "%b" "$worktree_path/$file")

      #file is deleted, but it is not committed
      [[ ! -L "$file_path" && ! -e "$file_path" ]] && continue
      printf "%b\\0" "$file_path"
    done < <(git ls-files --recurse-submodules --exclude-standard)
  )
}

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

list_git_managed_files() {
  if [[ $# != 1 ]]; then
    print_error "${FUNCNAME[0]} : need worktree_path"
    return 1
  fi
  local worktree_path
  local exclude_file_name=".gitmodules"
  if [[ ! -d "$1" ]]; then
    print_error "${FUNCNAME[0]} : $1 is not directory. Please specify a file."
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
      [[ "$file" =~ $exclude_file_name ]] && continue
      file=${file#\"}
      file=${file%\"}
      file_path=$(printf "%b" "$worktree_path/$file" )
      [[ ! -L "$file_path" && ! -e "$file_path" ]] && continue
      printf "%b\\0" "$file_path"
    done < <(git ls-files --recurse-submodules --exclude-standard)
  )
}

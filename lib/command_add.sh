#!/usr/bin/env bash
command_add() {
  if [[ $# != 1 ]]; then
    print_error "invalid arguments"
    command_help "add"
    return 1
  fi
  local target_path=$1
  local target_abs_path
  local target_repository_path

  # check worktree
  if ! is_git_worktree_root "$KAWAZU_DOTFILES_DIR" &>/dev/null; then
    print_error "$KAWAZU_DOTFILES_DIR is not git worktree"
    return 1
  fi

  if [[ ! -L $target_path && ! -e $target_path ]]; then
    print_error "$target_path does not exist"
    return 1
  fi

  # TODO: when target_path is directory. then add all files in directory
  if [[ -d $target_path ]]; then
    print_error "$target_path is directory. Please specify a file."
    return 1
  fi

  # file does not exist in the HOME directory skip
  target_abs_path=$(get_abs_path "$target_path")
  if [[ ! $target_abs_path =~ ^$HOME/.*$ ]]; then
    print_error "$target_path must be in your home directory"
    return 1
  fi

  target_repository_path=$KAWAZU_DOTFILES_DIR${target_abs_path#$HOME}
  #When the symbolic link is the corresponding repository file. skip
  if [[ -L $target_path ]]; then
    if [[ -e $target_path && "$(get_symlink_abs_path "$target_path")" == "$target_repository_path" ]]; then
      print_info "$target_path is already managed by git. skip"
      return 1
    fi
  fi

  #when target file already managed by git.then confirm and overwrite
  if [[ -e $target_repository_path ]]; then
    confirm "$target_repository_path is already exist. do you want to overwrite?"
    confirm_is_yes || return 1
    rm -rf "$target_repository_path"
  fi
  mkdir -p "$(dirname "$target_repository_path")"
  mv "$(dot_slash "$target_path")" "$target_repository_path"

  #git add
  result=$(cd "$(dirname "$target_repository_path")" && git add "./$(basename "$target_repository_path")") || {
    print_error "$result"
    mv "$target_repository_path" "$(dot_slash "$target_path")"
    return 1
  }

  print_success "add complete $target_path → $target_repository_path"
  return 0
}

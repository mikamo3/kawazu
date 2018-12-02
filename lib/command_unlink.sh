#!/usr/bin/env bash

#if no argments unlink all git managed files
command_unlink() {
  local result="0"
  if [[ $# == 0 ]]; then
    while IFS= read -r -d $'\0' file <&3; do
      local target_path="$HOME${file#$KAWAZU_DOTFILES_DIR}"

      [[ ! -L "$target_path" ]] && continue
      [[ ! "$file" == "$(get_symlink_abs_path "$target_path")" ]] && continue
      _do_unlink "$target_path" || result=$?
    done 3< <(list_git_managed_files "$KAWAZU_DOTFILES_DIR")
    return $result
  elif [[ $# == 1 ]]; then
    _do_unlink "$1"
  else
    print_error "invalid arguments"
    command_help "unlink"
    return 1
  fi
}

_do_unlink() {
  if [[ $# != 1 ]]; then
    print_error "invalid arguments"
    command_help "unlink"
    return 1
  fi
  local target_path=$1
  local link_to_path
  if [[ ! -L "$target_path" ]]; then
    if [[ ! -e "$target_path" ]]; then
      print_error "$target_path does not exist"
    else
      print_error "$target_path is not symlink"
    fi
    return 1
  fi

  if [[ ! "$(get_abs_path "$target_path")" =~ ^$HOME ]]; then
    print_error "$target_path is outside home directory"
    return 1
  fi

  link_to_path="$(get_symlink_abs_path "$target_path")" || {
    print_error "link destination of $target_path does not exist"
    return 1
  }

  if [[ ! "$link_to_path" =~ ^$KAWAZU_DOTFILES_DIR ]]; then
    print_error "$target_path is not dotfiles link"
    return 1
  fi
  rm "$target_path"
  cp -Rf "$link_to_path" "$target_path"
  print_success "unlink complete $target_path"
  return 0
}

#!/usr/bin/env bash

#if no argments unlink all git managed files
command_unlink() {
  if [[ $# == 0 ]]; then
    while IFS= read -r -d $'\0' file <&3; do
      [[ ! -L "$HOME${file#$KAWAZU_DOTFILES_DIR}" ]] && continue
      _do_unlink "$HOME${file#$KAWAZU_DOTFILES_DIR}"
    done 3< <(list_git_managed_files "$KAWAZU_DOTFILES_DIR")
  else
    _do_unlink "$1"
  fi
  return 0
}

_do_unlink() {
  if [[ $# != 1 ]]; then
    print_error "need target_path"
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
  # test -e return false when target_path link is link and broken link
  if ! find "$(readlink "$target_path")" &>/dev/null; then
    print_error "$target_path is not dotfiles link"
    return 1
  fi
  link_to_path="$(get_abs_path "$(readlink "$target_path")")"
  if [[ ! "$link_to_path" =~ ^$KAWAZU_DOTFILES_DIR ]]; then
    print_error "$target_path is not dotfiles link"
    return 1
  fi
  rm "$target_path"
  cp -Rf "$link_to_path" "$target_path"
  print_success "unlink complete $target_path"
  return 0
}

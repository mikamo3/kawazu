#!/usr/bin/env bash
command_link() {
  local result=0
  if [[ $# == 0 ]]; then
    while IFS= read -r -d $'\0' file <&3; do
      _do_link "$file" || result=$?
    done 3< <(list_git_managed_files "$KAWAZU_DOTFILES_DIR")
    return "$result"
  elif [[ $# == 1 ]]; then
    _do_link "$1"
  else
    print_error "invalid arguments"
    command_help "link"
    return 1
  fi
}

_do_link() {
  if [[ $# != 1 ]]; then
    print_error "invalid arguments"
    command_help "link"
    return 1
  fi
  local target_path
  local target_abs_path
  local common_path
  local dst_path
  local rel_path
  target_path=$(dot_slash "$1")

  if [[ ! -L "$target_path" && ! -e "$target_path" ]]; then
    print_error "$target_path does not exist"
    return 1
  fi

  if [[ -d "$target_path" ]]; then
    print_error "$target_path is directory. Please specify a file."
  fi

  if ! is_git_managed_file "$target_path" 2>/dev/null; then
    print_error "$target_path is not dotfiles file"
    return 1
  fi

  target_abs_path="$(get_abs_path "$target_path")"
  common_path="${target_abs_path#$KAWAZU_DOTFILES_DIR}"
  dst_path="$HOME$common_path"

  # when already linked. skip
  if [[ -L "$dst_path" && -e "$dst_path" ]]; then
    if [[ $(get_symlink_abs_path "$dst_path") == "$target_abs_path" ]]; then
      print_info "$target_path already linked"
      return 1
    fi
  fi

  # when dst file already exist.then confirm overwrite
  if [[ -L "$dst_path" && ! -e "$dst_path" ]] \
    || [[ ! -L "$dst_path" && -e "$dst_path" ]]; then
    local now_date
    local backup_path
    now_date="$(date +%Y%m%d)"
    backup_path="$KAWAZU_BACKUP_DIR/$now_date$common_path"
    confirm "$dst_path is already exist. do you want to overwrite?
File is backed up to $backup_path"
    confirm_is_yes || return $?
    mkdir -p "$(dirname "$backup_path")"
    cp "$dst_path" "$backup_path"
    print_success "backup $dst_path → $backup_path"
  fi

  # create symlink relpath
  mkdir -p "$(dirname "$dst_path")"
  rel_path="$(get_rel_path "$(dirname "$dst_path")" "$target_abs_path")"
  ln -sf "$rel_path" "$dst_path"
  print_success "link $target_abs_path → $dst_path"
}

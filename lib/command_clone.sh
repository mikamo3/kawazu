#!/usr/bin/env bash
command_clone() {
  if [[ $# == 0 || $# -gt 2 ]]; then
    print_error "invalid arguments"
    command_help "clone"
    return 1
  fi
  local repo=$1
  local branch=""
  local result

  if [[ $# == 2 ]]; then
    branch=$2
  fi

  result=$(git clone --recursive "$repo" "$KAWAZU_DOTFILES_DIR" 2>&1) || {
    print_error "$result"
    return 1
  }
  print_success "clone : $repo to $KAWAZU_DOTFILES_DIR"
  if [[ -n "$branch" ]]; then
    (
      cd "$KAWAZU_DOTFILES_DIR" || return 1
      if git rev-parse --verify "$branch" &>/dev/null; then
        git checkout "$branch"
      else
        git checkout -b "$branch"
      fi
    )
  fi
  return 0
}

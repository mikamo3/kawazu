#!/usr/bin/env bash

# init a dotfiles repository
# when repository directory is already exists nothing to do
#
command_init() {
  local result
  local branch=""
  if [[ $# -gt 1 ]]; then
    print_error "invalid arguments"
    command_help "init"
    return 1
  fi
  [[ $# == 1 ]] && branch="$1"

  is_git_worktree_root "$KAWAZU_DOTFILES_DIR" && {
    print_info "$KAWAZU_DOTFILES_DIR is git worktree. skip"
    return 1
  }

  result=$(git init "$KAWAZU_DOTFILES_DIR") || {
    print_error "$result"
    return 1
  }

  (
    cd "$KAWAZU_DOTFILES_DIR" || reutrn 1
    # TODO: write gitignore
    touch .gitignore
    [[ -n "$branch" ]] && git checkout -b "$branch"
    git add .gitignore
  )
  print_success "git repository created at $KAWAZU_DOTFILES_DIR"
}

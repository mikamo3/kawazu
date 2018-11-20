#!/usr/bin/env bash

# init a dotfiles repository
# when repository directory is already exists
#
init() {
  #TODO: add param branch If branch is set in the parameter, switch the branch after initialization
  local target_repository=$KAWAZU_DOTFILES_DIR
  [[ ! -e $target_repository ]] && mkd "$target_repository"

  # check target directory is already managed by git
  if (cd "$target_repository" && ! git rev-parse --is-inside-work-tree &>/dev/null); then
    result=$(cd "$target_repository" \
      && git init 2>&1 \
      && touch .gitignore
    ) || {
      print_error "$result"
      return 1
    }
    print_success "git repository created : $target_repository"
  else
    print_info "$target_repository is already managed by git"
  fi
}

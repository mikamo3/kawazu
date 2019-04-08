#!/usr/bin/env bash
kawazu() {
  if [[ $1 == "cd" ]]; then
    cd "${KAWAZU_DOTFILES_DIR:-$HOME/.kawazu/dotfiles}" || return 1
  else
    "${KAWAZU_ROOT_DIR:-$HOME/.kawazu/repos}/bin/kawazu" "$@"
  fi
}

#!/usr/bin/bash
export_env() {
  KAWAZU_ROOT_DIR="$BATS_TEST_DIRNAME/../.."
  KAWAZU_DOTFILES_DIR="/tmp/.dotfiles"
  KAWAZU_VERSION="0.1"
  export KAWAZU_ROOT_DIR
  export KAWAZU_DOTFILES_DIR
  export KAWAZU_VERSION
}

delete_dotfiles_dir() {
  rm -rf "$KAWAZU_DOTFILES_DIR"
}

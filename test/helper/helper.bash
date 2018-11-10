#!/usr/bin/bash
export_env() {
  KAWAZU_ROOT_DIR="$BATS_TEST_DIRNAME/../.."
  KAWAZU_DOTFILES_DIR="/tmp/.dotfiles"
  KAWAZU_VERSION="0.1"
  export KAWAZU_ROOT_DIR
  export KAWAZU_DOTFILES_DIR
  export KAWAZU_VERSION
}
create_dotfiles_git_repository() {
  (mkdir -p "$KAWAZU_DOTFILES_DIR" && cd "$KAWAZU_DOTFILES_DIR" && git init)
}
delete_dotfiles_git_repository() {
  rm -rf "$KAWAZU_DOTFILES_DIR"
}

is_git_repository() {
  (cd "$1" && git rev-parse --is-inside-work-tree)
  return $?
}

create_local_git_bare_repository() {
  local_git_repository_path=/tmp/git_repos.git
  mkdir -p "$local_git_repository_path"
  (cd $local_git_repository_path && git init --bare)
}

delete_local_git_bare_repository() {
  local_git_repository_path=/tmp/git_repos.git
  rm -rf "$local_git_repository_path"
}

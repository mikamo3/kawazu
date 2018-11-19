#!/usr/bin/bash
export_env() {
  TEST_WORK_DIR="/tmp/test"
  KAWAZU_ROOT_DIR="$BATS_TEST_DIRNAME/../.."
  KAWAZU_DOTFILES_DIR="${TEST_WORK_DIR}/.dotfiles"
  KAWAZU_VERSION="0.1"
  HOME="$TEST_WORK_DIR/home/user"
  OPT_DEBUG=true
  export TEST_WORK_DIR
  export KAWAZU_ROOT_DIR
  export KAWAZU_DOTFILES_DIR
  export KAWAZU_VERSION
  export OPT_DEBUG
}

create_test_directory() {
  mkdir -p "$TEST_WORK_DIR"
  mkdir -p "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
}

delete_test_directory() {
  rm -rf "$TEST_WORK_DIR"
}
create_dotfiles_git_repository() {
  (mkdir -p "$KAWAZU_DOTFILES_DIR" \
    && cd "$KAWAZU_DOTFILES_DIR" \
    && git init \
    && git config user.name "test" \
    && git config user.email "test@example.com")
}
delete_dotfiles_git_repository() {
  rm -rf "$KAWAZU_DOTFILES_DIR"
}

is_git_repository() {
  (cd "$1" && git rev-parse --is-inside-work-tree)
  return $?
}

create_local_git_bare_repository() {
  local_git_repository_path="$TEST_WORK_DIR/git_repos.git"
  mkdir -p "$local_git_repository_path"
  (cd $local_git_repository_path && git init --bare)
}

delete_local_git_bare_repository() {
  local_git_repository_path="$TEST_WORK_DIR/git_repos.git"
  rm -rf "$local_git_repository_path"
}

get_current_branch() {
  local branch
  branch=$(cd "$KAWAZU_DOTFILES_DIR" && git branch | grep "^\\* ")
  echo "${branch#* }"
}

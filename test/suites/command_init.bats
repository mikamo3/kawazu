#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  source ${KAWAZU_ROOT_DIR}/lib/command_init.sh
  delete_dotfiles_git_repository
}

teardown() {
  delete_dotfiles_git_repository
}

@test "init when dotfiles directory does not exists" {
  run init
  assert_success
  is_git_repository /tmp/.dotfiles
  assert_output -p "[✓] git repository created : /tmp/.dotfiles"
}

@test "init when dofiles already exists .git file" {
  mkdir -p /tmp/.dotfiles
  touch /tmp/.dotfiles/.git
  run init
  assert_failure
  assert_output -p "[✗] "
}

@test "init when dotfiles directory already exists" {
  mkdir -p /tmp/.dotfiles/.git
  run init
  assert_success
  assert_output -p "[✓] git repository created : /tmp/.dotfiles"
}

@test "init when dotfiles directory already managed by git" {
  mkdir -p /tmp/.dotfiles/
  create_dotfiles_git_repository
  run init
  assert_success
  assert_output -p "[i] /tmp/.dotfiles is already managed by git"
}

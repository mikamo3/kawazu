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
  create_test_directory
}

teardown() {
  delete_test_directory
}

@test "init when dotfiles directory does not exists" {
  run init
  assert_success
  is_git_repository /tmp/test/.dotfiles
  assert_output -p "[✓] git repository created : /tmp/test/.dotfiles"
}

@test "init when dofiles already exists .git file" {
  mkdir -p /tmp/test/.dotfiles
  touch /tmp/test/.dotfiles/.git
  run init
  assert_failure
  assert_output -p "[✗] "
}

@test "init when dotfiles directory already exists" {
  mkdir -p /tmp/test/.dotfiles/.git
  run init
  assert_success
  assert_output -p "[✓] git repository created : /tmp/test/.dotfiles"
}

@test "init when dotfiles directory already managed by git" {
  mkdir -p /tmp/test/.dotfiles/
  create_dotfiles_git_repository
  run init
  assert_success
  assert_output -p "[i] /tmp/test/.dotfiles is already managed by git"
}

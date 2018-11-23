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
  create_test_files
}

teardown() {
  delete_test_dir
}

@test "init when dotfiles directory does not exists" {
  rm -rf "$KAWAZU_DOTFILES_DIR"
  run init
  assert_success
  is_git_repository "$KAWAZU_DOTFILES_DIR"
  assert_output -p "[✓] git repository created : $KAWAZU_DOTFILES_DIR"
}

@test "init when dofiles already exists .git file" {
  touch "$KAWAZU_DOTFILES_DIR/.git"
  run init
  assert_failure
  assert_output -p "[✗] "
}

@test "init when dotfiles directory already exists" {
  run init
  assert_success
  assert_output -p "[✓] git repository created : $KAWAZU_DOTFILES_DIR"
}

@test "init when dotfiles directory already managed by git" {
  create_git_repository
  run init
  assert_success
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR is already managed by git"
}

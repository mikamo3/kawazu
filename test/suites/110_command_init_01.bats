#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env
load ../fixtures/git

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/file.sh
source ${KAWAZU_ROOT_DIR}/lib/git.sh
source ${KAWAZU_ROOT_DIR}/lib/command_init.sh

source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh
source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.target path
#   is empty directory
#   is file
#   is worktree
#   is directory contains files
#   does not exist
# 3. branch option
#   switch to branch

@test "command_init with 2 argument" {
  run command_init a b
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "init"
  assert_failure
}

@test "command_init target path is empty directory" {
  mkdir -p "$KAWAZU_DOTFILES_DIR"
  run command_init
  assert_output -p "[✓] git repository created at $KAWAZU_DOTFILES_DIR"
  assert diff "$KAWAZU_DOTFILES_DIR/.gitignore" <(printf "")
  assert_success
}

@test "command_init target path is file" {
  touch "$KAWAZU_DOTFILES_DIR"
  run command_init
  assert_failure
}

@test "command_init target path is worktree" {
  create_local_git_repository "$KAWAZU_DOTFILES_DIR"
  run command_init
  assert_failure
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR is git worktree. skip"
}

@test "command_init target path is directory contains files" {
  mkdir -p "$KAWAZU_DOTFILES_DIR"
  touch "$KAWAZU_DOTFILES_DIR/file"
  run command_init
  assert_success
  assert_file_exist "$KAWAZU_DOTFILES_DIR/file"
}

@test "command_init target path does not exist" {
  run command_init
  assert_success
}

@test "command_init set option branch" {
  run command_init branch
  assert_success
  cd "$KAWAZU_DOTFILES_DIR"
  assert_equal "$(LANG=C git status |head -n1 )" "On branch branch"
}

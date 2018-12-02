#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env

source "$KAWAZU_ROOT_DIR/kawazu.sh"
KAWAZU_ROOT_DIR=$KAWAZU_ROOT_DIR/test/mock
source "$KAWAZU_ROOT_DIR/mock.sh"
export -f print_mock_info

setup() {
  mkdir -p "$KAWAZU_DOTFILES_DIR"
}

teardown() {
  delete_test_dir
}

@test "kawazu run with no args" {
  run kawazu
  assert_mock_output 0 main
  assert_success
}

@test "kawazu run cd" {
  kawazu cd
  assert_equal "$(pwd)" "$KAWAZU_DOTFILES_DIR"
}

@test "kawazu with args" {
  run kawazu a b c
  assert_mock_output 0 main a b c
  assert_success
}

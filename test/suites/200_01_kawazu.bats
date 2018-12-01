#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source "$KAWAZU_ROOT_DIR/kawazu.sh"
  KAWAZU_ROOT_DIR=$KAWAZU_ROOT_DIR/test/mock
  source "$KAWAZU_ROOT_DIR/mock.sh"
  export -f print_mock_info

  cd "$HOME"
}

teardown() {
  delete_test_dir
}

@test "main with no args" {
  run kawazu
  assert_mock_output 0 main
  assert_success
}

@test "main run cd" {
  kawazu cd
  assert_equal "$(pwd)" "$KAWAZU_DOTFILES_DIR"
}

@test "main with args" {
  run kawazu a b c
  assert_mock_output 0 main a b c
  assert_success
}

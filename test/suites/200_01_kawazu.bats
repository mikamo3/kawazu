#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source "$KAWAZU_ROOT_DIR/kawazu.sh"
  cd "$HOME"
}

teardown() {
  delete_test_dir
}

@test "kawazu with no args" {
  run kawazu
  assert_output -p "usage: kawazu"
  assert_success
}

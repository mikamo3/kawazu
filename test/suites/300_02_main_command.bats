#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  KAWAZU_BIN=$KAWAZU_ROOT_DIR/bin/kawazu
  KAWAZU_ROOT_DIR=$KAWAZU_ROOT_DIR/test/mock
  source "$KAWAZU_ROOT_DIR/mock.sh"
  export -f print_mock_info

  cd "$HOME"
}

teardown() {
  delete_test_dir
}
@test "main command: none" {
  run $KAWAZU_BIN
  assert_mock_output 0 command_help
  assert_failure
}

@test "main command: unknown" {
  run $KAWAZU_BIN unknown
  assert_output -p "invalid command : unknown"
  assert_failure
}

@test "main command: add params: none" {
  run $KAWAZU_BIN add
  assert_mock_output 0 command_help add
  assert_failure
}

@test "main command: add params: a" {
  run $KAWAZU_BIN add a
  assert_mock_output 0 command_add a
  assert_success
}

@test "main command: add params: a b" {
  run $KAWAZU_BIN add a b
  assert_mock_output 0 command_add a
  assert_mock_output 3 command_add b
  assert_success
}

@test "main command: clone params: none" {
  run $KAWAZU_BIN clone
  assert_mock_output 0 command_help clone
  assert_failure
}

@test "main command: clone params: a" {
  run $KAWAZU_BIN clone a
  assert_mock_output 0 command_clone a
  assert_success
}

@test "main command: clone params: a b" {
  run $KAWAZU_BIN clone a b
  assert_mock_output 0 command_clone a b
  assert_success
}

@test "main command: clone params: a b c" {
  run $KAWAZU_BIN clone a b c
  assert_mock_output 0 command_help clone
  assert_failure
}

@test "main command: init params: none" {
  run $KAWAZU_BIN init
  assert_mock_output 0 command_init
  assert_success
}

@test "main command: init params: a" {
  run $KAWAZU_BIN init a
  assert_mock_output 0 command_init a
  assert_success
}

@test "main command: init params: a b" {
  run $KAWAZU_BIN init a b
  assert_mock_output 0 command_help init
  assert_failure
}

@test "main command: link params: none" {
  run $KAWAZU_BIN link
  assert_mock_output 0 command_help link
  assert_failure
}

@test "main command: link params: a" {
  run $KAWAZU_BIN link a
  assert_mock_output 0 command_link a
  assert_success
}

@test "main command: link params: a b" {
  run $KAWAZU_BIN link a b
  assert_mock_output 0 command_link a
  assert_mock_output 3 command_link b
  assert_success
}

@test "main command: unlink params: none" {
  run $KAWAZU_BIN unlink
  assert_mock_output 0 command_help unlink
  assert_failure
}

@test "main command: unlink params: a" {
  run $KAWAZU_BIN unlink a
  assert_mock_output 0 command_unlink a
  assert_success
}

@test "main command: unlink params: a b" {
  run $KAWAZU_BIN unlink a b
  assert_mock_output 0 command_unlink a
  assert_mock_output 3 command_unlink b
  assert_success
}

@test "main command: add params: a fail b (some commands fail)" {
  run $KAWAZU_BIN add a fail b
  assert_mock_output 0 command_add a
  assert_mock_output 3 command_add b
  assert_failure
}

@test "main command: link params: a fail b (some commands fail)" {
  run $KAWAZU_BIN link a fail b
  assert_mock_output 0 command_link a
  assert_mock_output 3 command_link b
  assert_failure
}

@test "main command: unlink params: a fail b (some commands fail)" {
  run $KAWAZU_BIN unlink a fail b
  assert_mock_output 0 command_unlink a
  assert_mock_output 3 command_unlink b
  assert_failure
}

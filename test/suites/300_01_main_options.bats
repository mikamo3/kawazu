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

@test "main with no option" {
  run $KAWAZU_BIN
  assert_mock_output 0 command_help
  assert_failure
}

@test "main option: -d" {
  run $KAWAZU_BIN -d
  assert_mock_output -d 0 command_help
  assert_failure
}

@test "main option: -f" {
  run $KAWAZU_BIN -f
  assert_mock_output -f 0 command_help
  assert_failure
}

@test "main option: -s" {
  run $KAWAZU_BIN -s
  assert_mock_output -s 0 command_help
  assert_failure
}

@test "main option: -d -f -s" {
  run $KAWAZU_BIN -d -f -s
  assert_mock_output -dfs 0 command_help
  assert_failure
}

@test "main option: -df" {
  run $KAWAZU_BIN -df
  assert_mock_output -df 0 command_help
  assert_failure
}

@test "main option: -dfs" {
  run $KAWAZU_BIN -dfs
  assert_mock_output -dfs 0 command_help
  assert_failure
}

@test "main option: --debug" {
  run $KAWAZU_BIN --debug
  assert_mock_output -d 0 command_help
  assert_failure
}

@test "main option: --force" {
  run $KAWAZU_BIN --force
  assert_mock_output -f 0 command_help
  assert_failure
}

@test "main option: --skip" {
  run $KAWAZU_BIN --skip
  assert_mock_output -s 0 command_help
  assert_failure
}

@test "main option: --debug --force --skip" {
  run $KAWAZU_BIN --debug --force --skip
  assert_mock_output -dfs 0 command_help
  assert_failure
}
@test "main option: --debug --skip" {
  run $KAWAZU_BIN --debug --skip
  assert_mock_output -ds 0 command_help
  assert_failure
}

@test "main option: --debug -f --skip" {
  run $KAWAZU_BIN --debug -f --skip
  assert_mock_output -dfs 0 command_help
  assert_failure
}

@test "main contain invalid long option" {
  run $KAWAZU_BIN --debug --invalid_option -f
  assert_output -p "[✗] invalid option : --invalid_option"
  assert_failure
}

@test "main contain invalid short option" {
  run $KAWAZU_BIN --debug -x -f
  assert_output -p "[✗] invalid option : -x"
  assert_failure
}

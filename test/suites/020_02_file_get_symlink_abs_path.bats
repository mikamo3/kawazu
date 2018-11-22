#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
}

teardown() {
  delete_test_dir
}
@test "get_symlink_abs_path with no args" {
  run get_symlink_abs_path
  assert_output -p "[✗] get_symlink_abs_path : need target_path"
  assert_failure
}

@test "get_symlink_abs_path with 2 args" {
  run get_symlink_abs_path a b
  assert_output -p "[✗] get_symlink_abs_path : too many arguments"
  assert_failure
}

@test "get_symlink_abs_path when file not exist" {
  run get_symlink_abs_path "$TEST_WORK_DIR/file_not_exist"
  assert_output -p "[✗] get_symlink_abs_path : $TEST_WORK_DIR/file_not_exist does not exists"
  assert_failure
}

@test "get_symlink_abs_path when file is not symlink" {
  run get_symlink_abs_path "$TEST_WORK_DIR/path/to/dir/file"
  assert_output -p "[✗] get_symlink_abs_path : $TEST_WORK_DIR/path/to/dir/file is not symbolic link"
  assert_failure
}

@test "get_symlink_abs_path get abs path symlink 1" {
  run get_symlink_abs_path "$TEST_WORK_DIR/path/to/dir/abs_symlink"
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_symlink_abs_path get abs path symlink 2" {
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_symlink_abs_path ./abs_symlink
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_symlink_abs_path get abs path symlink 3" {
  cd "$TEST_WORK_DIR/path/to"
  run get_symlink_abs_path dir/abs_symlink
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_symlink_abs_path get rel path symlink 1" {
  run get_symlink_abs_path "$TEST_WORK_DIR/path/to/dir/rel_symlink"
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_symlink_abs_path get rel path symlink 2" {
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_symlink_abs_path ./rel_symlink
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_symlink_abs_path get rel path symlink 3" {
  cd "$TEST_WORK_DIR/path/to"
  run get_symlink_abs_path dir/rel_symlink
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

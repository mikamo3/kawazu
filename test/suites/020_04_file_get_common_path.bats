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

@test "get_common_path with no args" {
  run get_common_path
  assert_output -p "[✗] get_common_path : need target_path1 target_path2"
  assert_failure
}

@test "get_common_path with 1 arg" {
  run get_common_path file
  assert_output -p "[✗] get_common_path : need target_path1 target_path2"
  assert_failure
}

@test "get_common_path path1 does not exist" {
  run get_common_path "path/to/not_exist" "path/to/dir/file"
  assert_failure
}

@test "get_common_path path2 does not exist" {
  run get_common_path "path/to/dir/file" "path/to/not_exist"
  assert_failure
}

@test "get_common_path both paths are the same file (rel path)" {
  run get_common_path "path/to/dir/file" "path/to/dir/file"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_common_path both paths are the same file (abs path)" {
  run get_common_path "$TEST_WORK_DIR/path/to/dir/file" "$TEST_WORK_DIR/path/to/dir/file"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}


@test "get_common_path path/to/dir/file and path/to/dir" {
  run get_common_path "path/to/dir/file" "path/to/dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_common_path path and path/to/dir/file" {
  run get_common_path "path" "path/to/dir/file"
  assert_output "$TEST_WORK_DIR/path"
  assert_success
}

@test "get_common_path file and path/to/dir/file" {
  run get_common_path "file" "path/to/dir/file"
  assert_output "$TEST_WORK_DIR"
  assert_success
}

@test "get_common_path path/to/dir/file and file" {
  run get_common_path "path/to/dir/file" "file"
  assert_output "$TEST_WORK_DIR"
  assert_success
}

@test "get_common_path each paths totally different" {
  run get_common_path "/var" "/tmp"
  assert_output "/"
  assert_success
}

@test "get_common_path path1 is broken link" {
  run get_common_path "path/to/symlink_dir/broken_symlink" "path/to"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_common_path path2 is broken link" {
  run get_common_path "path/to" "path/to/symlink_dir/broken_symlink"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_common_path each paths contain unsuitable caracter" {
  cd "path/to"
  run get_common_path "-newline
dir $(emoji)*/-newline
file $(emoji)*" "-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_output "$TEST_WORK_DIR/path/to/-newline
dir $(emoji)*"
  assert_success
}

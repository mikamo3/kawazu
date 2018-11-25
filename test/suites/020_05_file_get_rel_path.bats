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

@test "get_rel_path with no args" {
  run get_rel_path
  assert_output -p "[✗] get_rel_path : need target_path1 target_path2"
  assert_failure
}

@test "get_rel_path with 1 arg" {
  run get_rel_path file
  assert_output -p "[✗] get_rel_path : need target_path1 target_path2"
  assert_failure
}

@test "get_rel_path path1 does not exist" {
  run get_rel_path "path/to/not_exist" "path/to/dir/file"
  assert_failure
}

@test "get_rel_path path2 does not exist" {
  run get_rel_path "path/to/dir/file" "path/to/not_exist"
  assert_failure
}

@test "get_rel_path path1 is not directory" {
  run get_rel_path "path/to/dir/file" "path/to/dir/file"
  assert_output -p "[✗] get_rel_path : $TEST_WORK_DIR/path/to/dir/file is not directory"
  assert_failure
}

@test "get_rel_path both paths are the same directory(rel path)" {
  run get_rel_path "path/to/dir" "path/to/dir/file"
  assert_output "./file"
  assert_success
}

@test "get_rel_path both paths are the same directory(abs path)" {
  run get_rel_path "$TEST_WORK_DIR/path/to/dir" "$TEST_WORK_DIR/path/to/dir/file"
  assert_output "./file"
  assert_success
}

@test "get_rel_path target file at upper directory" {
  run get_rel_path "path/to/dir" "file"
  assert_output "../../../file"
  assert_success
}

@test "get_rel_path target file at upper directory" {
  run get_rel_path "path/to/dir" "file"
  assert_output "../../../file"
  assert_success
}

@test "get_rel_path target file at child directory" {
  run get_rel_path "./" "path/to/dir/file"
  assert_output "./path/to/dir/file"
  assert_success
}

@test "get_rel_path target file at other directory" {
  run get_rel_path "path/to/dir2/" "path/to/dir/file"
  assert_output "../dir/file"
  assert_success
}

@test "get_rel_path target is directory" {
  run get_rel_path "./" "path/to/dir"
  assert_output "./path/to/dir"
  assert_success
}

@test "get_rel_path target file is broken link" {
  run get_rel_path "./" "path/to/symlink_dir/broken_symlink"
  assert_output "./path/to/symlink_dir/broken_symlink"
  assert_success
}

@test "get_rel_path target file path contain unsuitable caracter" {
  run get_rel_path "./" "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_output "./path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_success
}

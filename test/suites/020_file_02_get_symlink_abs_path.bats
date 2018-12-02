#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/file.sh

UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

setup() {
  cd "$TEST_WORK_DIR"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.specify not symlink
#   file does not exist
#   file
#   directory
#   broken link
# 3.specify link path
#   link is absolute file path
#   link is absolute dir path
#   link is relative file path
#     link to path is upper directory
#     link to path is sub directory
#     link to path is upper sub directory
#   link is relative dir path
#     link to path is upper directory
#     link to path is sub directory
#     link to path is upper sub directory
# 4.contain unsuitable character
#   in symlink name
#   in symlink to path

@test "get_symlink_abs_path run with no args" {
  run get_symlink_abs_path
  assert_output -p "[✗] get_symlink_abs_path : need target_path"
  assert_failure
}

@test "get_symlink_abs_path run with 2 args" {
  run get_symlink_abs_path "a" "b"
  assert_output -p "[✗] get_symlink_abs_path : too many arguments"
  assert_failure
}

@test "get_symlink_abs_path target path does not exist" {
  run get_symlink_abs_path "file"
  assert_output -p "[✗] get_symlink_abs_path : file does not exists"
  assert_failure
}

@test "get_symlink_abs_path target path is file" {
  touch "file"
  run get_symlink_abs_path "file"
  assert_output -p "[✗] get_symlink_abs_path : file is not symbolic link"
  assert_failure
}

@test "get_symlink_abs_path target path is directory" {
  mkdir -p "dir"
  run get_symlink_abs_path "dir"
  assert_output -p "[✗] get_symlink_abs_path : dir is not symbolic link"
  assert_failure
}

@test "get_symlink_abs_path target path is broken link" {
  ln -s "/not_found" "link"
  run get_symlink_abs_path "link"
  assert_output -p "[✗] get_symlink_abs_path : link is broken symbolic link"
  assert_failure
}

@test "get_symlink_abs_path link is abs file path" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  ln -s "$TEST_WORK_DIR/path/to/dir/file" "link"
  run get_symlink_abs_path "link"
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_symlink_abs_path link is abs dir path" {
  mkdir -p "path/to/dir"
  ln -s "$TEST_WORK_DIR/path/to/dir" "link"
  run get_symlink_abs_path "link"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_symlink_abs_path link is file in upper directory path" {
  mkdir -p "path/to/dir"
  touch "path/to/file"
  ln -s "../file" "path/to/dir/link"
  run get_symlink_abs_path "path/to/dir/link"
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_symlink_abs_path link is file in sub directory path" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  ln -s "dir/file" "path/to/link"
  run get_symlink_abs_path "path/to/link"
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}
@test "get_symlink_abs_path link is file in upper sub directory path" {
  mkdir -p "path/to/dir"
  mkdir -p "path/to/dir2"
  touch "path/to/dir2/file"
  ln -s "../dir2/file" "path/to/dir/link"
  run get_symlink_abs_path "path/to/dir/link"
  assert_output "$TEST_WORK_DIR/path/to/dir2/file"
  assert_success
}

@test "get_symlink_abs_path link is dir in upper directory path" {
  mkdir -p "path/to/dir"
  ln -s "../dir" "path/to/dir/link"
  run get_symlink_abs_path "path/to/dir/link"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_symlink_abs_path link is dir in sub directory path" {
  mkdir -p "path/to/dir"
  ln -s "dir" "path/to/link"
  run get_symlink_abs_path "path/to/link"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_symlink_abs_path link is directory in upper sub directory path" {
  mkdir -p "path/to/dir"
  mkdir -p "path/to/dir2"
  ln -s "../dir2" "path/to/dir/link"
  run get_symlink_abs_path "path/to/dir/link"
  assert_output "$TEST_WORK_DIR/path/to/dir2"
  assert_success
}

@test "get_symlink_abs_path link name and to path is contain unsuitable character" {
  mkdir -p "path/to/dir"
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    touch "path/to/dir/$i"
    ln -s "path/to/dir/$i" "./$i"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_symlink_abs_path "$i"
    assert_output "$TEST_WORK_DIR/path/to/dir/$i"
    assert_success
  done
}

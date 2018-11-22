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

@test "get_abs_path with no args" {
  run get_abs_path
  assert_output -p "[✗] get_abs_path : need target_path"
  assert_failure
}

@test "get_abs_path with 2 args" {
  run get_abs_path a b
  assert_output -p "[✗] get_abs_path : too many arguments"
  assert_failure
}

@test "get_abs_path abs path(dir)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path abs path(file)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/file"
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path abs path(file name is contain space)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/file space"
  assert_output "$TEST_WORK_DIR/path/to/dir/file space"
  assert_success
}

@test "get_abs_path rel path 1(dir)" {
  cd path
  run get_abs_path to/dir
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path rel path 2(dir)" {
  cd path/to
  run get_abs_path dir/../../to/dir
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path rel path 3(dir)" {
  cd path/to/dir
  run get_abs_path .
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path rel path 4(dir)" {
  cd path/to/dir
  run get_abs_path ..
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_abs_path rel path 5(dir)" {
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path ../
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_abs_path rel path 6(dir)" {
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path ../../../../../../../
  assert_output /
  assert_success
}
#TODO: dir newline

@test "get_abs_path rel path 1(file)" {
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path dir/file
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path rel path 2(file)" {
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path dir/../../to/dir/file
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path rel path 3(file)" {
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path ./file
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path rel path 4(file)" {
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path ../file
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}
#TODO: file newline
@test "get_abs_path when file not exist 1" {
  cd path/to/dir
  run get_abs_path file_not_exist
  assert_output -p "[✗] get_abs_path : $TEST_WORK_DIR/path/to/dir/file_not_exist does not exists"
  assert_failure
}

@test "get_abs_path when file not exist 2" {
  cd "path/to/dir"
  run get_abs_path ../../file_not_exist
  assert_output -p "[✗] get_abs_path : $TEST_WORK_DIR/path/file_not_exist does not exists"
  assert_failure
}

@test "get_abs_path path name * " {
  run get_abs_path "*"
  assert_output -p "[✗] get_abs_path : $TEST_WORK_DIR/* does not exists"
  assert_failure
}

@test "get_abs_path abs symlink" {
  run get_abs_path path/to/dir/abs_symlink
  assert_output "$TEST_WORK_DIR/path/to/dir/abs_symlink"
  assert_success
}

@test "get_abs_path rel symlink" {
  run get_abs_path path/to/dir/rel_symlink
  assert_output "$TEST_WORK_DIR/path/to/dir/rel_symlink"
  assert_success
}
@test "get_abs_path symlink is broken" {
  cd path/to/dir
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/broken_symlink"
  assert_output "$TEST_WORK_DIR/path/to/dir/broken_symlink"
  assert_success
}

@test "get_abs_path abs path(file name is contain newline)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/newline
file"
  assert_output "$TEST_WORK_DIR/path/to/dir/newline
file"
  assert_success
}

@test "get_abs_path rel path(file name is contain newline)" {
  run get_abs_path "path/to/dir/newline
file"
  assert_output "$TEST_WORK_DIR/path/to/dir/newline
file"
  assert_success
}

@test "get_abs_path abs path(dir name is contain newline)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/newline
dir"
  assert_output "$TEST_WORK_DIR/path/to/newline
dir"
  assert_success
}

@test "get_abs_path rel path(dir name is contain newline)" {
  run get_abs_path "path/to/newline
dir"
  assert_output "$TEST_WORK_DIR/path/to/newline
dir"
  assert_success
}

@test "get_abs_path abs path(dir and file names are contain newline)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/newline
dir/newline
file"
  assert_output "$TEST_WORK_DIR/path/to/newline
dir/newline
file"
  assert_success
}

@test "get_abs_path rel path(dir and file names are contain newline)" {
  run get_abs_path "path/to/newline
dir/newline
file"
  assert_output "$TEST_WORK_DIR/path/to/newline
dir/newline
file"
  assert_success
}

@test "get_abs_path abs path(dir name is contain emoji)" {
  run get_abs_path "$TEST_WORK_DIR/$(emoji)"
  assert_output "$TEST_WORK_DIR/$(emoji)"
}

@test "get_rel_path abs path(dir name is contain emoji)" {
  run get_abs_path "./$(emoji)"
  assert_output "$TEST_WORK_DIR/$(emoji)"
}

@test "get_abs_path abs path(file name is contain emoji)" {
  run get_abs_path "$TEST_WORK_DIR/$(emoji)/$(emoji)"
  assert_output "$TEST_WORK_DIR/$(emoji)/$(emoji)"
}

@test "get_rel_path abs path(file name is contain emoji)" {
  run get_abs_path "./$(emoji)/$(emoji)"
  assert_output "$TEST_WORK_DIR/$(emoji)/$(emoji)"
}

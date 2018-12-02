#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/file.sh

setup() {
  cd "$TEST_WORK_DIR"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.specify absolute directory path
# 3.specify absolute file path
# 4.specify absolute symlink path
# 5.specify relative directory path
# 6.specify relative file path

# arguments error
@test "get_abs_path run with no args" {
  run get_abs_path
  assert_output -p "[✗] get_abs_path : need target_path"
  assert_failure
}

@test "get_abs_path run with 2 args" {
  run get_abs_path a b
  assert_output -p "[✗] get_abs_path : too many arguments"
  assert_failure
}

#target is absolute directory path
@test "get_abs_path target path is root" {
  run get_abs_path "/"
  assert_output "/"
  assert_success
}
@test "get_abs_path target path is abs dir path" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is abs dir path (trailing slash)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is abs dir path (trailing slash dot)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/."
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is abs dir path (dir name contains *)" {
  mkdir -p "$TEST_WORK_DIR/path/to/*"
  run get_abs_path "$TEST_WORK_DIR/path/to/*"
  assert_output "$TEST_WORK_DIR/path/to/*"
  assert_success
}

@test "get_abs_path target path is abs dir path (dir name contains -)" {
  mkdir -p "$TEST_WORK_DIR/path/to/-e"
  run get_abs_path "$TEST_WORK_DIR/path/to/-e"
  assert_output "$TEST_WORK_DIR/path/to/-e"
  assert_success
}

@test "get_abs_path target path is abs dir path (dir name contains space)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir name"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir name"
  assert_output "$TEST_WORK_DIR/path/to/dir name"
  assert_success
}

@test "get_abs_path target path is abs dir path (dir name contains newline)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir
name"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir
name"
  assert_output "$TEST_WORK_DIR/path/to/dir
name"
  assert_success
}

@test "get_abs_path target path is abs dir path (dir name contains emoji)" {
  mkdir -p "$TEST_WORK_DIR/path/to/👹"
  run get_abs_path "$TEST_WORK_DIR/path/to/👹"
  assert_output "$TEST_WORK_DIR/path/to/👹"
  assert_success
}

#target is absolute file path
@test "get_abs_path target path is abs file path" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/file"
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path target path is abs file path (file name contains *)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/*"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/*"
  assert_output "$TEST_WORK_DIR/path/to/dir/*"
  assert_success
}

@test "get_abs_path target path is abs file path (file name contains -)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/-e"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/-e"
  assert_output "$TEST_WORK_DIR/path/to/dir/-e"
  assert_success
}

@test "get_abs_path target path is abs file path (file name contains space)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file name"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/file name"
  assert_output "$TEST_WORK_DIR/path/to/dir/file name"
  assert_success
}

@test "get_abs_path target path is abs file path (file name contains newline)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file
newline"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/file
newline"
  assert_output "$TEST_WORK_DIR/path/to/dir/file
newline"
  assert_success
}

@test "get_abs_path target path is abs file path (file name contains emoji)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/👹"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/👹"
  assert_output "$TEST_WORK_DIR/path/to/dir/👹"
  assert_success
}

@test "get_abs_path target path is abs file path (file does not exist)" {
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/file"
  assert_output -p "[✗] get_abs_path : $TEST_WORK_DIR/path/to/dir/file does not exists"
  assert_failure
}

#target is absolute symbolic link path
@test "get_abs_path target path is abs symlink path (file path symlink)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/file"
  ln -s "$TEST_WORK_DIR/file" "$TEST_WORK_DIR/path/to/dir/symlink"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/symlink"
  assert_output "$TEST_WORK_DIR/path/to/dir/symlink"
  assert_success
}

@test "get_abs_path target path is abs symlink path (dir path symlink)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  ln -s "$TEST_WORK_DIR/path/to" "$TEST_WORK_DIR/path/to/dir/symlink"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/symlink"
  assert_output "$TEST_WORK_DIR/path/to/dir/symlink"
  assert_success
}

@test "get_abs_path target path is abs symlink path (broken symlink)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  ln -s "/not_found" "$TEST_WORK_DIR/path/to/dir/symlink"
  run get_abs_path "$TEST_WORK_DIR/path/to/dir/symlink"
  assert_output "$TEST_WORK_DIR/path/to/dir/symlink"
  assert_success
}

#target is relative directory path
@test "get_abs_path target path is rel dir path" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is current dir" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "."
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_abs_path target path is rel dir path (forward ./)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "./dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is upper dir path" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "../to"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_abs_path target path is rel dir path (trailing slash)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "dir/"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is rel dir path (trailing slash dot)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "dir/."
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_abs_path target path is rel dir path (dir name contains *)" {
  mkdir -p "$TEST_WORK_DIR/path/to/*"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "*"
  assert_output "$TEST_WORK_DIR/path/to/*"
  assert_success
}

@test "get_abs_path target path is rel dir path (dir name contains -)" {
  mkdir -p "$TEST_WORK_DIR/path/to/-e"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "-e"
  assert_output "$TEST_WORK_DIR/path/to/-e"
  assert_success
}

@test "get_abs_path target path is rel dir path (dir name contains space)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir name"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "dir name"
  assert_output "$TEST_WORK_DIR/path/to/dir name"
  assert_success
}

@test "get_abs_path target path is rel dir path (dir name contains newline)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir
name"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "dir
name"
  assert_output "$TEST_WORK_DIR/path/to/dir
name"
  assert_success
}

@test "get_abs_path target path is rel dir path (dir name contains emoji)" {
  mkdir -p "$TEST_WORK_DIR/path/to/👹"
  cd "$TEST_WORK_DIR/path/to"
  run get_abs_path "👹"
  assert_output "$TEST_WORK_DIR/path/to/👹"
  assert_success
}

#target is relative file path
@test "get_abs_path target path is rel file path" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "file"
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path target path is rel file path (forward ./)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "./file"
  assert_output "$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_abs_path target path is upper dir file path" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/file"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "../file"
  assert_output "$TEST_WORK_DIR/path/to/file"
  assert_success
}

@test "get_abs_path target path is rel file path (file name contains *)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/*"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "*"
  assert_output "$TEST_WORK_DIR/path/to/dir/*"
  assert_success
}

@test "get_abs_path target path is rel file path (file name contains -)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/-e"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "-e"
  assert_output "$TEST_WORK_DIR/path/to/dir/-e"
  assert_success
}

@test "get_abs_path target path is rel file path (file name contains space)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file name"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "file name"
  assert_output "$TEST_WORK_DIR/path/to/dir/file name"
  assert_success
}

@test "get_abs_path target path is rel file path (file name contains newline)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file
name"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "file
name"
  assert_output "$TEST_WORK_DIR/path/to/dir/file
name"
  assert_success
}

@test "get_abs_path target path is rel file path (file name contains emoji)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/👹"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "👹"
  assert_output "$TEST_WORK_DIR/path/to/dir/👹"
  assert_success
}

@test "get_abs_path target path is rel file path (file does not exists)" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  cd "$TEST_WORK_DIR/path/to/dir"
  run get_abs_path "file"
  assert_output -p "[✗] get_abs_path : file does not exists"
  assert_failure
}

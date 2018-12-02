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
# 2.specify path does not exist
#   path1
#   path2
# 3.specify path with same directory
#   target path type
#     path_1=dir path_2=dir
#     path_1=dir path_2=file
#     path_1=file path_2=dir
#     path_1=file path_2=file
#   each paths contain unsuitable character
# 4.specify path that partially matches each
#   target path type
#     path_1=dir path_2=dir
#     path_1=dir path_2=file
#     path_1=file path_2=dir
#     path_1=file path_2=file
#   target path is root directory
#     path_1
#     path_2
#     both
#   each paths contain unsuitable character
# 4.specify different paths respectively

@test "get_common_path run with no args" {
  run get_common_path
  assert_output -p "[✗] get_common_path : need target_path1 target_path2"
  assert_failure
}

@test "get_common_path run with 1 arg" {
  run get_common_path file
  assert_output -p "[✗] get_common_path : need target_path1 target_path2"
  assert_failure
}

@test "get_common_path path1 does not exist" {
  mkdir -p "path/to/dir"
  run get_common_path "path/to/not_exist" "path/to/dir"
  assert_output -p "[✗]"
  assert_failure
}

@test "get_common_path path2 does not exist" {
  mkdir -p "path/to/dir"
  run get_common_path "path/to/dir" "path/to/not_exist"
  assert_output -p "[✗]"
  assert_failure
}

@test "get_common_path path with same directory. path1 is dir. path2 is dir" {
  mkdir -p "path/to/dir"
  run get_common_path "path/to/dir" "path/to/dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_common_path path with same directory. path1 is dir. path2 is file" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_common_path "path/to/dir" "path/to/dir/file"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success

}

@test "get_common_path path with same directory. path1 is file. path2 is dir" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_common_path "path/to/dir/file" "path/to/dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_common_path path with same directory. path1 is file. path2 is file" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_common_path "path/to/dir/file" "path/to/dir"
  assert_output "$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_common_path path with same directory. each paths contain unsuitable character" {
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    mkdir -p "path/to/$i"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_common_path "path/to/$i" "path/to/$i"
    assert_output "$TEST_WORK_DIR/path/to/$i"
    assert_success
  done
}

@test "get_common_path path that partially matches each. path1 is dir. path2 is dir" {
  mkdir -p "path/to/dir1"
  mkdir -p "path/to/dir2"
  run get_common_path "path/to/dir1" "path/to/dir2"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_common_path path that partially matches each. path1 is dir. path2 is file" {
  mkdir -p "path/to/dir1"
  mkdir -p "path/to/dir2"
  touch "path/to/dir2/file"
  run get_common_path "path/to/dir1" "path/to/dir2/file"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success

}

@test "get_common_path path that partially matches each. path1 is file. path2 is dir" {
  mkdir -p "path/to/dir1"
  mkdir -p "path/to/dir2"
  touch "path/to/dir1/file"
  run get_common_path "path/to/dir1/file" "path/to/dir2"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_common_path path that partially matches each. path1 is file. path2 is file" {
  mkdir -p "path/to/dir1"
  mkdir -p "path/to/dir2"
  touch "path/to/dir1/file"
  touch "path/to/dir2/file"
  run get_common_path "path/to/dir1/file" "path/to/dir2/file"
  assert_output "$TEST_WORK_DIR/path/to"
  assert_success
}

@test "get_common_path path that partially matches each. path1 is root dir. path2 is dir" {
  mkdir -p "path/to/dir2"
  run get_common_path "/" "path/to/dir2"
  assert_output "/"
  assert_success
}

@test "get_common_path path that partially matches each. path1 is dir. path2 is root dir" {
  mkdir -p "path/to/dir1"
  run get_common_path "path/to/dir1" "/"
  assert_output "/"
  assert_success
}

@test "get_common_path path that partially matches each. path1 is root dir. path2 is root dir" {
  run get_common_path "/" "/"
  assert_output "/"
  assert_success
}

@test "get_common_path path that partially matches each. each paths contain unsuitable character" {
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    mkdir -p "path/to/$i/dir1"
    mkdir -p "path/to/$i/dir2"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_common_path "path/to/$i/dir1" "path/to/$i/dir2"
    assert_output "$TEST_WORK_DIR/path/to/$i"
    assert_success
  done
}

@test "get_common_path different paths respectively" {
  [[ -e /var ]] || skip "/var does not exist."
  run get_common_path "$TEST_WORK_DIR" "/var"
  assert_output "/"
  assert_success
}

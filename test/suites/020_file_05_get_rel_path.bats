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
# test patterm
# 1.wrong arguments
# 2.target path is sub directory
#   file
#   directory
#   symlink
#   broken symlink
#   file that unsuitable character in name
# 3.target path is current directory
#   file
#   directory
#   symlink
#   broken symlink
#   file that unsuitable character in name
# 4.target path is upper directory
#   file
#   directory
#   symlink
#   broken symlink
#   file that unsuitable character in name
# 5.target path is a totally different directory
#   file
#   directory
#   symlink
#   broken symlink
#   file that unsuitable character in name

@test "get_rel_path run with no args" {
  run get_rel_path
  assert_output -p "[✗] get_rel_path : need base_dir target_path"
  assert_failure
}

@test "get_rel_path with 1 arg" {
  run get_rel_path file
  assert_output -p "[✗] get_rel_path : need base_dir target_path"
  assert_failure
}

@test "get_rel_path base_dir does not exist" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_rel_path "path/to/not_exist" "path/to/dir/file"
  assert_failure
}

@test "get_rel_path target_path does not exist" {
  mkdir -p "path/to/dir"
  run get_rel_path "path/to/dir" "path/to/dir/not_exist"
  assert_failure
}

@test "get_rel_path base_dir is not directory" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_rel_path "path/to/dir/file" "path/to/dir/file"
  assert_output -p "[✗] $TEST_WORK_DIR/path/to/dir/file is not directory"
  assert_failure
}

@test "get_rel_path target_path is a file included in the sub dir" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_rel_path "path/to" "path/to/dir/file"
  assert_output "./dir/file"
  assert_success
}

@test "get_rel_path target_path is a dir included in the sub dir" {
  mkdir -p "path/to/dir"
  run get_rel_path "path/to" "path/to/dir"
  assert_output "./dir"
  assert_success
}

@test "get_rel_path target_path is a symlink included in the sub dir" {
  mkdir -p "path/to/dir"
  touch "file"
  ln -s "../../../file" "path/to/dir/symlink"
  run get_rel_path "path/to" "path/to/dir/symlink"
  assert_output "./dir/symlink"
  assert_success

}

@test "get_rel_path target_path is a broken symlink included in the sub dir" {
  mkdir -p "path/to/dir"
  ln -s "/not_found" "path/to/dir/symlink"
  run get_rel_path "path/to" "path/to/dir/symlink"
  assert_output "./dir/symlink"
  assert_success
}

@test "get_rel_path target_path is a file that unsuiable character in name and it is included in the sub dir" {
  mkdir -p "path/to/dir"
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    touch "path/to/dir/$i"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_rel_path "path/to" "path/to/dir/$i"
    assert_output "./dir/$i"
    assert_success
  done
}

@test "get_rel_path target_path is a file included in the cur dir" {
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_rel_path "path/to/dir" "path/to/dir/file"
  assert_output "./file"
  assert_success
}

@test "get_rel_path target_path is a dir included in the cur dir" {
  mkdir -p "path/to/dir"
  run get_rel_path "path/to/dir" "path/to/dir"
  assert_output "./"
  assert_success
}

@test "get_rel_path target_path is a symlink included in the cur dir" {
  mkdir -p "path/to/dir"
  touch "file"
  ln -s "../../../file" "path/to/dir/symlink"
  run get_rel_path "path/to/dir" "path/to/dir/symlink"
  assert_output "./symlink"
  assert_success

}

@test "get_rel_path target_path is a broken symlink included in the cur dir" {
  mkdir -p "path/to/dir"
  ln -s "/not_found" "path/to/dir/symlink"
  run get_rel_path "path/to/dir" "path/to/dir/symlink"
  assert_output "./symlink"
  assert_success
}

@test "get_rel_path target_path is a file that unsuiable character in name and it is included in the cur dir" {
  mkdir -p "path/to/dir"
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    touch "path/to/dir/$i"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_rel_path "path/to/dir" "path/to/dir/$i"
    assert_output "./$i"
    assert_success
  done
}

@test "get_rel_path target_path is a file included in the upper dir" {
  mkdir -p "path/to/dir"
  touch "path/to/file"
  run get_rel_path "path/to/dir" "path/to/file"
  assert_output "../file"
  assert_success
}

@test "get_rel_path target_path is a dir included in the upper dir" {
  mkdir -p "path/to/dir"
  run get_rel_path "path/to/dir" "path/to"
  assert_output "../"
  assert_success
}

@test "get_rel_path target_path is a symlink included in the upper dir" {
  mkdir -p "path/to/dir"
  touch "file"
  ln -s "../../file" "path/to/symlink"
  run get_rel_path "path/to/dir" "path/to/symlink"
  assert_output "../symlink"
  assert_success

}

@test "get_rel_path target_path is a broken symlink included in the upper dir" {
  mkdir -p "path/to/dir"
  ln -s "/not_found" "path/to/symlink"
  run get_rel_path "path/to/dir" "path/to/symlink"
  assert_output "../symlink"
  assert_success
}

@test "get_rel_path target_path is a file that unsuiable character in name and it is included in the upper dir" {
  mkdir -p "path/to/dir"
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    touch "path/to/$i"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_rel_path "path/to/dir" "path/to/$i"
    assert_output "../$i"
    assert_success
  done
}

@test "get_rel_path target_path is a file included in outside base_dir" {
  [[ -e /var ]] || skip "/var does not exist"
  mkdir -p "path/to/dir"
  touch "path/to/dir/file"
  run get_rel_path "/var" "path/to/dir/file"
  assert_output "../$TEST_WORK_DIR/path/to/dir/file"
  assert_success
}

@test "get_rel_path target_path is a dir included in outside base_dir" {
  [[ -e /var ]] || skip "/var does not exist"
  mkdir -p "path/to/dir"
  run get_rel_path "/var" "path/to/dir"
  assert_output "../$TEST_WORK_DIR/path/to/dir"
  assert_success
}

@test "get_rel_path target_path is a symlink included in outside base_dir" {
  [[ -e /var ]] || skip "/var does not exist"
  mkdir -p "path/to/dir"
  touch "file"
  ln -s "../../../file" "path/to/dir/symlink"
  run get_rel_path "/var" "path/to/dir/symlink"
  assert_output "../$TEST_WORK_DIR/path/to/dir/symlink"
  assert_success

}

@test "get_rel_path target_path is a broken symlink included in outside base_dir" {
  [[ -e /var ]] || skip "/var does not exist"
  mkdir -p "path/to/dir"
  ln -s "/not_found" "path/to/dir/symlink"
  run get_rel_path "/var" "path/to/dir/symlink"
  assert_output "../$TEST_WORK_DIR/path/to/dir/symlink"
  assert_success
}

@test "get_rel_path target_path is a file that unsuiable character in name and it is included in outside base_dir" {
  [[ -e /var ]] || skip "/var does not exist"
  mkdir -p "path/to/dir"
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    touch "path/to/dir/$i"
  done
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run get_rel_path "/var" "path/to/dir/$i"
    assert_output "../$TEST_WORK_DIR/path/to/dir/$i"
    assert_success
  done
}

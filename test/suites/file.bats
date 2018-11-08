#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  mkdir -p /tmp/abs_test_dir/a/b/c/d
  touch /tmp/abs_test_dir/a/b/c/d/testfile
  touch "/tmp/abs_test_dir/a/b/c/d/test file"
  touch /tmp/abs_test_dir/a/b/testfile
}

teardown() {
  rm -rf /tmp/abs_test_dir
}

@test "get_abs_path with no args" {
  run get_abs_path
  assert_output -p "get_abs_path : need target_path"
  assert_failure
}

@test "get_abs_path with 2 args" {
  run get_abs_path a b
  assert_output -p "get_abs_path : too many arguments"
  assert_failure
}

@test "get_abs_path ask absolute path(dir)" {
  run get_abs_path /tmp/abs_test_dir/a/b/c/d/
  assert_output /tmp/abs_test_dir/a/b/c/d
  assert_success
}

@test "get_abs_path ask absolute path(file)" {
  run get_abs_path /tmp/abs_test_dir/a/b/c/d/testfile
  assert_output /tmp/abs_test_dir/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path ask absolute path(file with space)" {
  run get_abs_path "/tmp/abs_test_dir/a/b/c/d/test file"
  assert_output "/tmp/abs_test_dir/a/b/c/d/test file"
  assert_success
}

@test "get_abs_path ask rel path 1(dir)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/d/
  assert_output /tmp/abs_test_dir/a/b/c/d
  assert_success
}

@test "get_abs_path ask rel path 2(dir)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/../../b/c/d/
  assert_output /tmp/abs_test_dir/a/b/c/d
  assert_success
}

@test "get_abs_path ask rel path 3(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path .
  assert_output /tmp/abs_test_dir/a/b/c/d
  assert_success
}

@test "get_abs_path ask rel path 4(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ..
  assert_output /tmp/abs_test_dir/a/b/c
  assert_success
}

@test "get_abs_path ask rel path 5(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../
  assert_output /tmp/abs_test_dir/a/b/c
  assert_success
}

@test "get_abs_path ask rel path 6(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../../../../../../../
  assert_output /
  assert_success
}

@test "get_abs_path ask rel path 1(file)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/d/testfile
  assert_output /tmp/abs_test_dir/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path ask rel path 2(file)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/../../b/c/d/testfile
  assert_output /tmp/abs_test_dir/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path ask rel path 3(file)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ./testfile
  assert_output /tmp/abs_test_dir/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path ask rel path 4(file)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../../testfile
  assert_output /tmp/abs_test_dir/a/b/testfile
  assert_success
}

@test "get_abs_path ask when file not exist 1" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path file_not_exist
  assert_output -p "get_abs_path : /tmp/abs_test_dir/a/b/c/d/file_not_exist does not exists"
  assert_failure
}

@test "get_abs_path ask when file not exist 2" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../../file_not_exist
  assert_output -p "get_abs_path : /tmp/abs_test_dir/a/b/file_not_exist does not exists"
  assert_failure
}

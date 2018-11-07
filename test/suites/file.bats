#!/usr/bin/env bats
load ../helper

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
  [[ $output =~ "get_abs_path : need target_path" ]]
  [[ $status == 1 ]]
}

@test "get_abs_path with 2 args" {
  run get_abs_path a b
  [[ $output =~ "get_abs_path : too many arguments" ]]
  [[ $status == 1 ]]
}

@test "get_abs_path ask absolute path(dir)" {
  run get_abs_path /tmp/abs_test_dir/a/b/c/d/
  [[ $output == /tmp/abs_test_dir/a/b/c/d ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask absolute path(file)" {
  run get_abs_path /tmp/abs_test_dir/a/b/c/d/testfile
  [[ $output == /tmp/abs_test_dir/a/b/c/d/testfile ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask absolute path(file with space)" {
  run get_abs_path "/tmp/abs_test_dir/a/b/c/d/test file"
  [[ $output == "/tmp/abs_test_dir/a/b/c/d/test file" ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 1(dir)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/d/
  [[ $output == /tmp/abs_test_dir/a/b/c/d ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 2(dir)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/../../b/c/d/
  [[ $output == /tmp/abs_test_dir/a/b/c/d ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 3(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path .
  [[ $output == /tmp/abs_test_dir/a/b/c/d ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 4(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ..
  [[ $output == /tmp/abs_test_dir/a/b/c ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 5(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../
  [[ $output == /tmp/abs_test_dir/a/b/c ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 6(dir)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../../../../../../../
  [[ $output == / ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 1(file)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/d/testfile
  [[ $output == /tmp/abs_test_dir/a/b/c/d/testfile ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 2(file)" {
  cd /tmp/abs_test_dir/a/b/
  run get_abs_path c/../../b/c/d/testfile
  [[ $output == /tmp/abs_test_dir/a/b/c/d/testfile ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 3(file)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ./testfile
  [[ $output == /tmp/abs_test_dir/a/b/c/d/testfile ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask rel path 4(file)" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../../testfile
  [[ $output == /tmp/abs_test_dir/a/b/testfile ]]
  [[ $status == 0 ]]
}

@test "get_abs_path ask when file not exist 1" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path file_not_exist
  [[ $output =~ "get_abs_path : /tmp/abs_test_dir/a/b/c/d/file_not_exist does not exists" ]]
  [[ $status == 1 ]]
}

@test "get_abs_path ask when file not exist 2" {
  cd /tmp/abs_test_dir/a/b/c/d
  run get_abs_path ../../file_not_exist
  [[ $output =~ "get_abs_path : /tmp/abs_test_dir/a/b/file_not_exist does not exists" ]]
  [[ $status == 1 ]]
}

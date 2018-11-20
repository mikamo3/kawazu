#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  mkdir -p /tmp/test/a/b/c/d
  touch /tmp/test/a/b/c/d/testfile
  touch "/tmp/test/a/b/c/d/test file"
  touch /tmp/test/a/b/testfile
  ln -s /tmp/test/a/b/testfile /tmp/test/a/b/c/d/symlink_testfile
  ln -s deadlink /tmp/test/a/b/c/d/deadlink
  ln -s /tmp/test/a/b/testfile /tmp/test/a/b/c/abs_sym_testfile
  (cd /tmp/test/a/b/c && ln -s ../testfile rel_sym_testfile)
}

teardown() {
  rm -rf /tmp/test
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
  run get_symlink_abs_path /file_not_exist
  assert_output -p "[✗] get_symlink_abs_path : /file_not_exist does not exists"
  assert_failure
}

@test "get_symlink_abs_path when file is not symlink" {
  run get_symlink_abs_path /tmp/test/a/b/c/d/testfile
  assert_output -p "[✗] get_symlink_abs_path : /tmp/test/a/b/c/d/testfile is not symbolic link"
  assert_failure
}

@test "get_symlink_abs_path get abs path symlink 1" {
  run get_symlink_abs_path /tmp/test/a/b/c/abs_sym_testfile
  assert_output "/tmp/test/a/b/testfile"
  assert_success
}

@test "get_symlink_abs_path get abs path symlink 2" {
  cd /tmp/test/a/b/c/d
  run get_symlink_abs_path ../abs_sym_testfile
  assert_output "/tmp/test/a/b/testfile"
  assert_success
}

@test "get_symlink_abs_path get abs path symlink 3" {
  cd /tmp/test/a/b/
  run get_symlink_abs_path c/abs_sym_testfile
  assert_output "/tmp/test/a/b/testfile"
  assert_success
}

@test "get_symlink_abs_path get rel path symlink 1" {
  run get_symlink_abs_path /tmp/test/a/b/c/rel_sym_testfile
  assert_output "/tmp/test/a/b/testfile"
  assert_success
}

@test "get_symlink_abs_path get rel path symlink 2" {
  cd /tmp/test/a/b/c/d
  run get_symlink_abs_path ../rel_sym_testfile
  assert_output "/tmp/test/a/b/testfile"
  assert_success
}

@test "get_symlink_abs_path get rel path symlink 3" {
  cd /tmp/test/a/b
  run get_symlink_abs_path c/rel_sym_testfile
  assert_output "/tmp/test/a/b/testfile"
  assert_success
}

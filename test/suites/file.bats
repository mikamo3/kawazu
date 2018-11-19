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

@test "get_abs_path absolute path(dir)" {
  run get_abs_path /tmp/test/a/b/c/d/
  assert_output /tmp/test/a/b/c/d
  assert_success
}

@test "get_abs_path absolute path(file)" {
  run get_abs_path /tmp/test/a/b/c/d/testfile
  assert_output /tmp/test/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path absolute path(file with space)" {
  run get_abs_path "/tmp/test/a/b/c/d/test file"
  assert_output "/tmp/test/a/b/c/d/test file"
  assert_success
}

@test "get_abs_path rel path 1(dir)" {
  cd /tmp/test/a/b/
  run get_abs_path c/d/
  assert_output /tmp/test/a/b/c/d
  assert_success
}

@test "get_abs_path rel path 2(dir)" {
  cd /tmp/test/a/b/
  run get_abs_path c/../../b/c/d/
  assert_output /tmp/test/a/b/c/d
  assert_success
}

@test "get_abs_path rel path 3(dir)" {
  cd /tmp/test/a/b/c/d
  run get_abs_path .
  assert_output /tmp/test/a/b/c/d
  assert_success
}

@test "get_abs_path rel path 4(dir)" {
  cd /tmp/test/a/b/c/d
  run get_abs_path ..
  assert_output /tmp/test/a/b/c
  assert_success
}

@test "get_abs_path rel path 5(dir)" {
  cd /tmp/test/a/b/c/d
  run get_abs_path ../
  assert_output /tmp/test/a/b/c
  assert_success
}

@test "get_abs_path rel path 6(dir)" {
  cd /tmp/test/a/b/c/d
  run get_abs_path ../../../../../../../
  assert_output /
  assert_success
}

@test "get_abs_path rel path 1(file)" {
  cd /tmp/test/a/b/
  run get_abs_path c/d/testfile
  assert_output /tmp/test/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path rel path 2(file)" {
  cd /tmp/test/a/b/
  run get_abs_path c/../../b/c/d/testfile
  assert_output /tmp/test/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path rel path 3(file)" {
  cd /tmp/test/a/b/c/d
  run get_abs_path ./testfile
  assert_output /tmp/test/a/b/c/d/testfile
  assert_success
}

@test "get_abs_path rel path 4(file)" {
  cd /tmp/test/a/b/c/d
  run get_abs_path ../../testfile
  assert_output /tmp/test/a/b/testfile
  assert_success
}

@test "get_abs_path when file not exist 1" {
  cd /tmp/test/a/b/c/d
  run get_abs_path file_not_exist
  assert_output -p "[✗] get_abs_path : /tmp/test/a/b/c/d/file_not_exist does not exists"
  assert_failure
}

@test "get_abs_path when file not exist 2" {
  cd /tmp/test/a/b/c/d
  run get_abs_path ../../file_not_exist
  assert_output -p "[✗] get_abs_path : /tmp/test/a/b/file_not_exist does not exists"
  assert_failure
}

@test "get_abs_path ask path pattern * " {
  cd /tmp/test/a/b/c/d
  run get_abs_path "*"
  assert_output -p "[✗] get_abs_path : /tmp/test/a/b/c/d/* does not exists"
  assert_failure
}

@test "get_abs_path ask symlink" {
  cd /tmp/test/a/b
  run get_abs_path c/d/symlink_testfile
  assert_output "/tmp/test/a/b/c/d/symlink_testfile"
  assert_success
}

@test "get_abs_path ask symlink is broken" {
  cd /tmp/test/a/b/c
  run get_abs_path "d/deadlink"
  assert_output "/tmp/test/a/b/c/d/deadlink"
  assert_success
}
@test "mkd with no args" {
  run mkd
  assert_output -p "[✗] mkd : need target_path"
  assert_failure
}

@test "mkd with 2 args" {
  run mkd a b
  assert_output -p "[✗] mkd : too many arguments"
  assert_failure
}

@test "mkd create directory from relative path" {
  cd /tmp/test/a/b/c/d
  run mkd ../../e
  assert_output -p "[✓] create directory : ../../e"
  assert_success
}

@test "mkd create directory from absolute path" {
  run mkd /tmp/test/a/b/c/d/e
  assert_output -p "[✓] create directory : /tmp/test/a/b/c/d/e"
  assert_success
}

@test "mkd when directory already exists" {
  run mkd /tmp/test/a/b/c/d
  assert_output -p "[i] directory already exists"
  assert_success
}

@test "mkd when file already exists" {
  run mkd /tmp/test/a/b/c/d/testfile
  assert_output -p "[✗] mkd : file with the same name already exists : /tmp/test/a/b/c/d/testfile"
  assert_failure
}

@test "mkd when mkdir failed (permission denied)" {
  run mkd /root/dir
  assert_output -p "[✗] mkd : create directory failed : /root/dir"
  assert_failure
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

#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  TEST_WORK_DIR="$(mktemp -d)"
}

teardown() {
  [[ -n "$TEST_WORK_DIR" ]] && rm -rf "$TEST_WORK_DIR"
}

@test "assert_output_contain_in_array output : blank, array : empty" {
  expect=()
  run assert_output_contain_in_array "echo -e \"\"" expect
  [[ "$status" == 0 ]]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output_contain_in_array output : a\0, array : empty" {
  expect=()
  run assert_output_contain_in_array "echo -e \"a\0\"" expect
  assert_failure
  assert_equal ${#lines[@]} 3
  assert_line -n 0 -p "output does not exist in expect"
  assert_line -n 1 -e "output\\s+:\\s+a"
}

@test "assert_output_contain_in_array output : blank, array : (a,b)" {
  expect=(a b)
  run assert_output_contain_in_array "echo -e \"\"" expect
  assert_failure
  assert_equal ${#lines[@]} 4
  assert_line -n 0 -p "several strings in expect are not output"
  assert_line -n 1 -e "value\\s+:\\s+a"
  assert_line -n 2 -e "value\\s+:\\s+b"
}

@test "assert_output_contain_in_array output : a\0b\0c\0, array : (a,c)" {
  expect=(a c)
  run assert_output_contain_in_array "echo -e \"a\0b\0c\0\"" expect
  assert_failure
  assert_equal ${#lines[@]} 3
  assert_line -n 0 -p "output does not exist in expect"
  assert_line -n 1 -e "output\\s+:\\s+b"
}

@test "assert_output_contain_in_array output : \"a b\"\0\"b\nc\"\0👹\0, array : (\"a b\",\"b\nc\",👹)" {
  expect=("a b" "b
c" "👹")
  run assert_output_contain_in_array "echo -e \"a b\0b\nc\0👹\0\"" expect
  assert_success
  assert_equal ${#lines[@]} 0
}

@test "assert_mock_output called_from : test" {
  mock_output="called from : test
parameters :
options : OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  run echo "$mock_output"
  run assert_mock_output 0 test
  assert_success
  assert_equal ${#lines[@]} 0
}

@test "assert_mock_output params : \"a\" \"b\" \"c d\"" {
  mock_output="called from : test
parameters : \"a\" \"b\" \"c d\"
options : OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  run echo "$mock_output"
  run assert_mock_output 0 test "a" "b" "c d"
  assert_success
  assert_equal ${#lines[@]} 0
}

@test "assert_mock_output options : OPT_DEBUG=true OPT_FORCE=false OPT_SKIP=true" {
  mock_output="called from : test
parameters :
options : OPT_DEBUG=true, OPT_FORCE=false, OPT_SKIP=true"
  run echo "$mock_output"
  run assert_mock_output -ds 0 test
  assert_success
  assert_equal ${#lines[@]} 0
}

@test "assert_mock_output options : OPT_DEBUG=false OPT_FORCE=true OPT_SKIP=false" {
  mock_output="called from : test
parameters :
options : OPT_DEBUG=false, OPT_FORCE=true, OPT_SKIP=false"
  run echo "$mock_output"
  run assert_mock_output -f 0 test
  assert_success
  assert_equal ${#lines[@]} 0
}

@test "assert_mock_output confirm long options" {
  mock_output="called from : test
parameters :
options : OPT_DEBUG=true, OPT_FORCE=true, OPT_SKIP=true"
  run echo "$mock_output"
  run assert_mock_output --debug --force --skip 0 test
  assert_success
  assert_equal ${#lines[@]} 0
}

@test "assert_mock_output invalid option" {
  run echo ""
  run assert_mock_output -z 0 test
  assert_failure
  assert_output -p "unknown option"
}

@test "assert_mock_output invalid long option" {
  run echo ""
  run assert_mock_output --invalid 0 test
  assert_failure
  assert_output -p "unknown option"
}

@test "assert_mock_output called_from : expect test actual func " {
  mock_output="called from : func
parameters :
options : OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  run echo "$mock_output"
  run assert_mock_output 0 test
  assert_failure
  assert_output -p "called from : test"
  assert_output -p "called from : func"
}

@test "assert_mock_output parameters : expect a b c actual d e" {
  mock_output="called from : test
parameters : \"d\" \"e\"
options : OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  run echo "$mock_output"
  run assert_mock_output 0 test "a" "b" "c"
  assert_failure
  assert_output -p "parameters : \"a\" \"b\" \"c\""
  assert_output -p "parameters : \"d\" \"e\""
}

@test "assert_mock_output options : expect OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false actual OPT_DEBUG=true, OPT_FORCE=false, OPT_SKIP=false" {
  mock_output="called from : test
parameters :
options : OPT_DEBUG=true, OPT_FORCE=false, OPT_SKIP=false"
  run echo "$mock_output"
  run assert_mock_output 0 test
  assert_failure
  assert_output -p "options : OPT_DEBUG=true, OPT_FORCE=false, OPT_SKIP=false"
  assert_output -p "options : OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
}

@test "assert_git_status file does not exist" {
  run assert_git_status /not_found "M "
  assert_failure
}

@test "assert_git_status expect : untracked, actual : added to index" {
  git init "$TEST_WORK_DIR"
  touch "$TEST_WORK_DIR/file"
  (
    cd "$TEST_WORK_DIR" || fail
    git add file
  )
  run assert_git_status "$TEST_WORK_DIR/file" "??"
  assert_failure
}

@test "assert_git_status expect : added to index, actual : untracked" {
  git init "$TEST_WORK_DIR"
  touch "$TEST_WORK_DIR/file"
  run assert_git_status "$TEST_WORK_DIR/file" "A "
  assert_failure
}

@test "assert_git_status expect : added to index, actual : added to index" {
  git init "$TEST_WORK_DIR"
  touch "$TEST_WORK_DIR/file"
  (
    cd "$TEST_WORK_DIR" || fail
    git add file
  )
  run assert_git_status "$TEST_WORK_DIR/file" "A "
  assert_success
}

@test "assert_git_status expect : untracked, actual : untracked" {
  git init "$TEST_WORK_DIR"
  touch "$TEST_WORK_DIR/file"
  run assert_git_status "$TEST_WORK_DIR/file" "??"
  assert_success
}

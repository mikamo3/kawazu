#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  source "$BATS_TEST_DIRNAME/../mock/mock.sh"
}

teardown() {
  :
}

@test "mock with no args" {
  run print_mock_info
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters :"
  assert_line -n 2 "options: OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  assert_success
}

@test "mock args: a" {
  run print_mock_info a
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters : \"a\""
  assert_line -n 2 "options: OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  assert_success
}

@test "mock args: a b" {
  run print_mock_info a b
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters : \"a\" \"b\""
  assert_line -n 2 "options: OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  assert_success
}

@test "mock args: a b \"aa b\<newline>cd\"" {
  run print_mock_info a b "aa b
cd"
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters : \"a\" \"b\" \"aa b"
  assert_line -n 2 "cd\""
  assert_line -n 3 "options: OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  assert_success
}

@test "mock args: a b \"aa b\<newline>cd\"" {
  run print_mock_info a b "aa b
cd"
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters : \"a\" \"b\" \"aa b"
  assert_line -n 2 "cd\""
  assert_line -n 3 "options: OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=false"
  assert_success
}

@test "mock options: OPT_DEBUG=true" {
  export OPT_DEBUG=true
  run print_mock_info
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters :"
  assert_line -n 2 "options: OPT_DEBUG=true, OPT_FORCE=false, OPT_SKIP=false"
  assert_success
}

@test "mock options: OPT_FORCE=true" {
  export OPT_FORCE=true
  run print_mock_info
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters :"
  assert_line -n 2 "options: OPT_DEBUG=false, OPT_FORCE=true, OPT_SKIP=false"
  assert_success
}

@test "mock options: OPT_SKIP=true" {
  export OPT_SKIP=true
  run print_mock_info
  assert_line -n 0 "called from : run"
  assert_line -n 1 "parameters :"
  assert_line -n 2 "options: OPT_DEBUG=false, OPT_FORCE=false, OPT_SKIP=true"
  assert_success
}

@test "mock args:contain fail" {
  run print_mock_info fail
  assert_output ""
  assert_failure
}

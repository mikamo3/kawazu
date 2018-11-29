#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/command_help.sh
}

teardown() {
  :
}

@test "command_help help" {
  run command_help
  assert_output -p "usage"
  assert_success
}

@test "command_help help add" {
  run command_help add
  assert_success
}

@test "command_help help init" {
  run command_help init
  assert_success
}

@test "command_help help clone" {
  run command_help clone
  assert_success
}

@test "command_help help link" {
  run command_help link
  assert_success
}

@test "command_help help unlink" {
  run command_help unlink
  assert_success
}

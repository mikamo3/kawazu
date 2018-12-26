#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/command_help.sh

@test "command_help help" {
  run command_help
  assert_output -p "usage"
  assert_success
}

@test "command_help help add" {
  run command_help add
  assert_success
}

@test "command_help help cd" {
  run command_help cd
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

@test "command_help help unknown command" {
  run command_help unknown_command
  assert_output -p "[✗] unknown command : unknown_command"
  assert_failure
}

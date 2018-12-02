#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env

source ${KAWAZU_ROOT_DIR}/lib/file.sh

@test "dot_slash /path return /path" {
  run dot_slash /path
  assert_output "/path"
}

@test "dot_slash path return ./path" {
  run dot_slash path
  assert_output "./path"
}

@test "dot_slash ./path return ./path" {
  run dot_slash ./path
  assert_output "./path"
}

@test "dot_slash .path return ./.path" {
  run dot_slash .path
  assert_output "./.path"
}

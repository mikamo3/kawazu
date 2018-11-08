#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup(){
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
}

@test "print_error" {
  run print_error message
  assert_output -p "[✗] message"
}

@test "print_success" {
  run print_success message
  assert_output -p "[✓] message"
}

@test "print_info" {
  run print_info message
  assert_output -p "[i] message"
}

@test "print_debug with debug flg is true" {
  export OPT_DEBUG=true
  run print_debug message
  assert_output -p "[debug] message"
}

@test "print_debug with debug flg is false" {
  export OPT_DEBUG=false
  run print_debug message
  assert_output -p ""
}

@test "print_version" {
  run print_version
  assert_output -p "kawazu version 0.1"
}

@test "print_question" {
  run print_question message
  assert_output -p "[?] message"
}

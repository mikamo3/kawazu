#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env
source ${KAWAZU_ROOT_DIR}/lib/console.sh

@test "print_error" {
  run print_error message
  assert_output -p "[✗] message"
}

@test "print_error with newline" {
  run print_error "message\nnewline"
  assert_line -n 0 -p "[✗] message"
  assert_line -n 1 -p "newline"

}
@test "print_success" {
  run print_success message
  assert_output -p "[✓] message"
}

@test "print_success with newline" {
  run print_success "message\nnewline"
  assert_line -n 0 -p "[✓] message"
  assert_line -n 1 -p "newline"
}

@test "print_info" {
  run print_info message
  assert_output -p "[i] message"
}

@test "print_info with newline" {
  run print_info "message\nnewline"
  assert_line -n 0 -p "[i] message"
  assert_line -n 1 -p "newline"
}

@test "print_debug with debug flg is true" {
  OPT_DEBUG=true
  run print_debug message
  assert_output -p "[debug] message"
}

@test "print_debug with debug flg is true with newline" {
  OPT_DEBUG=true
  run print_debug "message\nnewline"
  assert_line -n 0 -p "[debug] message"
  assert_line -n 1 -p "newline"
}


@test "print_debug with debug flg is false" {
  OPT_DEBUG=false
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

@test "print_question with newline" {
  run print_question "message\nnewline"
  assert_line -n 0 -p "[?] message"
  assert_line -n 1 -p "newline"
}

#!/usr/bin/env/bats
load ../helper
setup(){
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
}
@test "print_error" {
  run print_error message
  [[ $output =~ "[✗] message" ]]
}

@test "print_success" {
  run print_success message
  [[ $output =~ "[✓] message" ]]
}

@test "print_info" {
run print_info message
  [[ $output =~ "[i] message" ]]
}

@test "print_debug" {
  run print_debug message
  [[ $output =~ "[debug] message" ]]
}

@test "print_version" {
  run print_version
  [[ $output == "kawazu version 0.1" ]]
}

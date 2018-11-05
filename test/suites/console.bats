#!/usr/bin/env/bats
load ../helper
setup(){
    export_env
    source ${KAWAZU_ROOT_DIR}/lib/console.sh
}
@test "output console error" {
    result=$(print_error message)
    [[ $result =~ "[✗] message" ]]
}

@test "output console success" {
    result=$(print_success message)
    [[ $result =~ "[✓] message" ]]
}

@test "output console info" {
    result=$(print_info message)
    [[ $result =~ "[i] message" ]]
}

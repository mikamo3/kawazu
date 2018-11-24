#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  export_env
  expect_header="\r\n\u001b\[33m\[\?\]"
  expect_reset="\u001b\[0m"
  expect_prompt="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"
}

@test "question answer anwser to question" {
  run expect <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "question message\n"
    expect -ex "$expect_header message : $expect_reset" {} default {exit 1}
    send "answer\n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$REPLY\n"
    expect -ex "\r\nanswer\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success

}

@test "confirm answer y to confirm" {
  run expect <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "confirm message\n"
    expect -ex "$expect_header message (y/n) : " {} default {exit 1}
    send "y"
    expect -re "$expect_prompt" {} default {exit 1}
    send "confirm_is_yes\n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo $\?\n"
    expect -ex "\r\n0" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
}

@test "confirm answer n to confirm" {
  run expect <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "confirm message\n"
    expect -ex "$expect_header message (y/n) : " {} default {exit 1}
    send "n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "confirm_is_yes\n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo $\?\n"
    expect -ex "\r\n1" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
}

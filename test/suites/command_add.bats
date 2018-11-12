#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  source ${KAWAZU_ROOT_DIR}/lib/interactive.sh
  source ${KAWAZU_ROOT_DIR}/lib/command_add.sh
  create_dotfiles_git_repository
  create_home_directory

  #set homedir
  cd $HOME
  touch testfile
  mkdir test_dir
  touch test_dir/testfile
  touch /tmp/testfile
  ln -s deadlink
  ln -s testfile sym_testfile

  #for expect
  expect_interactive_header="\r\n\u001b\[33m\[\?\]"
  expect_info_header="\r\n\u001b\[36m\[i\]"
  expect_success_header="\r\n\u001b\[32m\[✓\]"
  expect_reset="\u001b\[0m"
  expect_prompt="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"
}

teardown() {
  delete_dotfiles_git_repository
  delete_home_directory
  rm /tmp/testfile
}

@test "command_add with no args" {
  run command_add
  assert_output -p "[✗] command_add : need filepath"
  assert_failure
}

@test "command_add when dotfiles repository does not found" {
  delete_dotfiles_git_repository
  run command_add testfile
  assert_output -p "[✗] /tmp/.dotfiles does not exist"
  assert_failure
}

@test "command_add when dotfiles is not git repository" {
  rm -rf $KAWAZU_DOTFILES_DIR/.git
  run command_add testfile
  assert_output -p "[✗] /tmp/.dotfiles is not git repository"
  assert_failure
}

@test "command_add when target file does not exist" {
  run command_add file_not_found
  assert_output -p "[✗] file_not_found does not exist"
  assert_failure
}

@test "command_add when target file is directory" {
  run command_add test_dir
  assert_output -p "[✗] test_dir is directory. Please specify a file."
  assert_failure
}

@test "command_add when target file is not included home directory" {
  cd /tmp
  run command_add testfile
  assert_output -p "[✗] testfile must be in your home directory"
  assert_failure
}

@test "command_add when target file is symlink and already managed by git (abs path)" {
  (cd $KAWAZU_DOTFILES_DIR && touch testfile && git add testfile && git commit -m "test")
  ln -sf $KAWAZU_DOTFILES_DIR/testfile testfile
  run command_add testfile
  assert_output -p "[i] testfile is already managed by git. skip"
  assert_failure
}

@test "command_add when target file is symlink and already managed by git (rel path)" {
  (cd $KAWAZU_DOTFILES_DIR && touch testfile && git add testfile && git commit -m "test")
  ln -sf ../../$KAWAZU_DOTFILES_DIR/testfile testfile
  run command_add testfile
  assert_output -p "[i] testfile is already managed by git. skip"
  assert_failure
}

@test "command_add no managed file (cur dir is home)" {
  run command_add testfile
  assert_line -n 0 -p "[i] add testfile → /tmp/.dotfiles/testfile"
  assert_line -n 1 -p "[✓] add complete testfile → /tmp/.dotfiles/testfile"
  assert $(cd /tmp/.dotfile && git status -s && grep "^A  testfile$")
  assert_success
}

@test "command_add no managed file (cur dir is home/test_dir)" {
  cd test_dir
  run command_add ../testfile
  assert_line -n 0 -p "[i] add ../testfile → /tmp/.dotfiles/testfile"
  assert_line -n 1 -p "[✓] add complete ../testfile → /tmp/.dotfiles/testfile"
  assert $(cd /tmp/.dotfile && git status -s && grep "^A  testfile$")
  assert_success
}

@test "command_add no managed file with dir (cur dir is home)" {
  run command_add test_dir/testfile
  assert_line -n 0 -p "[i] add test_dir/testfile → /tmp/.dotfiles/test_dir/testfile"
  assert_line -n 1 -p "[✓] add complete test_dir/testfile → /tmp/.dotfiles/test_dir/testfile"
  assert $(cd /tmp/.dotfile && git status -s && grep "^A  test_dir/testfile$")
  assert_success
}

@test "command_add no managed file with dir (cur dir is home/test_dir)" {
  cd test_dir
  run command_add testfile
  assert_line -n 0 -p "[i] add testfile → /tmp/.dotfiles/test_dir/testfile"
  assert_line -n 1 -p "[✓] add complete testfile → /tmp/.dotfiles/test_dir/testfile"
  assert $(cd /tmp/.dotfile && git status -s && grep "^A  test_dir/testfile$")
  assert_success
}

@test "command_add target file is link" {
  run command_add sym_testfile
  assert_line -n 0 -p "[i] add sym_testfile → /tmp/.dotfiles/sym_testfile"
  assert_line -n 1 -p "[✓] add complete sym_testfile → /tmp/.dotfiles/sym_testfile"
  assert $(cd /tmp/.dotfile && git status -s && grep "^A  sym_testfile$")
  assert_success
}
@test "command_add when target file is broken link" {
  run command_add deadlink
  assert_output -p "[✗] deadlink is broken symbolic link. skip"
  assert_failure
}

@test "command_add when managing files with the same name in git repository. answer is no" {
  (cd $KAWAZU_DOTFILES_DIR && touch testfile && git add testfile && git commit -m "test")
  run expect -d <<EOF
    log_file /tmp/exp
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send  "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_add.sh\n"
    send "command_add testfile\n"
    expect -ex "$expect_interactive_header /tmp/.dotfiles/testfile is already exist. do you want to overwrite? (y/n) : " {} default {exit 1}
    send "n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\r\n1\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
}

@test "command_add when managing files with the same name in git repository. answer is yes" {
  (cd $KAWAZU_DOTFILES_DIR && touch testfile && git add testfile && git commit -m "test")
  run expect -d <<EOF
    log_file /tmp/exp
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send  "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_add.sh\n"
    send "command_add testfile\n"
    expect -ex "$expect_interactive_header /tmp/.dotfiles/testfile is already exist. do you want to overwrite? (y/n) : " {} default {exit 1}
    send "y"
    expect -ex "$expect_success_header add complete testfile → /tmp/.dotfiles/testfile" {} default {exit 1}
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\r\n0\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
}

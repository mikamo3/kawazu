#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  source ${KAWAZU_ROOT_DIR}/lib/interactive.sh
  source ${KAWAZU_ROOT_DIR}/lib/command_add.sh
  create_git_repository
  create_test_files "$HOME"

  #for expect
  expect_interactive_header="\r\n\u001b\[33m\[\?\]"
  expect_info_header="\r\n\u001b\[36m\[i\]"
  expect_success_header="\r\n\u001b\[32m\[✓\]"
  expect_reset="\u001b\[0m"
  expect_prompt="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"
  git_add_unsuitable_file_path="path/to/-newline\\\\n\
dir \\\\360\\\\237\\\\221\\\\271\\*/-newline\\\\n\
file \\\\360\\\\237\\\\221\\\\271\\*"
  cd "$HOME"
}

teardown() {
  delete_test_dir
}

@test "command_add with no args" {
  run command_add
  # FIXME: print help
  assert_output -p "[✗] "
  assert_failure
}

@test "command_add dotfiles dir does not exist" {
  rm -rf "$KAWAZU_DOTFILES_DIR"
  run command_add test
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR does not exist"
  assert_failure
}

@test "command_add dotfiles is not git repository" {
  rm -rf "$KAWAZU_DOTFILES_DIR/.git"
  run command_add test
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR is not git repository"
  assert_failure
}

@test "command_add target file does not exist" {
  run command_add file_not_found
  assert_output -p "[✗] file_not_found does not exist"
  assert_failure
}

@test "command_add target file is directory" {
  run command_add path
  assert_output -p "[✗] path is directory. Please specify a file."
  assert_failure
}

@test "command_add target file is not included home directory" {
  cd "$TEST_WORK_DIR"
  run command_add file
  assert_output -p "[✗] file must be in your home directory"
  assert_failure
}

@test "command_add target file already managed by git (link is abs path)" {
  git_add_file "file"
  ln -sf $KAWAZU_DOTFILES_DIR/file file
  run command_add file
  assert_output -p "[i] file is already managed by git. skip"
  assert_failure
}

@test "command_add target file already managed by git (link is rel path)" {
  git_add_file "file"
  ln -sf ../../.dotfiles/file file
  run command_add file
  assert_output -p "[i] file is already managed by git. skip"
  assert_failure
}

@test "command_add no managed file (cur dir is home)" {
  run command_add file
  assert_line -n 0 -p "[i] add file → $KAWAZU_DOTFILES_DIR/file"
  assert_line -n 1 -p "[✓] add complete file → $KAWAZU_DOTFILES_DIR/file"
  assert git_get_file_status "file" "A"
  assert_success
}

@test "command_add no managed file (cur dir is home/path)" {
  cd path
  run command_add ../file
  assert_line -n 0 -p "[i] add ../file → $KAWAZU_DOTFILES_DIR/file"
  assert_line -n 1 -p "[✓] add complete ../file → $KAWAZU_DOTFILES_DIR/file"
  assert git_get_file_status "file" "A"
  assert_success
}

@test "command_add no managed file (specify an abs path)" {
  run command_add "$HOME/file"
  assert_line -n 0 -p "[i] add $HOME/file → $KAWAZU_DOTFILES_DIR/file"
  assert_line -n 1 -p "[✓] add complete $HOME/file → $KAWAZU_DOTFILES_DIR/file"
  assert git_get_file_status "file" "A"
  assert_success
}

@test "command_add no managed file with dir (cur dir is home)" {
  run command_add path/to/dir/file
  assert_line -n 0 -p "[i] add path/to/dir/file → $KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_line -n 1 -p "[✓] add complete path/to/dir/file → $KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert git_get_file_status "path/to/dir/file" "A"
  assert_success
}

@test "command_add no managed file with dir (cur dir is home/path/to/dir)" {
  cd path/to/dir
  run command_add file
  assert_line -n 0 -p "[i] add file → $KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_line -n 1 -p "[✓] add complete file → $KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert git_get_file_status "path/to/dir/file" "A"
  assert_success
}
@test "command_add no managed file with dir (specify an abs path)" {
  run command_add "$HOME/path/to/dir/file"
  assert_line -n 0 -p "[i] add $HOME/path/to/dir/file → $KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_line -n 1 -p "[✓] add complete $HOME/path/to/dir/file → $KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert git_get_file_status "path/to/dir/file" "A"
  assert_success
}

@test "command_add target file is symlink" {
  run command_add path/to/symlink_dir/rel_symlink
  assert_line -n 0 -p "[i] add path/to/symlink_dir/rel_symlink → $KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_symlink"
  assert_line -n 1 -p "[✓] add complete path/to/symlink_dir/rel_symlink → $KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_symlink"
  assert git_get_file_status "path/to/symlink_dir/rel_symlink" "A"
  assert_success
}

@test "command_add target file is broken link" {
  skip "to fix allow add a broken symlink"
  run command_add path/to/symlink_dir/broken_symlink
  assert_line -n 0 -p "[i] add path/to/symlink_dir/broken_symlink → $KAWAZU_DOTFILES_DIR/path/to/symlink_dir/broken_symlink"
  assert_line -n 1 -p "[✓] add complete path/to/symlink_dir/broken_symlink → $KAWAZU_DOTFILES_DIR/path/to/symlink_dir/broken_symlink"
  assert git_get_file_status "path/to/symlink_dir/broken_symlink" "A"
  assert_success
}

@test "command_add when managing files with the same name in git repository. answer is no" {
  git_add_file "file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_add.sh\n"
    send "command_add file\n"
    expect -ex "$expect_interactive_header $KAWAZU_DOTFILES_DIR/file is already exist. do you want to overwrite? (y/n) : " {} default {exit 1}
    send "n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\r\n1\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
}

@test "command_add when managing files with the same name in git repository. answer is yes" {
  git_add_file "file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send  "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_add.sh\n"
    send "command_add file\n"
    expect -ex "$expect_interactive_header $KAWAZU_DOTFILES_DIR/file is already exist. do you want to overwrite? (y/n) : " {} default {exit 1}
    send "y"
    expect -ex "$expect_success_header add complete file → $KAWAZU_DOTFILES_DIR/file" {} default {exit 1}
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\r\n0\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
}

@test "command_add target file path contain unsuitable character (cur dir is home)" {
  run command_add "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_line -n 0 -p "[i] add path/to/-newline"
  assert_line -n 1 -p "dir $(emoji)*/-newline"
  assert_line -n 2 -p "file $(emoji)* → $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 3 -p "dir $(emoji)*/-newline"
  assert_line -n 4 -p "file $(emoji)*"
  assert_line -n 5 -p "[✓] add complete path/to/-newline"
  assert_line -n 6 -p "dir $(emoji)*/-newline"
  assert_line -n 7 -p "file $(emoji)* → $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 8 -p "dir $(emoji)*/-newline"
  assert_line -n 9 -p "file $(emoji)*"
  assert_success
  assert git_get_file_status "$git_add_unsuitable_file_path" "A"
}

@test "command_add target file path contain unsuitable character (cur dir is target file dir)" {
  cd "path/to/-newline
dir $(emoji)*"
  run command_add "-newline
file $(emoji)*"
  assert_success
  assert git_get_file_status "$git_add_unsuitable_file_path" "A"
}

@test "command_add target file path contain unsuitable character and already managed (cur dir is home)" {
  git_add_file "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  run command_add "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*" < <(echo y)
  assert_line -n 0 -p "[i] add path/to/-newline"
  assert_line -n 1 -p "dir $(emoji)*/-newline"
  assert_line -n 2 -p "file $(emoji)* → $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 3 -p "dir $(emoji)*/-newline"
  assert_line -n 4 -p "file $(emoji)*"
  assert_line -n 5 -p "[?] $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 6 -p "dir $(emoji)*/-newline"
  assert_line -n 7 -p "file $(emoji)* is already exist. do you want to overwrite? (y/n) : "
  assert_line -n 8 -p "[✓] add complete path/to/-newline"
  assert_line -n 9 -p "dir $(emoji)*/-newline"
  assert_line -n 10 -p "file $(emoji)* → $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 11 -p "dir $(emoji)*/-newline"
  assert_line -n 12 -p "file $(emoji)*"
  assert_success
  assert git_get_file_status "$git_add_unsuitable_file_path" "A"
}

@test "command_add target file path contain unsuitable character and already managed (cur dir is target file dir)" {
  cd "path/to/-newline
dir $(emoji)*"
  run command_add "-newline
file $(emoji)*" < <(echo y)
  assert_success
  assert git_get_file_status "$git_add_unsuitable_file_path" "A"
}

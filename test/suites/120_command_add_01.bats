#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env
load ../fixtures/git

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/file.sh
source ${KAWAZU_ROOT_DIR}/lib/git.sh
source ${KAWAZU_ROOT_DIR}/lib/interactive.sh
source ${KAWAZU_ROOT_DIR}/lib/command_add.sh

source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh
source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh

#for expect
EXPECT_INTERACTIVE_HEADER="\r\n\u001b\[33m\[\?\]"
EXPECT_INFO_HEADER="\r\n\u001b\[36m\[i\]"
EXPECT_SUCCESS_HEADER="\r\n\u001b\[32m\[✓\]"
EXPECT_RESET="\u001b\[0m"
EXPECT_PROMPT="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"

UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

setup() {
  create_local_git_repository "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
  cd "$HOME"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.worktree
#   does not exist
#   is not git worktree
# 3.target path
#   is file
#   is file inside directory
#   does not exist
#   is directory
#   is file that does not in home directory
#   is symbolic link
#     to worktree file
#       abs path
#       rel path
#     not to worktree file
#     broken link
#   contain unsuitable character
#   was already exist in worktree and overwrite
#   was already exist in worktree and skip
#   is ignored file

@test "command_add run with no args" {
  run command_add
  assert_failure
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "add"
}

@test "command_add worktree does not exist" {
  rm -rf "$KAWAZU_DOTFILES_DIR"
  run command_add test
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR is not git worktree"
  assert_failure
}

@test "command_add worktree worktree is not git worktree" {
  rm -rf "$KAWAZU_DOTFILES_DIR/.git"
  run command_add test
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR is not git worktree"
  assert_failure
}

@test "command_add target path is file" {
  touch "$HOME/file"
  run command_add file
  assert_line -n 0 -p "[✓] add complete file → $KAWAZU_DOTFILES_DIR/file"
  assert_success
  assert_file_not_exist "$HOME/file"
  assert_git_status "$KAWAZU_DOTFILES_DIR/file" "A "
}

@test "command_add target path is file inside directory" {
  mkdir -p "$HOME/path/to/dir"
  touch "$HOME/path/to/dir/file"
  run command_add "path/to/dir/file"
  assert_success
  assert_file_not_exist "$HOME/path/to/dir/file"
  assert_git_status "$KAWAZU_DOTFILES_DIR/path/to/dir/file" "A "
}

@test "command_add target path does not exist" {
  run command_add "$HOME/not_found"
  assert_failure
  assert_output -p "[✗] $HOME/not_found does not exist"
}

@test "command_add target path is directory" {
  mkdir -p "$HOME/path"
  run command_add "$HOME/path"
  assert_failure
  assert_output -p "[✗] $HOME/path is directory. Please specify a file."
}

@test "command_add target path is file that does not in home directory" {
  touch "$TEST_WORK_DIR/file"
  run command_add "$TEST_WORK_DIR/file"
  assert_failure
  assert_output -p "[✗] $TEST_WORK_DIR/file must be in your home directory"
}

@test "command_add target path is symlink to worktree file (abs path)" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  mkdir -p "$HOME/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  ln -s "$KAWAZU_DOTFILES_DIR/path/to/dir/file" "$HOME/path/to/dir/file"
  run command_add "$HOME/path/to/dir/file"
  assert_failure
  assert_output -p "[i] $HOME/path/to/dir/file is already managed by git. skip"
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
}

@test "command_add target path is symlink to worktree file (rel path)" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  mkdir -p "$HOME/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  ln -s "../../../../../.dotfiles/path/to/dir/file" "$HOME/path/to/dir/file"
  run command_add "$HOME/path/to/dir/file"
  assert_failure
  assert_output -p "[i] $HOME/path/to/dir/file is already managed by git. skip"
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "../../../../../.dotfiles/path/to/dir/file"
}

@test "command_add target path is symlink not to worktree file" {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  touch "$TEST_WORK_DIR/path/to/dir/file"
  ln -s "$TEST_WORK_DIR/path/to/dir/file" "$HOME/link"
  run command_add "$HOME/link"
  assert_success
  assert_git_status "$KAWAZU_DOTFILES_DIR/link" "A "
  assert_equal "$(readlink "$KAWAZU_DOTFILES_DIR/link")" "$TEST_WORK_DIR/path/to/dir/file"
}

@test "command_add target path is broken link" {
  ln -s "/not_found" "$HOME/link"
  run command_add "$HOME/link"
  assert_success
  assert_git_status "$KAWAZU_DOTFILES_DIR/link" "A "
  assert_equal "$(readlink "$KAWAZU_DOTFILES_DIR/link")" "/not_found"
}

@test "command_add target path contain unsuitable character" {
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    mkdir -p "$HOME/$i"
    touch "$HOME/$i/$i"
  done

  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run command_add "$HOME/$i/$i"
    assert_success
    assert_git_status "$KAWAZU_DOTFILES_DIR/$i/$i" "A "
  done
}

@test "command_add target file was already exist in worktree and overwrite" {
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file"
  git_commit "$KAWAZU_DOTFILES_DIR/file"
  echo "home file" > "$HOME/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_add.sh\n"
    send "command_add file\n"
    expect -ex "$EXPECT_INTERACTIVE_HEADER $KAWAZU_DOTFILES_DIR/file is already exist. do you want to overwrite? (y/n) : " {} default {exit 1}
    send "y"
    expect -ex "$EXPECT_SUCCESS_HEADER add complete file → $KAWAZU_DOTFILES_DIR/file" {} default {exit 1}
    expect -re "$EXPECT_PROMPT" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\r\n0\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_git_status "$KAWAZU_DOTFILES_DIR/file" "M "
  assert_equal "$(cat $KAWAZU_DOTFILES_DIR/file)" "home file"
}

@test "command_add target file was already exist in worktree and skip" {
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file"
  git_commit "$KAWAZU_DOTFILES_DIR/file"
  echo "home file" > "$HOME/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_add.sh\n"
    send "command_add file\n"
    expect -ex "$EXPECT_INTERACTIVE_HEADER $KAWAZU_DOTFILES_DIR/file is already exist. do you want to overwrite? (y/n) : " {} default {exit 1}
    send "n"
    expect -re "$EXPECT_PROMPT" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\r\n1\r\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_equal "$(cat $KAWAZU_DOTFILES_DIR/file)" "git file"
}

@test "command_add target file is ignored file"  {
  echo "file" > "$KAWAZU_DOTFILES_DIR/.gitignore"
  touch "$HOME/file"
  run command_add "$HOME/file"
  assert_failure
  assert_output -p "[✗] "
  assert_file_not_exist "$KAWAZU_DOTFILES_DIR/file"
  assert_file_exist "$HOME/file"
}

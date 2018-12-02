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
source ${KAWAZU_ROOT_DIR}/lib/command_unlink.sh

source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh
source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh

UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

setup() {
  create_local_git_repository "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file_a"
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file_b"
  echo "git file" > "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_commit "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
  cd "$HOME"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.run with no arguments
#   home directory is empty
#   symlink that link to worktree file exists
#   worktree file that does not linked from home directory exist
#   with same name file exists at home directory
#   with same name symlink that link is broken exists at home directory
#   contain unsuitable character
# 3.run with argument
#   target path is worktree file
#   target path does not exist

@test "command_unlink run with 2 args" {
  run command_unlink a b
  assert_failure
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "unlink"
}
@test "command_unlink run with no args when home dir is empty" {
  run command_unlink
  assert_success
  assert_equal "$(find ./ -type f)" ""
}

@test "command_unlink run with no args symlink that link to worktree file contain at home directory" {
  mkdir -p "$HOME/path/to/dir"
  ln -s "$KAWAZU_DOTFILES_DIR/file_a" "$HOME/file_a"
  ln -s "$KAWAZU_DOTFILES_DIR/path/to/dir/file" "$HOME/path/to/dir/file"
  run command_unlink
  assert_success
  assert [ -f "$HOME/file_a" ]
  assert [ -f "$HOME/path/to/dir/file" ]
  assert_file_not_exist "$HOME/file_b"
}

@test "command_unlink run with no args with same name file exists at home directory" {
  echo "home file" > "$HOME/file_b"
  run command_unlink
  assert_success
  assert_equal "$(cat "$HOME/file_b")" "home file"
}

@test "command_unlink run with no args with same name symlink that link is broken exists at home directory" {
  ln -s "/not_found" "$HOME/file_b"
  run command_unlink
  assert_success
  assert_equal "$(readlink "$HOME/file_b")" "/not_found"
}

@test "command_unlink run with no args path contain unsuitable character" {
  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    mkdir -p "$KAWAZU_DOTFILES_DIR/$i"
    touch "$KAWAZU_DOTFILES_DIR/$i/$i"
    mkdir -p "$HOME/$i"
    ln -s "$KAWAZU_DOTFILES_DIR/$i/$i" "$HOME/$i/$i"
  done
  git_commit "$KAWAZU_DOTFILES_DIR"

  run command_unlink
  assert_success

  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    assert [ -f "$HOME/$i/$i" ]
  done
}

@test "command_unlink target path is worktree file" {
  ln -s "$KAWAZU_DOTFILES_DIR/file_a" "$HOME/file_a"
  run command_unlink "$HOME/file_a"
  assert_success
  assert [ -f "$HOME/file_a" ]
}

@test "command_unlink target path does not exist" {
  ln -s "/not_found" "$HOME/file_a"
  run command_unlink "$HOME/file_a"
  assert_failure
}

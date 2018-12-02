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
# 2.target path
#   does not exist
#   is file
#   is symlink not to a file in worktree
#   is broken link
#   is a symlink to the file in worktree
#     different directory structure
#     not in home directory
#     absolute path
#     relative path
#        $HOME/link
#        $HOME/path/to/dir/link
#     file does not exist in worktree
#     contain unsuitable character

UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

@test "_do_unlink run with no args" {
  run _do_unlink
  assert_failure
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "unlink"
}

@test "_do_unlink target path does not exist" {
  run _do_unlink not_found
  assert_failure
  assert_output -p "[✗] not_found does not exist"
}

@test "_do_unlink target path is file" {
  touch "$HOME/file"
  run _do_unlink "$HOME/file"
  assert_failure
  assert_output -p "[✗] $HOME/file is not symlink"
}

@test "_do_unlink target path is symlink not to a file in worktree" {
  touch "$HOME/file"
  ln -s "$HOME/file" "$HOME/link"
  run _do_unlink "$HOME/link"
  assert_failure
  assert_output -p "[✗] $HOME/link is not dotfiles link"
}

@test "_do_unlink target path is broken link" {
  ln -s "/not_found" "$HOME/link"
  run _do_unlink "$HOME/link"
  assert_failure
  assert_output -p "[✗] link destination of $HOME/link does not exist"
}

@test "_do_unlink target path is outside \$HOME and is a symlink to the file in worktree" {
  touch "$KAWAZU_DOTFILES_DIR/file"
  ln -s "$KAWAZU_DOTFILES_DIR/file" "$TEST_WORK_DIR/link"
  run _do_unlink "$TEST_WORK_DIR/link"
  assert_failure
  assert_output -p "$TEST_WORK_DIR/link is outside home directory"
}

@test "_do_unlink target path is in the \$HOME and is a symlink to the file in worktree (abs path)" {
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file"
  ln -s "$KAWAZU_DOTFILES_DIR/file" "$HOME/link"
  run _do_unlink "$HOME/link"
  assert_success
  assert_output -p "[✓] unlink complete $HOME/link"
  assert [ -f "$HOME/link" ]
  assert_equal "$(cat $HOME/link)" "git file"
}

@test "_do_unlink target path is in the \$HOME and is a symlink to the file in worktree (rel path)" {
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file"
  ln -s "../../.dotfiles/file" "$HOME/link"
  run _do_unlink "$HOME/link"
  assert_success
  assert_output -p "[✓] unlink complete $HOME/link"
  assert [ -f "$HOME/link" ]
  assert_equal "$(cat $HOME/link)" "git file"
}

@test "_do_unlink target path is in the \$HOME/path/to/dir and is a symlink to the file in worktree (rel path)" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  echo "git file" > "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  mkdir -p "$HOME/path/to/dir"
  ln -s "../../../../../.dotfiles/path/to/dir/file" "$HOME/path/to/dir/link"
  run _do_unlink "$HOME/path/to/dir/link"
  assert_success
  assert_output -p "[✓] unlink complete $HOME/path/to/dir/link"
  assert [ -f "$HOME/path/to/dir/link" ]
  assert_equal "$(cat $HOME/path/to/dir/link)" "git file"
}

@test "_do_unlink target path is in the \$HOME and is a symlink to the file in worktree. but file does not exist" {
  ln -s "$KAWAZU_DOTFILES_DIR/not_found" "$HOME/link"
  run _do_unlink "$HOME/link"
  assert_failure
  assert_output -p "[✗] link destination of $HOME/link does not exist"
}

@test "_do_unlink target path contain unsuitable caracter" {
  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    mkdir -p "$KAWAZU_DOTFILES_DIR/$i"
    touch "$KAWAZU_DOTFILES_DIR/$i/$i"
    mkdir -p "$HOME/$i"
    ln -s "../../../.dotfiles/$i/$i" "$HOME/$i/$i"
  done

  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    run _do_unlink "$HOME/$i/$i"
    assert_success
    assert_output -p "[✓] unlink complete $HOME/$i/$i"
    assert [ -f "$HOME/$i/$i" ]
  done
}

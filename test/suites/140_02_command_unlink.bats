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
  source ${KAWAZU_ROOT_DIR}/lib/git.sh
  source ${KAWAZU_ROOT_DIR}/lib/command_unlink.sh
  create_git_repository
  create_test_files "$KAWAZU_DOTFILES_DIR"
  (cd "$KAWAZU_DOTFILES_DIR" && git add -A)

  cd "$HOME"
}

teardown() {
  delete_test_dir
}

@test "command_unlink with no args when home dir is empty" {
  run command_unlink
  assert_success
  assert_equal "$(find ./ -type f)" ""
}

@test "command_unlink specify path is dotfiles root file" {
  ln -s "../../.dotfiles/file" "file"
  run command_unlink "file"
  assert_success
  echo "$output"
  assert [ -f "file" ]
}

@test "command_unlink with no args when home dir contain dotfiles symlink" {
  mkdir -p "path/to/dir"
  mkdir -p "path/to/dir2"
  mkdir -p "path/to/symlink_dir"
  mkdir -p "path/to/symlink_dir/-newline
dir $(emoji)*"
  mkdir -p "path/to/-newline
dir $(emoji)*"
  ln -s "${KAWAZU_DOTFILES_DIR}/file" "file"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/file" "path/to/file"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/dir/file" "path/to/dir/file"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*" "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/symlink_dir/rel_symlink" "path/to/symlink_dir/rel_symlink"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/symlink_dir/rel_dir_symlink" "path/to/symlink_dir/rel_dir_symlink"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/symlink_dir/broken_symlink" "path/to/symlink_dir/broken_symlink"
  ln -s "${KAWAZU_DOTFILES_DIR}/path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink" "path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink"
  run command_unlink
  assert_success
  assert [ -f "file" ]
  assert [ -f "path/to/file" ]
  assert [ -f "path/to/dir/file" ]
  assert [ -f "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*" ]
  assert [ -L "path/to/symlink_dir/rel_symlink" ]
  assert [ -L "path/to/symlink_dir/rel_dir_symlink" ]
  assert [ -L "path/to/symlink_dir/broken_symlink" ]
  assert [ -L "path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink" ]
}

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
  source ${KAWAZU_ROOT_DIR}/lib/command_link.sh
  create_git_repository
  create_test_files "$KAWAZU_DOTFILES_DIR"
  (cd "$KAWAZU_DOTFILES_DIR" && git add -A)

  #for backup dir name
  now_date=$(date +%Y%m%d)
  relpath_to_dotfiles_dir="../../.dotfiles"
  #for expect
  expect_interactive_header="\r\n\u001b\[33m\[\?\]"
  expect_info_header="\r\n\u001b\[36m\[i\]"
  expect_success_header="\r\n\u001b\[32m\[✓\]"
  expect_reset="\u001b\[0m"
  expect_prompt="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"

  cd "$HOME"
}

@test "command_link with no args" {
  run command_link
  assert "$(readlink "file")" "$relpath_to_dotfiles_dir/file"
  assert "$(readlink "path/to/dir/file")" "../../../$relpath_to_dotfiles_dir/path/to/dir/file"
  assert "$(readlink "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*")" "../../../$relpath_to_dotfiles_dir/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert "$(readlink "path/to/symlink_dir/rel_symlink")" "../../../$relpath_to_dotfiles_dir/path/to/symlink_dir/rel_symlink"
  assert "$(readlink "path/to/symlink_dir/broken_symlink")" "../../../$relpath_to_dotfiles_dir/path/to/symlink_dir/broken_symlink"
  assert "$(readlink "path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink")" "../../../$relpath_to_dotfiles_dir/path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink"
  assert_success
}

@test "command_link specify target_path" {
  run command_link "file"
  assert "$(readlink "file")" "$relpath_to_dotfiles_dir/file"
  assert_success
}

@test "command_link specify target_path and file with the same name exist" {
  touch file
  run command_link "file" < <(echo y)
  assert "$(readlink "file")" "$relpath_to_dotfiles_dir/file"
  assert_success
}

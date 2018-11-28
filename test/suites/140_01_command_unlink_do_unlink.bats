#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
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

@test "_do_unlink with no args" {
  run _do_unlink
  assert_output -p "[✗] need target_path"
  assert_failure
}

@test "_do_unlink specify path does not exist" {
  run _do_unlink "path_not_found"
  assert_output -p "[✗] path_not_found does not exist"
  assert_failure
}

@test "_do_unlink specify path is file" {
  touch "file"
  run _do_unlink "file"
  assert_output -p "[✗] file is not symlink"
  assert_failure
}

@test "_do_unlink specify path is not dotfiles link" {
  touch "file"
  ln -s "file" "symlink"
  run _do_unlink "symlink"
  assert_output -p "[✗] symlink is not dotfiles link"
  assert_failure
}

@test "_do_unlink specify path is broken link in dotfiles dir" {
  ln -s "$KAWAZU_DOTFILES_DIR/path/file_not_found" "symlink"
  run _do_unlink "symlink"
  assert_output -p "[✗] symlink is not dotfiles link"
  assert_failure
}

@test "_do_unlink specify path is dotfiles root file abs link" {
  echo "test" > "$KAWAZU_DOTFILES_DIR/file"
  ln -s "$KAWAZU_DOTFILES_DIR/file" "file"
  run _do_unlink "file"
  assert_line -n 0 -p "[✓] unlink complete file"
  assert_success
  assert [ -f "file" ]
  assert_equal "$(cat file)" "test"
}

@test "_do_unlink specify path is dotfiles root file rel link" {
  echo "test" > "$KAWAZU_DOTFILES_DIR/file"
  ln -s "../../.dotfiles/file" "file"
  run _do_unlink "file"
  assert_line -n 0 -p "[✓] unlink complete file"
  assert_success
  assert [ -f "file" ]
  assert_equal "$(cat file)" "test"
}

@test "_do_unlink specify path is dotfiles link" {
  ln -s "../../.dotfiles/path/to/symlink_dir/rel_symlink" "rel_symlink"
  run _do_unlink "rel_symlink"
  assert_line -n 0 -p "[✓] unlink complete rel_symlink"
  assert_success
  assert [ -L "rel_symlink" ]
  assert_equal "$(readlink "rel_symlink")" "../file"
}

@test "_do_unlink specify path is dotfiles broken link" {
  ln -s "../../.dotfiles/path/to/symlink_dir/broken_symlink" "broken_symlink"
  run _do_unlink "broken_symlink"
  assert_line -n 0 -p "[✓] unlink complete broken_symlink"
  assert_success
  assert [ -L "broken_symlink" ]
  assert_equal "$(readlink "broken_symlink")" "/not_exist_file"
}

@test "_do_unlink specify path contain unsuitable character" {
  mkdir -p "./path/to/-newline
dir $(emoji)*"
  echo "test" > "$KAWAZU_DOTFILES_DIR/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  ln -s "$KAWAZU_DOTFILES_DIR/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*" "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  run _do_unlink "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_success
  assert_line -n 0 -p "[✓] unlink complete path/to/-newline"
  assert_line -n 1 -p "dir $(emoji)*/-newline"
  assert_line -n 2 -p "file $(emoji)*"
  assert [ -f "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*" ]
  assert_equal "$(cat "path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*")" "test"
}

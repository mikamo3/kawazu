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
  create_local_git_bare_repository
  git clone --recurse-submodules "$BARE_REPOS_DIR" "$KAWAZU_DOTFILES_DIR"
  (
    cd "$KAWAZU_DOTFILES_DIR" || return 1
    git add -A
    touch unmanaged_file
  )
}

teardown() {
  delete_test_dir
}

@test "list_git_managed_files with no args" {
  run list_git_managed_files
  assert_output -p "[✗] list_git_managed_files : need repository_path"
  assert_failure
}

@test "list_git_managed_files repository_path is not git worktree" {
  run list_git_managed_files "$TEST_WORK_DIR"
  assert_output -p "[✗] list_git_managed_files : $TEST_WORK_DIR is not git worktree"
  assert_failure
}

@test "list_git_managed_files repository_path exists" {
  run list_git_managed_files "$KAWAZU_DOTFILES_DIR"
  assert_line -n 0 -p "$KAWAZU_DOTFILES_DIR/path/to/-newline\ndir \360\237\221\271*/-newline\nfile \360\237\221\271*"
  assert_line -n 1 -p "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/-newline\ndir \360\237\221\271*/-newline\nfile \360\237\221\271* rel_symlink"
  assert_line -n 2 -p "$KAWAZU_DOTFILES_DIR/file"
  assert_line -n 3 -p "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_line -n 4 -p "$KAWAZU_DOTFILES_DIR/path/to/file"
  assert_line -n 5 -p "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/broken_symlink"
  assert_line -n 6 -p "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_dir_symlink"
  assert_line -n 7 -p "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_symlink"
  assert_success
}
@test "list_git_managed_files repository_path is empty" {
  (
    cd "$KAWAZU_DOTFILES_DIR" || return 1
    rm -rf "./*"
    git init
  )
  run list_git_managed_files "$KAWAZU_DOTFILES_DIR"
  assert_output ""
  assert_success
}

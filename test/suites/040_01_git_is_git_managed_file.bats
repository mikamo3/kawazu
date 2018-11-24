#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/git.sh
  create_local_git_bare_repository
  git clone "$BARE_REPOS_DIR" "$KAWAZU_DOTFILES_DIR"
  (
    cd "$KAWAZU_DOTFILES_DIR" || return 1
    git add -A
    touch unmanaged_file
  )
}

teardown() {
  delete_test_dir
}

@test "is_git_managed_file with no args" {
  run is_git_managed_file
  assert_output -p "[✗] is_git_managed_file : need target_path"
  assert_failure
}

@test "is_git_managed_file target file is unmanaged" {
  run is_git_managed_file "$KAWAZU_DOTFILES_DIR/unmanaged_file"
  assert_output ""
  assert_failure
}

@test "is_git_managed_file target file's dir is unmanaged" {
  run is_git_managed_file "$TEST_WORK_DIR/file"
  assert_output ""
  assert_failure
}

@test "is_git_managed_file target is dir" {
  run is_git_managed_file "$KAWAZU_DOTFILES_DIR"
  assert_output
  assert_failure
}

@test "is_git_managed_file target is submodule file" {
  run is_git_managed_file "$KAWAZU_DOTFILES_DIR/submodule/file"
  assert_success
}

@test "is_git_managed_file target is file" {
  run is_git_managed_file "$KAWAZU_DOTFILES_DIR/file"
  assert_success
}

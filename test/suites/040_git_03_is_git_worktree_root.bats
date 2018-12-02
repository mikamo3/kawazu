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

GIT_WORKTREE_DIR="$TEST_WORK_DIR/worktree"

setup() {
  create_local_git_repository "$GIT_WORKTREE_DIR"
  cd "$TEST_WORK_DIR"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.target_path
#   does not exist
#   file
#   empty directory
#   worktree
#   directory inside worktree

@test "is_git_worktree_root run with no arguments" {
  run is_git_worktree_root
  assert_failure
  assert_output -p "[✗] is_git_worktree_root : need target_path"
}

@test "is_git_worktree_root run with 2 arguments" {
  run is_git_worktree_root a b
  assert_failure
  assert_output -p "[✗] is_git_worktree_root : need target_path"
}

@test "is_git_worktree_root target_path does not exist" {
  run is_git_worktree_root "/not_found"
  assert_failure
  assert_output -p "[✗] is_git_worktree_root : /not_found does not directory"
}

@test "is_git_worktree_root target_path is file" {
  touch "$TEST_WORK_DIR/file"
  run is_git_worktree_root "$TEST_WORK_DIR/file"
  assert_output -p "[✗] is_git_worktree_root : $TEST_WORK_DIR/file does not directory"
}

@test "is_git_worktree_root target path is empty directory" {
  mkdir -p "$TEST_WORK_DIR/directory"
  run is_git_worktree_root "$TEST_WORK_DIR/directory"
  assert_failure
}

@test "is_git_worktree_root target path is worktree" {
  run is_git_worktree_root "$GIT_WORKTREE_DIR"
  assert_success
}

@test "is_git_worktree_root target path is directory inside worktree" {
  mkdir -p "$GIT_WORKTREE_DIR/directory"
  run is_git_worktree_root "$GIT_WORKTREE_DIR/directory"
  assert_failure
}

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
UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

setup() {
  create_local_git_repository "$GIT_WORKTREE_DIR"
  cd "$TEST_WORK_DIR"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.target
#   does not exist
#   directory
#   untracked file
#   staging file
#   managed file
#   managed file in dir
#   managed symlink
#   managed broken symlink
#   deleted file
#   submodule file
#   managed file contain unsuitable character in name

@test "is_git_managed_file run with no args" {
  run is_git_managed_file
  assert_output -p "[✗] is_git_managed_file : need target_path"
  assert_failure
}

@test "is_git_managed_file target_path does not exist" {
  run is_git_managed_file "not_exist"
  assert_failure
}

@test "is_git_managed_file target_path is dir" {
  mkdir -p "$GIT_WORKTREE_DIR/dir"
  run is_git_managed_file "$GIT_WORKTREE_DIR/dir"
  assert_output -p "[✗] is_git_managed_file : $GIT_WORKTREE_DIR/dir is directory. Please specify a file."
  assert_failure
}

@test "is_git_managed_file target_path is untracked file" {
  touch "$GIT_WORKTREE_DIR/file"
  run is_git_managed_file "$GIT_WORKTREE_DIR/file"
  assert_failure
}

@test "is_git_managed_file target_path is staging file" {
  touch "$GIT_WORKTREE_DIR/file"
  git_add "$GIT_WORKTREE_DIR/file"
  run is_git_managed_file "$GIT_WORKTREE_DIR/file"
  assert_success
}

@test "is_git_managed_file target_path is managed file" {
  touch "$GIT_WORKTREE_DIR/file"
  git_commit "$GIT_WORKTREE_DIR/file"
  run is_git_managed_file "$GIT_WORKTREE_DIR/file"
  assert_success
}

@test "is_git_managed_file target_path is managed file in dir" {
  mkdir -p "$GIT_WORKTREE_DIR/dir"
  touch "$GIT_WORKTREE_DIR/dir/file"
  git_commit "$GIT_WORKTREE_DIR/dir/file"
  run is_git_managed_file "$GIT_WORKTREE_DIR/dir/file"
  assert_success
}

@test "is_git_managed_file target_path is symlink" {
  touch "file"
  ln -s "$TEST_WORK_DIR/file" "$GIT_WORKTREE_DIR/symlink"
  git_commit "$GIT_WORKTREE_DIR/symlink"
  run is_git_managed_file "$GIT_WORKTREE_DIR/symlink"
  assert_success
}

@test "is_git_managed_file target_path is broken symlink" {
  ln -s "/not_found" "$GIT_WORKTREE_DIR/symlink"
  git_commit "$GIT_WORKTREE_DIR/symlink"
  run is_git_managed_file "$GIT_WORKTREE_DIR/symlink"
  assert_success
}

@test "is_git_managed_file target_path is deleted file" {
  touch "$GIT_WORKTREE_DIR/file"
  git_commit "$GIT_WORKTREE_DIR/file"
  rm "$GIT_WORKTREE_DIR/file"
  run is_git_managed_file "$GIT_WORKTREE_DIR/file"
  assert_output -p "[✗] is_git_managed_file : $GIT_WORKTREE_DIR/file does not exist"
  assert_failure
}

@test "is_git_managed_file target_path is submodule file" {
  local submodule_dir="$TEST_WORK_DIR/submodule"
  create_local_git_repository "$submodule_dir"
  touch "$submodule_dir/file"
  git_commit "$submodule_dir/file"
  (
    cd "$GIT_WORKTREE_DIR"|| fail
    git submodule add "$submodule_dir" submodule
  )
  run is_git_managed_file "$GIT_WORKTREE_DIR/submodule/file"
  assert_success
}

@test "is_git_managed_file target_path is managed. And contain unsuitable character in name" {

  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    mkdir -p "$GIT_WORKTREE_DIR/$i"
    touch "$GIT_WORKTREE_DIR/$i/$i"
  done

  git_commit "$GIT_WORKTREE_DIR"

  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    run is_git_managed_file "$GIT_WORKTREE_DIR/$i/$i"
    assert_success
  done
}

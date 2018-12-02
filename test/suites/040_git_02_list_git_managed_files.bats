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

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.target path
#   does not exist
#   is file
#   is not worktree
#   is empty worktree
# 3.target path contain
#   managed file
#   staging file
#   managed file in dir
#   unmanaged file
#   deleted file
#   managed symlink
#   managed broken symlink
#   submodule file
#   managed file contain unsuitable character in name


@test "list_git_managed_files run with no args" {
  run list_git_managed_files
  assert_output -p "[✗] list_git_managed_files : need worktree_path"
  assert_failure
}

@test "list_git_managed_files target_path is file" {

  run list_git_managed_files "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[✗] list_git_managed_files : $KAWAZU_DOTFILES_DIR/file is not directory. Please specify a directory"
  assert_failure
}

@test "list_git_managed_files repository_path is not worktree" {
  run list_git_managed_files "$TEST_WORK_DIR"
  assert_output -p "[✗] list_git_managed_files : $TEST_WORK_DIR is not git worktree"
  assert_failure
}

@test "list_git_managed_files repository_path is empty worktree" {
  create_local_git_repository "$GIT_WORKTREE_DIR"
  run list_git_managed_files "$GIT_WORKTREE_DIR"
  assert_output ""
  assert_success
}

@test "list_git_managed_files repository_path contain files" {
  expect_arr=(
    "$GIT_WORKTREE_DIR/managed_file"
    "$GIT_WORKTREE_DIR/staging_file"
    "$GIT_WORKTREE_DIR/dir/managed_file"
  )

  #prepare
  create_local_git_repository "$GIT_WORKTREE_DIR"
  mkdir -p "$GIT_WORKTREE_DIR/dir"
  touch "$GIT_WORKTREE_DIR/managed_file"
  touch "$GIT_WORKTREE_DIR/dir/managed_file"
  touch "$GIT_WORKTREE_DIR/deleted_file"
  git_commit "$GIT_WORKTREE_DIR"

  touch "$GIT_WORKTREE_DIR/staging_file"
  git_add "$GIT_WORKTREE_DIR/staging_file"

  rm "$GIT_WORKTREE_DIR/deleted_file"
  touch "$GIT_WORKTREE_DIR/ummanaged_file"

  #run
  assert_output_contain_in_array "list_git_managed_files \"$GIT_WORKTREE_DIR\"" expect_arr
}

@test "list_git_managed_files repository_path contain symlinks" {
  expect_arr=(
    "$GIT_WORKTREE_DIR/file"
    "$GIT_WORKTREE_DIR/symlink"
    "$GIT_WORKTREE_DIR/broken_symlink"
  )

  #prepare
  create_local_git_repository "$GIT_WORKTREE_DIR"
  touch "$GIT_WORKTREE_DIR/file"
  ln -s "file" "$GIT_WORKTREE_DIR/symlink"
  ln -s "/not_found" "$GIT_WORKTREE_DIR/broken_symlink"
  git_commit "$GIT_WORKTREE_DIR"

  #run
  assert_output_contain_in_array "list_git_managed_files \"$GIT_WORKTREE_DIR\"" expect_arr
}

@test "list_git_managed_files repository_path contain submodule" {
  expect_arr=(
    "$GIT_WORKTREE_DIR/.gitmodules"
    "$GIT_WORKTREE_DIR/submodule/file"
  )

  #prepare
  git_submodule_dir="$TEST_WORK_DIR/submodule"
  create_local_git_repository "$git_submodule_dir"
  touch "$git_submodule_dir/file"
  git_commit "$git_submodule_dir/file"

  create_local_git_repository "$GIT_WORKTREE_DIR"
  (
    cd "$GIT_WORKTREE_DIR" || fail
    git submodule add "$git_submodule_dir"
  )

  #run
  assert_output_contain_in_array "list_git_managed_files \"$GIT_WORKTREE_DIR\"" expect_arr
}

@test "list_git_managed_files repository_path contain unsuitable character in name" {
  #prepare
  expect_arr=(
  )
  create_local_git_repository "$GIT_WORKTREE_DIR"
  for i in "${UNSUITABLE_CHARACTERS[@]}";do
    expect_arr+=("$GIT_WORKTREE_DIR/$i/$i")
    mkdir -p "$GIT_WORKTREE_DIR/$i"
    touch "$GIT_WORKTREE_DIR/$i/$i"
  done

  git_commit "$GIT_WORKTREE_DIR"

  #run
  assert_output_contain_in_array "list_git_managed_files \"$GIT_WORKTREE_DIR\"" expect_arr
}

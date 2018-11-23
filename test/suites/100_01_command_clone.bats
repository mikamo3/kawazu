#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  export_env
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  source ${KAWAZU_ROOT_DIR}/lib/command_clone.sh
  create_local_git_bare_repository
}

teardown() {
  delete_test_dir
}

@test "clone with no args" {
  run clone
  #FIXME: print usage
  assert_output -p "[✗] "
  assert_failure
}

@test "clone from local repository when exist worktree" {
  create_git_repository
  run clone "$BARE_REPOS_DIR"
  assert_output -p "[i] $TEST_WORK_DIR/.dotfiles is already managed by git. skip"
  assert_failure
}

@test "clone from local git repository when target directory does not exist" {
  rm -rf "$KAWAZU_DOTFILES_DIR"
  run clone "$BARE_REPOS_DIR"
  assert_output -p "[✓] clone : $BARE_REPOS_DIR to $KAWAZU_DOTFILES_DIR"
  assert_success
}

@test "clone from invalid source" {
  run clone /path_not_exist/repos.git
  assert_output -p "[✗] "
  assert_failure
}

@test "clone form github with https protocol" {
  run clone "$GIT_REMOTE_URL"
  assert_output -p "[✓] clone : $GIT_REMOTE_URL to $KAWAZU_DOTFILES_DIR"
  branch=$(get_current_branch)
  assert $(is_git_repository "$KAWAZU_DOTFILES_DIR")
  assert_equal "$branch" "master"
  assert_success
}

@test "clone and switch exist branch" {
  run clone "$BARE_REPOS_DIR" "develop"
  assert_output -p "[✓] clone : $BARE_REPOS_DIR to $KAWAZU_DOTFILES_DIR"
  assert_output -p "[✓] swith to branch develop"
  assert $(is_git_repository "$KAWAZU_DOTFILES_DIR")
  branch=$(get_current_branch)
  assert_equal "$branch" "develop"
  assert_success
}

@test "clone and switch not exist branch" {
  run clone "$GIT_REMOTE_URL" not_exist_branch
  assert_output -p "[✓] swith to branch not_exist_branch"
  assert_output -p "[✓] clone : $GIT_REMOTE_URL to $KAWAZU_DOTFILES_DIR"
  assert $(is_git_repository /tmp/test/.dotfiles)
  branch=$(get_current_branch)
  assert_equal "$branch" "not_exist_branch"
}

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
  github_repos=https://github.com/mikamo3/test_repos.git
  create_local_git_bare_repository
  delete_dotfiles_git_repository
}

teardown() {
  delete_dotfiles_git_repository
  delete_local_git_bare_repository
}

@test "clone with no args" {
  run clone
  assert_output -p "[✗] clone : need repo [branch]"
  assert_failure
}

@test "clone from local git repository when target directory is already managed git" {
  create_dotfiles_git_repository
  run clone "$local_git_repository_path"
  assert_output -p "[i] /tmp/test/.dotfiles is already managed by git. skip"
  assert_success
}

@test "clone from local git repository when target directory does not exist" {
  run clone "$local_git_repository_path"
  assert_output -p "[✓] clone : /tmp/test/git_repos.git to /tmp/test/.dotfiles"
  assert_success
}

@test "clone from invalid source" {
  run clone /path_not_exist/repos.git
  assert_output -p "[✗] "
  assert_failure
}

@test "clone form github with https protocol" {
  run clone https://github.com/mikamo3/test_repos.git
  assert_output -p "[✓] clone : https://github.com/mikamo3/test_repos.git to /tmp/test/.dotfiles"
  branch=$(get_current_branch)
  assert $(is_git_repository /tmp/test/.dotfiles)
  assert_equal "$branch" "master"
  assert_success
}

@test "clone and switch exist branch" {
  run clone https://github.com/mikamo3/test_repos.git develop
  assert_output -p "[✓] clone : https://github.com/mikamo3/test_repos.git to /tmp/test/.dotfiles"
  assert_output -p "[✓] swith to branch develop"
  assert $(is_git_repository /tmp/test/.dotfiles)
  branch=$(get_current_branch)
  assert_equal "$branch" "develop"
  assert_success
}

@test "clone and switch not exist branch" {
  run clone https://github.com/mikamo3/test_repos.git not_exist_branch
  assert_output -p "[✓] clone : https://github.com/mikamo3/test_repos.git to /tmp/test/.dotfiles"
  assert_output -p "[✓] swith to branch not_exist_branch"
  assert $(is_git_repository /tmp/test/.dotfiles)
  branch=$(get_current_branch)
  assert_equal "$branch" "not_exist_branch"
}

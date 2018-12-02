#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env
load ../fixtures/git

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/file.sh
source ${KAWAZU_ROOT_DIR}/lib/command_clone.sh

source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh
source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh


LOCAL_BARE_REPOSITORY_PATH="$TEST_WORK_DIR/repos.git"

setup() {
  create_local_git_bare_repository "$LOCAL_BARE_REPOSITORY_PATH"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.repository path
#   is local dir
#   is url (github)
#   is invalid path
# 3.repository
#   contain submodule
# 4.branch
#   switch to exist branch
#   switch to not exist branch

@test "command_clone run with no args" {
  run command_clone
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "clone"
  assert_failure
}

@test "command_clone run with 3 args" {
  run command_clone
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "clone"
  assert_failure
}

@test "command_clone repository path is local dir" {
  run command_clone "$LOCAL_BARE_REPOSITORY_PATH"
  assert_success
  assert_line -n 0 -p "[✓] clone : $LOCAL_BARE_REPOSITORY_PATH to $KAWAZU_DOTFILES_DIR"
}

@test "command_clone repository path is url" {
  repository_url="https://github.com/mikamo3/test_repos.git"
  run command_clone "$repository_url"
  assert_success
  assert_line -n 0 -p "[✓] clone : $repository_url to $KAWAZU_DOTFILES_DIR"
}

@test "command_clone invalid repository path " {
  run command_clone "/not_found"
  assert_failure
}

@test "command_clone repository contain submodule" {
  submodule_repository_path="$TEST_WORK_DIR/submodule"
  worktree_path="$TEST_WORK_DIR/worktree"
  create_local_git_repository "$submodule_repository_path"
  touch "$submodule_repository_path/file"
  git_commit "$submodule_repository_path/file"

  git clone "$LOCAL_BARE_REPOSITORY_PATH" "$worktree_path"
  (
    cd "$worktree_path"
    git config user.name "test"
    git config user.email "test@example.com"
    git submodule add "$submodule_repository_path" submodule
    git commit -m "add submodule"
    git push
  )

  run command_clone "$LOCAL_BARE_REPOSITORY_PATH"
  assert_success
  assert_file_exist "$KAWAZU_DOTFILES_DIR/submodule/file"
}

@test "command_clone switch to exist branch" {
  worktree_path="$TEST_WORK_DIR/worktree"
  git clone "$LOCAL_BARE_REPOSITORY_PATH" "$worktree_path"
  (
    cd "$worktree_path"
    git config user.name "test"
    git config user.email "test@example.com"
    touch file
    git add file
    git commit -m "commit at master"
    git push origin master
    git checkout -b exist_branch
    touch file2
    git add file2
    git commit -m "commit at exist_branch"
    git push origin exist_branch
    git remote get-url origin
  )
  run command_clone "$LOCAL_BARE_REPOSITORY_PATH" exist_branch
  assert_success
  assert_line -n 0 -p "[✓] clone : $LOCAL_BARE_REPOSITORY_PATH to $KAWAZU_DOTFILES_DIR"
  cd "$KAWAZU_DOTFILES_DIR"
  assert_equal "$(git rev-parse --abbrev-ref @)" "exist_branch"
}

@test "command_clone switch to not exist branch" {
  run command_clone "$LOCAL_BARE_REPOSITORY_PATH" not_exist_branch
  assert_success
  assert_line -n 0 -p "[✓] clone : $LOCAL_BARE_REPOSITORY_PATH to $KAWAZU_DOTFILES_DIR"
  cd "$KAWAZU_DOTFILES_DIR"
  assert_equal "$(LANG=C git status |head -n1 )" "On branch not_exist_branch"
}

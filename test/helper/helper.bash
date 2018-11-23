#!/usr/bin/bash
export_env() {
  TEST_WORK_DIR=$(mktemp -d)
  KAWAZU_ROOT_DIR="$BATS_TEST_DIRNAME/../.."
  KAWAZU_DOTFILES_DIR="$TEST_WORK_DIR/.dotfiles"
  HOME="$TEST_WORK_DIR/home/user"
  KAWAZU_VERSION="0.1"
  OPT_DEBUG=true

  # use in script
  export TEST_WORK_DIR
  export KAWAZU_ROOT_DIR
  export KAWAZU_DOTFILES_DIR
  export KAWAZU_VERSION
  export OPT_DEBUG

  # use only in test
  BARE_REPOS_DIR="$TEST_WORK_DIR/repos.git"
  SUBMODULE_BARE_REPOS_DIR="$TEST_WORK_DIR/submodule_repos.git"

  # shellckeck disable=SC2034
  GIT_REMOTE_URL="https://github.com/mikamo3/test_repos.git"

  mkdir -p "$TEST_WORK_DIR"
  mkdir -p "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
  cd "$TEST_WORK_DIR" || return 1
}

emoji() {
  echo -e "\\U1f479"
}
#shellcheck disable=SC2120
create_test_files() {
  local prefix_dir="$TEST_WORK_DIR/"
  [[ $# != 0 ]] && prefix_dir="$1/"
  mkdir -p "${prefix_dir}path/to/dir"
  mkdir -p "${prefix_dir}path/to/symlink_dir"
  mkdir -p "${prefix_dir}path/to/symlink_dir/-newline
dir $(emoji)*"
  mkdir -p "${prefix_dir}path/to/-newline
dir $(emoji)*"
  touch "${prefix_dir}file"
  touch "${prefix_dir}path/to/file"
  touch "${prefix_dir}path/to/dir/file"
  touch "${prefix_dir}path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"

  ln -s "../file" "${prefix_dir}path/to/symlink_dir/rel_symlink"
  ln -s "../dir" "${prefix_dir}path/to/symlink_dir/rel_dir_symlink"
  ln -s "/not_exist_file" "${prefix_dir}path/to/symlink_dir/broken_symlink"
  ln -s "../../-newline
dir $(emoji)*/-newline
file $(emoji)*" "${prefix_dir}path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink"

  if [[ "$prefix_dir" == "$TEST_WORK_DIR/" ]]; then
    ln -s "${prefix_dir}path/to/file" "${prefix_dir}path/to/symlink_dir/abs_symlink"
    ln -s "${prefix_dir}path/to/dir" "${prefix_dir}path/to/symlink_dir/abs_dir_symlink"
    ln -s "${prefix_dir}path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*" "${prefix_dir}path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* abs_symlink"
  fi
}

prepare_test() {
  export_env
  #shellcheck disable=SC2119
  create_test_files
}

delete_test_dir() {
  [[ -n "$TEST_WORK_DIR" ]] && rm -rf "$TEST_WORK_DIR"
}

create_git_repository() {
  (mkdir -p "$KAWAZU_DOTFILES_DIR" \
    && cd "$KAWAZU_DOTFILES_DIR" \
    && git init \
    && git config user.name "test" \
    && git config user.email "test@example.com")
}

create_local_git_bare_repository() {
  local worktree_dir
  local submodule_worktree_dir
  mkdir -p "$BARE_REPOS_DIR"
  mkdir -p "$SUBMODULE_BARE_REPOS_DIR"
  worktree_dir=$(mktemp -d "$TEST_WORK_DIR/XXXXXXXXX")
  submodule_worktree_dir=$(mktemp -d "$TEST_WORK_DIR/XXXXXXXXX")

  (cd "$BARE_REPOS_DIR" && git init --bare)

  (cd "$SUBMODULE_BARE_REPOS_DIR" && git init --bare)

  git clone "$SUBMODULE_BARE_REPOS_DIR" "$submodule_worktree_dir"
  git_create_file_and_push "$submodule_worktree_dir"

  git clone "$BARE_REPOS_DIR" "$worktree_dir"
  (
    cd "$worktree_dir" || return 1
    git submodule add "$SUBMODULE_BARE_REPOS_DIR" submodule
  )
  git_create_file_and_push "$worktree_dir"
  rm -rf "$submodule_worktree_dir"
  rm -rf "$worktree_dir"
}

git_create_file_and_push() {
  local target_path=$1
  (
    cd "$target_path" || return 1
    git config user.name "test"
    git config user.email "test@example.com"
    #shellcheck disable=SC2119
    create_test_files "$target_path"
    git add -A
    git commit -m "testcommit"
    git push
  )
}

is_git_repository() {
  (cd "$1" && git rev-parse --is-inside-work-tree)
  return $?
}

get_current_branch() {
  local branch
  branch=$(cd "$KAWAZU_DOTFILES_DIR" && git branch | grep "^\\* ")
  echo "${branch#* }"
}

git_add_file() {
  local target_file_path=$1
  (
    cd "$KAWAZU_DOTFILES_DIR" || return 1
    local target_dir_path
    target_dir_path="$(dirname "$target_file_path")"
    [[ -n "$target_dir_path" ]] && mkdir -p "$target_dir_path"
    touch "$target_file_path"
    git add "$target_file_path"
  )
}

git_get_file_status() {
  local target_file_path=$1
  local status=$2
  (
    cd "$KAWAZU_DOTFILES_DIR" || return 1
    git status -s #for debug
    git status -s | grep "^\\s*${status}\\s\\+\"\\?${target_file_path}\"\\?"
  )
}

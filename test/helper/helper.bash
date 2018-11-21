#!/usr/bin/bash
export_env() {
  TEST_WORK_DIR=$(mktemp -d)
  KAWAZU_ROOT_DIR="$BATS_TEST_DIRNAME/../.."
  KAWAZU_DOTFILES_DIR="${TEST_WORK_DIR}/.dotfiles"
  HOME="$TEST_WORK_DIR/home/user"
  KAWAZU_VERSION="0.1"
  OPT_DEBUG=true
  # shellckeck disable=SC1117
  EMOJI="\U1f479"
  export TEST_WORK_DIR
  export KAWAZU_ROOT_DIR
  export KAWAZU_DOTFILES_DIR
  export KAWAZU_VERSION
  export OPT_DEBUG
  export EMOJI
  cd "$TEST_WORK_DIR" || return 1
}

create_test_directory() {
  mkdir -p "$TEST_WORK_DIR"
  mkdir -p "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
}

create_test_files() {
  mkdir -p "$TEST_WORK_DIR/path/to/dir"
  mkdir -p "$TEST_WORK_DIR/path/to/dir2"
  mkdir -p "$TEST_WORK_DIR/path/to/newline
dir"
  mkdir -p "$TEST_WORK_DIR/$(echo -e "$EMOJI")"

  touch "$TEST_WORK_DIR/path/to/file"
  touch "$TEST_WORK_DIR/path/to/dir/file"
  touch "$TEST_WORK_DIR/path/to/dir/file space"
  touch "$TEST_WORK_DIR/path/to/dir/newline
file"
  touch "$TEST_WORK_DIR/path/to/newline
dir/newline
file"
  touch "$TEST_WORK_DIR/$(echo -e "$EMOJI")/$(echo -e "$EMOJI")"

  ln -s "$TEST_WORK_DIR/path/to/file" "$TEST_WORK_DIR/path/to/dir/abs_symlink"
  ln -s "../file" "$TEST_WORK_DIR/path/to/dir/rel_symlink"
  ln -s "/not_exist_file" "$TEST_WORK_DIR/path/to/dir/broken_symlink"
}

delete_test_directory() {
  [[ -n "$TEST_WORK_DIR" ]] && rm -rf "$TEST_WORK_DIR"
}

create_dotfiles_git_repository() {
  (mkdir -p "$KAWAZU_DOTFILES_DIR" \
    && cd "$KAWAZU_DOTFILES_DIR" \
    && git init \
    && git config user.name "test" \
    && git config user.email "test@example.com")
}
delete_dotfiles_git_repository() {
  rm -rf "$KAWAZU_DOTFILES_DIR"
}

is_git_repository() {
  (cd "$1" && git rev-parse --is-inside-work-tree)
  return $?
}

create_local_git_bare_repository() {
  local_git_repository_path="$TEST_WORK_DIR/git_repos.git"
  mkdir -p "$local_git_repository_path"
  (cd "$local_git_repository_path" && git init --bare)
}

delete_local_git_bare_repository() {
  local_git_repository_path="$TEST_WORK_DIR/git_repos.git"
  rm -rf "$local_git_repository_path"
}

get_current_branch() {
  local branch
  branch=$(cd "$KAWAZU_DOTFILES_DIR" && git branch | grep "^\\* ")
  echo "${branch#* }"
}

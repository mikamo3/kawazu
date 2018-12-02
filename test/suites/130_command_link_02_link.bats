#!/usr/bin/env bats
#TODO: add submodule test case
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

load ../fixtures/env
load ../fixtures/git

source ${KAWAZU_ROOT_DIR}/lib/console.sh
source ${KAWAZU_ROOT_DIR}/lib/file.sh
source ${KAWAZU_ROOT_DIR}/lib/interactive.sh
source ${KAWAZU_ROOT_DIR}/lib/git.sh
source ${KAWAZU_ROOT_DIR}/lib/command_link.sh

source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh
source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh

REL_DOTFILES_DIR="../../.dotfiles"
UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

setup() {
  create_local_git_repository "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
  cd "$HOME"
}

# test pattern
# 1.wrong arguments
# 2.run with no arguments
#   already linked to home directory
#   with same name exists
#     overwrite
#     skip
#   contain unsuitable character
# 3.run with argument
#   target path is repository file
#   target path does not exist

@test "command_link run with 2 args" {
  run command_link a b
  assert_failure
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "link"
}

@test "command_link run with no args link all files" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/file_a"
  touch "$KAWAZU_DOTFILES_DIR/file_b"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR"
  run command_link
  assert_success
  assert_equal "$(readlink "$HOME/file_a")" "$REL_DOTFILES_DIR/file_a"
  assert_equal "$(readlink "$HOME/file_b")" "$REL_DOTFILES_DIR/file_b"
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "../../../$REL_DOTFILES_DIR/path/to/dir/file"
}

@test "command_link run with no args already linked to home dir" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/file_a"
  touch "$KAWAZU_DOTFILES_DIR/file_b"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR"

  ln -s "$REL_DOTFILES_DIR/file_b" "$HOME/file_b"
  run command_link
  assert_failure
  assert_equal "$(readlink "$HOME/file_a")" "$REL_DOTFILES_DIR/file_a"
  assert_equal "$(readlink "$HOME/file_b")" "$REL_DOTFILES_DIR/file_b"
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "../../../$REL_DOTFILES_DIR/path/to/dir/file"
}


@test "command_link run with no args with same name exists. then overwrite" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/file_a"
  touch "$KAWAZU_DOTFILES_DIR/file_b"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR"

  touch "$HOME/file_b"
  run command_link < <(echo y)
  assert_success
  assert_equal "$(readlink "$HOME/file_a")" "$REL_DOTFILES_DIR/file_a"
  assert_equal "$(readlink "$HOME/file_b")" "$REL_DOTFILES_DIR/file_b"
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "../../../$REL_DOTFILES_DIR/path/to/dir/file"
}

@test "command_link run with no args with same name exists. then skip" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/file_a"
  touch "$KAWAZU_DOTFILES_DIR/file_b"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR"

  touch "$HOME/file_b"
  run command_link < <(echo n)
  assert_failure
  assert_equal "$(readlink "$HOME/file_a")" "$REL_DOTFILES_DIR/file_a"
  assert [ -f "$HOME/file_b" ]
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "../../../$REL_DOTFILES_DIR/path/to/dir/file"
}

@test "command_link run with no args contain unsuitable character" {
  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    mkdir -p "$KAWAZU_DOTFILES_DIR/$i"
    touch "$KAWAZU_DOTFILES_DIR/$i/$i"
  done
  git_add "$KAWAZU_DOTFILES_DIR"
  run command_link
  assert_success

  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    assert_equal "$(readlink "$HOME/$i/$i")" "../$REL_DOTFILES_DIR/$i/$i"
  done
}

@test "command_link target path is repository file" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/file_a"
  touch "$KAWAZU_DOTFILES_DIR/file_b"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR"

  run command_link "$KAWAZU_DOTFILES_DIR/file_b"
  assert_success
  assert_file_not_exist "$HOME/file_a"
  assert_equal "$(readlink "$HOME/file_b")" "$REL_DOTFILES_DIR/file_b"
  assert_file_not_exist "$HOME/path/to/dir/file"

}

@test "command_link target path does not exist" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/file_a"
  touch "$KAWAZU_DOTFILES_DIR/file_b"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR"

  run command_link "not_found"
  assert_failure
  assert_file_not_exist "$HOME/file_a"
  assert_file_not_exist "$HOME/file_b"
  assert_file_not_exist "$HOME/path/to/dir/file"

}

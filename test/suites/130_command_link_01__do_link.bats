#!/usr/bin/env bats
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

#for backup dir name
NOW_DATE="$(date +%Y%m%d)"

#for expect
EXPECT_INTERACTIVE_HEADER="\r\n\u001b\[33m\[\?\]"
EXPECT_INFO_HEADER="\r\n\u001b\[36m\[i\]"
EXPECT_SUCCESS_HEADER="\r\n\u001b\[32m\[✓\]"
EXPECT_RESET="\u001b\[0m"
EXPECT_PROMPT="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"

UNSUITABLE_CHARACTERS=("-" "*" "link space" "link
newline" "👹")

setup() {
  create_local_git_repository "$KAWAZU_DOTFILES_DIR"
  mkdir -p "$HOME"
  cd "$HOME"
}

teardown() {
  delete_test_dir
}

# test pattern
# 1.wrong arguments
# 2.target file
#   exists in worktree root
#   exists in directory that exists in worktree
#   already linkd to home directory
#     $HOME/file
#     $HOME/path/to/dir/file
#     absolute path
#     relative path
#   is not managed
#   is directory
#   does not exist
#   is symbolic link
#   is broken link
#   with same name exists in home directory
#     overwrite
#       $HOME/file
#       $HOME/path/to/dir/file
#     skip
#   contain unsuitable character

@test "_do_link run with no args" {
  run _do_link
  assert_failure
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "link"
}

@test "_do_link run with 2 args" {
  run _do_link a b
  assert_failure
  assert_line -n 0 -p "[✗] invalid arguments"
  assert_mock_output 1 "command_help" "link"
}

@test "_do_link target file exists in worktree root" {
  touch "$KAWAZU_DOTFILES_DIR/file"
  git_add "$KAWAZU_DOTFILES_DIR/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_success
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/file → $HOME/file"
  assert_equal "$(readlink $HOME/file)" "../../.dotfiles/file"
}

@test "_do_link target file exists in directory that exists in worktree" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_success
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/path/to/dir/file → $HOME/path/to/dir/file"
  assert_equal "$(readlink $HOME/path/to/dir/file)" "../../../../../.dotfiles/path/to/dir/file"
}

@test "_do_link target file already linked to home directory. path is ./file. link is abs path" {
  touch "$KAWAZU_DOTFILES_DIR/file"
  git_add "$KAWAZU_DOTFILES_DIR/file"
  ln -s "$KAWAZU_DOTFILES_DIR/file" "$HOME/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_failure
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR/file already linked"
}

@test "_do_link target file already linked to home directory. path is ./file. link is rel path" {
  touch "$KAWAZU_DOTFILES_DIR/file"
  git_add "$KAWAZU_DOTFILES_DIR/file"
  ln -s "../../.dotfiles/file" "$HOME/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_failure
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR/file already linked"
}

@test "_do_link target file already linked to home directory. path is ./path/to/dir/file. link is abs path" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  mkdir -p "$HOME/path/to/dir"
  ln -s "$KAWAZU_DOTFILES_DIR/path/to/dir/file" "$HOME/path/to/dir/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_failure
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR/path/to/dir/file already linked"
}

@test "_do_link target file already linked to home directory. path is ./path/to/dir/file. link is rel path" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  touch "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  mkdir -p "$HOME/path/to/dir"
  ln -s "../../../../../.dotfiles/path/to/dir/file" "$HOME/path/to/dir/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_failure
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR/path/to/dir/file already linked"
}

@test "_do_link target file is not managed by git" {
  rm -rf "$KAWAZU_DOTFILES_DIR/.git"
  touch "$KAWAZU_DOTFILES_DIR/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR/file is not dotfiles file"
  assert_failure
}

@test "_do_link target is directory" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/dir"
  assert_failure
  assert_output -p "$KAWAZU_DOTFILES_DIR/path/to/dir is directory. Please specify a file."
}

@test "_do_link target file does not exist" {
  run _do_link "$KAWAZU_DOTFILES_DIR/not_exist"
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR/not_exist does not exist"
  assert_failure
}

@test "_do_link target file is symlink" {
  touch "$KAWAZU_DOTFILES_DIR/file"
  ln -s "$KAWAZU_DOTFILES_DIR/file" "$KAWAZU_DOTFILES_DIR/link"
  git_add "$KAWAZU_DOTFILES_DIR"
  run _do_link "$KAWAZU_DOTFILES_DIR/link"
  assert_success
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/link → $HOME/link"
  assert_equal "$(readlink "$HOME/link")" "../../.dotfiles/link"
}

@test "_do_link target file is broken link" {
  ln -s "/not_found" "$KAWAZU_DOTFILES_DIR/link"
  git_add "$KAWAZU_DOTFILES_DIR"
  run _do_link "$KAWAZU_DOTFILES_DIR/link"
  assert_success
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/link → $HOME/link"
  assert_equal "$(readlink "$HOME/link")" "../../.dotfiles/link"
}

@test "_do_link target file with the same name exist in \$HOME and overwrite" {
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file"
  git_add "$KAWAZU_DOTFILES_DIR/file"
  echo "home file" > "$HOME/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_link.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh\n"
    send "_do_link ${KAWAZU_DOTFILES_DIR}/file\n"
    expect -ex "$EXPECT_INTERACTIVE_HEADER $HOME/file is already exist. do you want to overwrite?\
\\r\\nFile is backed up to $KAWAZU_BACKUP_DIR/$NOW_DATE/file (y/n) : " {} default {exit 1}
    send "y"
    expect -ex "$EXPECT_SUCCESS_HEADER backup $HOME/file → $KAWAZU_BACKUP_DIR/$NOW_DATE/file" {} defalut {exit 1}
    expect -ex "$EXPECT_SUCCESS_HEADER link $KAWAZU_DOTFILES_DIR/file → $HOME/file" {} defalut {exit 1}
    expect -re "$EXPECT_PROMPT" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\\r\\n0\\r\\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_equal "$(cat "$KAWAZU_BACKUP_DIR/$NOW_DATE/file")" "home file"
  assert_equal "$(readlink $HOME/file)" "../../.dotfiles/file"
}

@test "_do_link target file with the same name exist in \$HOME/path/to/dir/ and overwrite" {
  mkdir -p "$KAWAZU_DOTFILES_DIR/path/to/dir"
  echo "git file" > "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  git_add "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  mkdir -p "$HOME/path/to/dir"
  echo "home file" > "$HOME/path/to/dir/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_link.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/test/mock/mock.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/test/mock/lib/command_help.sh\n"
    send "_do_link ${KAWAZU_DOTFILES_DIR}/path/to/dir/file\n"
    expect -ex "$EXPECT_INTERACTIVE_HEADER $HOME/path/to/dir/file is already exist. do you want to overwrite?\
\\r\\nFile is backed up to $KAWAZU_BACKUP_DIR/$NOW_DATE/path/to/dir/file (y/n) : " {} default {exit 1}
    send "y"
    expect -ex "$EXPECT_SUCCESS_HEADER backup $HOME/path/to/dir/file → $KAWAZU_BACKUP_DIR/$NOW_DATE/path/to/dir/file" {} defalut {exit 1}
    expect -ex "$EXPECT_SUCCESS_HEADER link $KAWAZU_DOTFILES_DIR/path/to/dir/file → $HOME/path/to/dir/file" {} defalut {exit 1}
    expect -re "$EXPECT_PROMPT" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\\r\\n0\\r\\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_equal "$(cat "$KAWAZU_BACKUP_DIR/$NOW_DATE/path/to/dir/file")" "home file"
  assert_equal "$(readlink $HOME/path/to/dir/file)" "../../../../../.dotfiles/path/to/dir/file"
}

@test "_do_link target file with the same name exist in \$HOME and skip" {
  echo "git file" > "$KAWAZU_DOTFILES_DIR/file"
  git_add "$KAWAZU_DOTFILES_DIR/file"
  echo "home file" > "$HOME/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_link.sh\n"
    send "_do_link ${KAWAZU_DOTFILES_DIR}/file\n"
    expect -ex "$EXPECT_INTERACTIVE_HEADER $HOME/file is already exist. do you want to overwrite?\
\\r\\nFile is backed up to $KAWAZU_BACKUP_DIR/$NOW_DATE/file (y/n) : " {} default {exit 1}
    send "n"
    expect -re "$EXPECT_PROMPT" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\\r\\n1\\r\\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_equal "$(cat "$HOME/file")" "home file"
  assert_file_not_exist "$KAWAZU_BACKUP_DIR/$NOW_DATE/file"
}

@test "_do_link target file contain unsuitable character" {
  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    mkdir -p "$KAWAZU_DOTFILES_DIR/$i"
    touch "$KAWAZU_DOTFILES_DIR/$i/$i"
  done
  git_add "$KAWAZU_DOTFILES_DIR"

  for i in "${UNSUITABLE_CHARACTERS[@]}"; do
    run _do_link "$KAWAZU_DOTFILES_DIR/$i/$i"
    assert_success
    assert_equal "$(readlink "$HOME/$i/$i")" "../../../.dotfiles/$i/$i"
  done
}

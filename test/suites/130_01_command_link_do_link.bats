#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  source ${KAWAZU_ROOT_DIR}/lib/interactive.sh
  source ${KAWAZU_ROOT_DIR}/lib/git.sh
  source ${KAWAZU_ROOT_DIR}/lib/command_link.sh
  create_git_repository
  create_test_files "$KAWAZU_DOTFILES_DIR"
  (cd "$KAWAZU_DOTFILES_DIR" && git add -A)

  #for backup dir name
  now_date=$(date +%Y%m%d)
  #for expect
  expect_interactive_header="\r\n\u001b\[33m\[\?\]"
  expect_info_header="\r\n\u001b\[36m\[i\]"
  expect_success_header="\r\n\u001b\[32m\[✓\]"
  expect_reset="\u001b\[0m"
  expect_prompt="\\r\\nbash-\[0-9\]{1,}\\\\.\[0-9\]{1,}\\\\$"
  cd "$HOME"
}

teardown() {
  delete_test_dir
}

@test "_do_link with no args" {
  #FIXME: print help
  run _do_link
  assert_output -p "[✗] "
  assert_failure
}

@test "_do_link target file is not managed by git" {
  rm -rf "$KAWAZU_DOTFILES_DIR/.git"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR/file is not dotfiles file"
  assert_failure
}

@test "_do_link target file does not exist" {
  run _do_link "$KAWAZU_DOTFILES_DIR/not_exist"
  assert_output -p "[✗] $KAWAZU_DOTFILES_DIR/not_exist does not exist"
  assert_failure
}

@test "_do_link target file is worktree root file" {
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/file → $HOME/file"
  assert_equal "$(readlink "$HOME/file")" "../../.dotfiles/file"
  assert_success
}

@test "_do_link run at root directory" {
  cd /
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/file → $HOME/file"
  assert_equal "$(readlink "$HOME/file")" "../../.dotfiles/file"
  assert_success
}

@test "_do_link target file contains dir" {
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/path/to/dir/file → $HOME/path/to/dir/file"
  assert_equal "$(readlink "$HOME/path/to/dir/file")" "../../../../../.dotfiles/path/to/dir/file"
  assert_success
}

@test "_do_link target file is symlink" {
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_symlink"
  assert_output -p "[✓] link $KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_symlink → $HOME/path/to/symlink_dir/rel_symlink"
  assert_equal "$(readlink "$HOME/path/to/symlink_dir/rel_symlink")" "../../../../../.dotfiles/path/to/symlink_dir/rel_symlink"
}

@test "_do_link already linked (symlink is abs path)" {
  ln -s "$KAWAZU_DOTFILES_DIR/file" "$HOME/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR/file already linked"
  assert_failure
}

@test "_do_link already linked (symlink is rel path)" {
  cd "$HOME"
  ln -s "../../.dotfiles/file" "$HOME/file"
  run _do_link "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[i] $KAWAZU_DOTFILES_DIR/file already linked"
  assert_failure
}

@test "_do_link file with the same name exist in home and answer is yes" {
  echo "file" > "$HOME/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_link.sh\n"
    send "_do_link ${KAWAZU_DOTFILES_DIR}/file\n"
    expect -ex "$expect_interactive_header $HOME/file is already exist. do you want to overwrite?\
\\r\\nFile is backed up to $KAWAZU_BACKUP_DIR/$now_date/file (y/n) : " {} default {exit 1}
    send "y"
    expect -ex "$expect_success_header backup $HOME/file → $KAWAZU_BACKUP_DIR/$now_date/file" {} defalut {exit 1}
    expect -ex "$expect_success_header link $KAWAZU_DOTFILES_DIR/file → $HOME/file" {} defalut {exit 1}
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\\r\\n0\\r\\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_equal "$(cat "$KAWAZU_BACKUP_DIR/$now_date/file")" "file"
  assert_equal "$(readlink $HOME/file)" "../../.dotfiles/file"
}

@test "_do_link file with the same name exist in home and answer is no" {
  echo "file" > "$HOME/file"
  run expect -d <<EOF
    set timeout 1
    spawn bash --norc
    send "source ${KAWAZU_ROOT_DIR}/lib/console.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/interactive.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/file.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/git.sh\n"
    send "source ${KAWAZU_ROOT_DIR}/lib/command_link.sh\n"
    send "_do_link ${KAWAZU_DOTFILES_DIR}/file\n"
    expect -ex "$expect_interactive_header $HOME/file is already exist. do you want to overwrite?\
\\r\\nFile is backed up to $KAWAZU_BACKUP_DIR/$now_date/file (y/n) : " {} default {exit 1}
    send "n"
    expect -re "$expect_prompt" {} default {exit 1}
    send "echo \\\$\?\n"
    expect -ex "\\r\\n1\\r\\n" {send "exit\n";exit 0} default {exit 1}
    exit 1
EOF
  assert_success
  assert_equal "$(cat "$HOME/file")" "file"
  assert_file_not_exist "$KAWAZU_BACKUP_DIR/file"
}

@test "_do_link target file path contain unsuitable character" {
  run _do_link "$KAWAZU_DOTFILES_DIR/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_line -n 0 -p "[✓] link $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 1 -p "dir $(emoji)*/-newline"
  assert_line -n 2 -p "file $(emoji)* → $HOME/path/to/-newline"
  assert_line -n 3 -p "dir $(emoji)*/-newline"
  assert_line -n 4 -p "file $(emoji)*"
  assert_equal "$(readlink "$HOME/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*")" "../../../../../.dotfiles/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_success
}

@test "_do_link target file path contain unsuitable character and file with the same name exist" {
  mkdir -p "$HOME/path/to/-newline
dir $(emoji)*"
  echo "file" > "$HOME/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  cd "$KAWAZU_DOTFILES_DIR/path/to/-newline
dir $(emoji)*"
  run _do_link "-newline
file $(emoji)*" < <(echo y)
  assert_line -n 0 -p "[?] $HOME/path/to/-newline"
  assert_line -n 1 -p "dir $(emoji)*/-newline"
  assert_line -n 2 -p "file $(emoji)* is already exist. do you want to overwrite?"
  assert_line -n 3 -p "File is backed up to $KAWAZU_BACKUP_DIR/$now_date/path/to/-newline"
  assert_line -n 4 -p "dir $(emoji)*/-newline"
  assert_line -n 5 -p "file $(emoji)* (y/n) : "
  assert_line -n 6 -p "[✓] backup $HOME/path/to/-newline"
  assert_line -n 7 -p "dir $(emoji)*/-newline"
  assert_line -n 8 -p "file $(emoji)* → $KAWAZU_BACKUP_DIR/$now_date/path/to/-newline"
  assert_line -n 9 -p "dir $(emoji)*/-newline"
  assert_line -n 10 -p "file $(emoji)*"
  assert_line -n 11 -p "[✓] link $KAWAZU_DOTFILES_DIR/path/to/-newline"
  assert_line -n 12 -p "dir $(emoji)*/-newline"
  assert_line -n 13 -p "file $(emoji)* → $HOME/path/to/-newline"
  assert_line -n 14 -p "dir $(emoji)*/-newline"
  assert_line -n 15 -p "file $(emoji)*"

  assert_equal "$(readlink "$HOME/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*")" "../../../../../.dotfiles/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
  assert_equal "$(cat "$KAWAZU_BACKUP_DIR/$now_date/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*")" "file"
  assert_success
}

#!/usr/bin/env bats
load ../helper/helper
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

setup() {
  prepare_test
  source ${KAWAZU_ROOT_DIR}/lib/console.sh
  source ${KAWAZU_ROOT_DIR}/lib/file.sh
  source ${KAWAZU_ROOT_DIR}/lib/git.sh
  create_local_git_bare_repository
  git clone --recurse-submodules "$BARE_REPOS_DIR" "$KAWAZU_DOTFILES_DIR" &>/dev/null
  (
    cd "$KAWAZU_DOTFILES_DIR" || return 1
    git config user.name "test"
    git config user.email "test@example.com"
    touch deleted_file_for_git_rm deleted_file
    git add deleted_file_for_git_rm deleted_file &>/dev/null
    git commit -m "add deleted_file" &>/dev/null
    git rm deleted_file_for_git_rm &>/dev/null
    rm deleted_file
    touch unmanaged_file
  )

  # result_file_list
  result_arr=(
    "$KAWAZU_DOTFILES_DIR/file"
    "$KAWAZU_DOTFILES_DIR/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
    "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
    "$KAWAZU_DOTFILES_DIR/path/to/file"
    "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink"
    "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/broken_symlink"
    "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_dir_symlink"
    "$KAWAZU_DOTFILES_DIR/path/to/symlink_dir/rel_symlink"
    "$KAWAZU_DOTFILES_DIR/submodule/file"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/-newline
dir $(emoji)*/-newline
file $(emoji)*"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/dir/file"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/file"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/symlink_dir/-newline
dir $(emoji)*/-newline
file $(emoji)* rel_symlink"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/symlink_dir/broken_symlink"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/symlink_dir/rel_dir_symlink"
    "$KAWAZU_DOTFILES_DIR/submodule/path/to/symlink_dir/rel_symlink"
  )
}

teardown() {
  delete_test_dir
}

@test "list_git_managed_files with no args" {
  run list_git_managed_files
  assert_output -p "[✗] list_git_managed_files : need worktree_path"
  assert_failure
}

@test "list_git_managed_files repository_path is file" {
  run list_git_managed_files "$KAWAZU_DOTFILES_DIR/file"
  assert_output -p "[✗] list_git_managed_files : $KAWAZU_DOTFILES_DIR/file is not directory. Please specify a file."
  assert_failure
}

@test "list_git_managed_files repository_path is not git worktree" {
  run list_git_managed_files "$TEST_WORK_DIR"
  assert_output -p "[✗] list_git_managed_files : $TEST_WORK_DIR is not git worktree"
  assert_failure
}

@test "list_git_managed_files repository_path exists(abs path)" {
  # not use run . (return value contain NULL )
  while IFS= read -r -d '' line; do
    for ((i=0; i<${#result_arr[@]}; i++)); do
      if [[ "$line" == "${result_arr[$i]}" ]]; then
        unset "result_arr[$i]"
        result_arr=("${result_arr[@]}")
        break
      fi
      if [[ $(($i+1)) == ${#result_arr[@]} ]]; then
batslib_print_kv_single 8 \
        "filepath" "$line" \
      | batslib_decorate "path does not exist in result_arr" \
      | fail
      fi
    done
  done < <(list_git_managed_files "$KAWAZU_DOTFILES_DIR")
  if [[ ${#result_arr[@]} != 0 ]]; then
    batslib_decorate "contain_result_arr"< <(
      for ((i=0; i<${#result_arr[@]}; i++)); do
        batslib_print_kv_single 8 \
        "filepath" \
        "${result_arr[$i]}"
      done
    )
    fail
  fi
}

@test "list_git_managed_files repository_path exists(rel path)" {
  cd "$KAWAZU_DOTFILES_DIR"
  # not use run . (return value contain NULL )
  while IFS= read -r -d '' line; do
    for ((i=0;i<${#result_arr[@]};i++));do
      echo "search:${result_arr[$i]}"
      if [[ "$line" == "${result_arr[$i]}" ]]; then
        unset "result_arr[$i]"
        result_arr=("${result_arr[@]}")
        break
      fi
      if [[ $(($i+1)) == ${#result_arr[@]} ]] ;then
batslib_print_kv_single 8 \
        "filepath" "$line" \
      | batslib_decorate "path does not exist in result_arr" \
      | fail
      fi
    done
  done < <(list_git_managed_files "./")
  if [[ ${#result_arr[@]} != 0 ]]; then
    batslib_decorate "contain_result_arr"< <(
      for ((i=0;i<${#result_arr[@]};i++)); do
        batslib_print_kv_single 8 \
        "filepath" \
        "${result_arr[$i]}"
      done
    )
    fail
  fi
}

@test "list_git_managed_files repository_path is directory in worktree" {
  run list_git_managed_files "$KAWAZU_DOTFILES_DIR/path/to/dir"
  assert_line -n 0 "$KAWAZU_DOTFILES_DIR/path/to/dir/file"
  assert_equal "${#lines[@]}" "1"
  assert_success
}

@test "list_git_managed_files repository_path is empty" {
  rm -rf "$KAWAZU_DOTFILES_DIR/path"
  rm -rf "$KAWAZU_DOTFILES_DIR/file"
  rm -rf "$KAWAZU_DOTFILES_DIR/submodule"
  run list_git_managed_files "$KAWAZU_DOTFILES_DIR"
  assert_output ""
  assert_success
}

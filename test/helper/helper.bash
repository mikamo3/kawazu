#!/usr/bin/bash

delete_test_dir() {
  [[ -n "$TEST_WORK_DIR" ]] && rm -rf "$TEST_WORK_DIR"
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
    git add "$target_file_path" &>/dev/null
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

assert_git_status() {
  local target_file_path="$1"
  local status="$2"
  local result
  [[ ! -L $target_file_path && ! -e $target_file_path ]] && {
    batslib_print_kv_single 8 \
      "path" "$target_file_path" \
      | batslib_decorate "file does not exist" \
      | fail
    return $?
  }
  (
    cd "$(dirname "$target_file_path")" || return 1
    result=$(git status -s "$target_file_path")

    if [[ -n "$result" ]]; then
      echo "$result" | head -n1 | grep "^$status" || {
        batslib_print_kv_single 8 \
          "path" "$target_file_path" \
          "status" "$status" \
          | batslib_decorate "git status differ" \
          | fail
      }
    fi
  )
}

# Check whether output divided by null characters exist in the array
# when it does not exist in the array. fail
# when array's value does not exist in output. fail
assert_output_contain_in_array() {
  local cmd="$1"
  local arr_name="$2"
  local expect_array=()

  #copy array
  for ((i = 0; i < $(eval "echo \${#$arr_name[@]}"); i++)); do
    expect_array+=("$(eval "echo -e \"\${$arr_name[$i]}\"")")
  done

  while IFS= read -r -d '' line; do
    local exist_flg=false
    for ((i = 0; i < ${#expect_array[@]}; i++)); do
      if [[ "$line" == "${expect_array[$i]}" ]]; then
        unset "expect_array[$i]"
        expect_array=("${expect_array[@]}")
        exist_flg=true
        break
      fi
    done

    if [[ "$exist_flg" == "false" ]]; then
      batslib_print_kv_single 8 \
        "output" "$line" \
        | batslib_decorate "output does not exist in $arr_name" \
        | fail
      return $?
    fi
  done < <(eval "$cmd")

  if [[ ${#expect_array[@]} != 0 ]]; then
    batslib_decorate "several strings in $arr_name are not output" < <(
      for ((i = 0; i < ${#expect_array[@]}; i++)); do
        batslib_print_kv_single 8 \
          "value" \
          "${expect_array[$i]}"
      done
    ) | fail
  fi
}

assert_mock_output() {
  local opt_debug_flg=false
  local opt_force_flg=false
  local opt_skip_flg=false
  while [[ $1 =~ ^- ]]; do
    local options=()
    if [[ $1 =~ ^-[a-z] ]]; then
      local param_flgs=${1:1}
      for ((i = 0; i < ${#param_flgs}; i++)); do
        options+=("${param_flgs:$i:1}")
      done
    else
      options=("${1#--}")
    fi
    for option in "${options[@]}"; do
      case $option in
      d | debug)
        opt_debug_flg=true
        continue
        ;;
      f | force)
        opt_force_flg=true
        continue
        ;;
      s | skip)
        opt_skip_flg=true
        continue
        ;;
      *)
        fail "unknown option"
        return $?
        ;;
      esac
    done
    shift
  done
  local line="$1"
  local called_function="$2"
  local output_parameters="parameters :"
  shift
  shift
  assert_line -n "$line" "called from : $called_function" || return $?
  for i in "$@"; do
    output_parameters+=" \"$i\""
  done
  assert_line -n "$((line + 1))" "$output_parameters" || return $?
  assert_line -n "$((line + 2))" "options : OPT_DEBUG=$opt_debug_flg,\
 OPT_FORCE=$opt_force_flg,\
 OPT_SKIP=$opt_skip_flg" || return $?
}

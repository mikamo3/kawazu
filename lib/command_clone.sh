#!/usr/bin/env bash
clone() {
  if [[ $# == 0 ]]; then
    print_error "${FUNCNAME[0]} : need repo [branch]"
    exit 1
  fi
  local repo=$1
  local branch=
  local clone_to_path=$KAWAZU_DOTFILES_DIR

  if [[ $# == 2 ]]; then
    branch=$2
  fi
  if [[ -e "$clone_to_path" ]]; then
    if (cd "$clone_to_path" && git rev-parse --is-inside-work-tree &>/dev/null); then
      print_info "$clone_to_path is already managed by git. skip"
      return 0
    fi
  fi

  result=$(git clone --recursive "$repo" "$clone_to_path") || {
    print_error "$result"
    return 1
  }

  print_success "clone : $repo to $clone_to_path"
  if [[ $branch ]]; then
    (
      cd "$clone_to_path" && git checkout "$branch"
      git rev-parse --verify "$branch" || git branch "$branch"
      git checkout "$branch"
      print_success "swith to branch $branch"
    )
  fi
  return 0
}

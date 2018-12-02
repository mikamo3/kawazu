#!/usr/bin/env bash
create_local_git_repository() {
  (
    git init "$1"
    cd "$1" || return 1
    git config user.name "test"
    git config user.email "test@example.com"
  )
}

create_local_git_bare_repository() {
  git init --bare "$1"
}

git_add() {
  (
    if [[ -d "$1" ]]; then
      cd "$1" || return 1
      git add -A
    else
      cd "$(dirname "$1")" || return 1
      git add "$1"
    fi
  )

}

git_commit() {
  (
    git_add "$1"
    if [[ -d "$1" ]]; then
      cd "$1" || return 1
    else
      cd "$(dirname "$1")" || return 1
    fi
    git commit -m "test commit"
  )
}

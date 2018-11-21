#!/usr/bin/env bash
run_test_partial() {
  local script_dir
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  cd "$script_dir/.." || return 1
  docker build ./ -t kawazu
  for file in "$@"; do
    docker run --rm kawazu /tmp/kawazu/"$file"
  done
}
run_test_partial "$@"

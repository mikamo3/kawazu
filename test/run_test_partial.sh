#!/usr/bin/env bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR/.." || return 1
docker build ./ -t kawazu
for file in "$@"; do
  docker run --rm kawazu /tmp/kawazu/"$file"
done

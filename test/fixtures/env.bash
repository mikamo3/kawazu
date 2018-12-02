#!/usr/bin/env bash
KAWAZU_ROOT_DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
TEST_WORK_DIR=$(mktemp -d)
HOME="$TEST_WORK_DIR/home/kawazu"
export KAWAZU_VERSION="0.1"
export KAWAZU_ROOT_DIR
export KAWAZU_DOTFILES_DIR="$TEST_WORK_DIR/.dotfiles"
export KAWAZU_BACKUP_DIR="$TEST_WORK_DIR/.backup"

export OPT_DEBUG=false
export OPT_FORCE=false
export OPT_SKIP=false

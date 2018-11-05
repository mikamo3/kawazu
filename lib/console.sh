#!/usr/bin/env bash
#console output function
readonly CL_BLACK="\E[30m"
readonly CL_RED="\E[31m"
readonly CL_GREEN="\E[32m"
readonly CL_YELLOW="\E[33m"
readonly CL_BLUE="\E[34m"
readonly CL_PURPLE="\E[35m"
readonly CL_CYAN="\E[36m"
readonly CL_WHITE="\E[37m"
readonly CL_RST="\E[0m"

print_error() {
  echo -e "${CL_RED}[✗] $1${CL_RST}"
}
print_success() {
  echo -e "${CL_GREEN}[✓] $1${CL_RST}"
}
print_info() {
  echo -e "${CL_CYAN}[i] $1${CL_RST}"
}

#!/usr/bin/env bash
#TODO: write help
command_help() {
  if [[ $# != 0 ]]; then
    "_help_$1" 2>/dev/null || {
      print_error "unknown command : $1"
      return 1
    }
  else
    cat <<EOF
Simple dotfiles manager.
Usage: kawazu [OPTION] COMMAND [ARGS ...]
Options:
  -f , --force               Overwrite files that exist
  -s , --skip                Skip files that exist
  -d , --debug               Output debug
  -v , --version             Print version

Commands:
  add FILE ...              Add files to dotfiles repository
  cd                        Change working directory to dotfiles directory
  clone URL [BRANCH]        Clone dotfiles directory to remote repository
  init [BRANCH]             Create dotfiles repository
  link [FILE ...]           Link from dotfiles to home directory
  unlink [FILE ...]         Unlink dotfiles
EOF
  fi
  return 0
}

_help_add() {
  cat <<EOF
Add files to dotfiles repository.
Usage: kawazu add FILE ...

Add files to git repository and create symbolic link to home directory.
Files added to the dotfiles repository are staged.
If the file is excluded by the .gitignore file, process will be skipped.
EOF
}

_help_clone() {
  cat <<EOF
Clone a Git repository.
Usage: kawazu clone URL [BRANCH]

Clone a Git repository as dotfiles repository.
If the BRANCH specified, swith to the specified branch. (when BRANCH does not exists. create and switch)
EOF
}

_help_cd() {
  cat <<EOF
Change working directory to dotfiles directory.
Usage: kawazu cd
EOF
}

_help_init() {
  cat <<EOF
Create dotfiles repository
Usage: kawazu init [BRANCH]

Create a Git repository as dotfiles repository.
If the BRANCH specified, create and switch to the specified branch.
EOF
}

_help_link() {
  cat <<EOF
Link from dotfiles to home directory.
Usage: kawazu link [FILE ...]

Create links in the HOME directory of files in the dotfiles repository.
If FILE is not specified, links of all files in the dotfiles repository will be created.
If already linked, skip processing
If a file with the same name exists in the HOME directory, the file is backed up and the link is created.
EOF
}

_help_unlink() {
  cat <<EOF
Unlink dotfiles
Usage: kawazu unlink [FILE ...]

Unlink link from dotfiles repository file.
If FILE is not specified, unlink all files in the dotfiles repository.
EOF
}

#!/usr/bin/env bats
load ../helper/bats-support/load
load ../helper/bats-assert/load
load ../helper/bats-file/load

GIT_LOCAL_BARE_REPOSITORY=/tmp/bare.git
ARC_MACHINE_A=/tmp/machine_a.tar.gz
ARC_MACHINE_B=/tmp/machine_b.tar.gz
ARC_MACHINE_C=/tmp/machine_c.tar.gz

setup() {
  # !! clean home directory
  find /home/kawazu -mindepth 1 | xargs rm -rf

  git config --global user.name "test"
  git config --global user.email "test@example.com"

  cd "$HOME"

  mkdir -p .kawazu/
  cp -r /tmp/kawazu .kawazu/repos
  source .kawazu/repos/kawazu.sh
}

teardown() {
  # !! when this script run at local will removed all files in home directory
  find /home/kawazu -mindepth 1 | xargs rm -rf
}

# test scenario
# machine a
#   initialize dotfiles repository
#   write some dotfiles
#   and commit
#   set remote repository
#   push to remote repository
# machime b
#   clone dotfiles repository
#   link all files
#   edit dotfiles
#   add some dotfiles
#   commit and push to remote repository
# machine a
#   pull from remote repository
#   link new dotfiles
#   edit dotfile
#   commit and push to remote repository
# machine b
#   edit dotfile (with the same name as the file edited on machine a)
#   commit
#   pull (conflict)
#   edit conflict and push to remote repository
# machine c
#   clone dotfiles repository (branch c)
#   edit dotfiles
#   add dotfiles
# machine a
#   pull from remote repository
#   edit dotfiles
#   add dotfiles (with the same name as the file added on machine c)
#   push to remote repository
# machine c
#   fetch from remote repository
#   merge from master
# machine a
# unlink all files
# machine b
# unlink all files
# machine c
# unlink all files

@test "scenario 1 : (machine a) init -> add some dotfiles -> commit it -> push to remote repos" {

  # create bare repository
  git init --bare "$GIT_LOCAL_BARE_REPOSITORY"

  # init a repository
  run kawazu init
  assert_success


  # edit some file at home directory
  echo "test file a" > .file_a
  echo "test file b" > .file_b
  mkdir -p .config/test
  echo "test file c" > .config/test/file_c

  # add sone files to repository
  run kawazu add .file_a
  assert_success

  cd .config
  run kawazu add ../.file_b
  assert_success

  run kawazu add test/file_c
  assert_success

  assert_equal "$(readlink $HOME/.file_a)" "./.kawazu/dotfiles/.file_a"
  assert_equal "$(readlink $HOME/.file_b)" "./.kawazu/dotfiles/.file_b"
  assert_equal "$(readlink $HOME/.config/test/file_c)" "../../.kawazu/dotfiles/.config/test/file_c"

  # cd to repository then commit
  kawazu cd
  assert_equal "$(pwd)" "$HOME/.kawazu/dotfiles"

  run git commit -m "test commit from machine a"
  assert_success

  #push to local bare repository
  git remote add origin "$GIT_LOCAL_BARE_REPOSITORY"
  git push origin master

  # save machine state
  cd $HOME
  tar -czf "$ARC_MACHINE_A" .
}

@test "scenario 2 : (machine b) clone from remote repos -> link from repos -> edit some exist file -> add new dotfiles -> commit it -> push to remote repos" {
  # some file exist in home directory
  touch .file_a
  run kawazu clone "$GIT_LOCAL_BARE_REPOSITORY"
  assert_success
  run kawazu link < <(echo y)
  assert_success
  assert_equal "$(readlink .file_a)" "./.kawazu/dotfiles/.file_a"
  assert_equal "$(readlink .file_b)" "./.kawazu/dotfiles/.file_b"
  assert_equal "$(readlink .config/test/file_c)" "../../.kawazu/dotfiles/.config/test/file_c"

  # edit exist file
  mkdir -p .config/test2/
  echo "test" >> .file_b
  echo "new file test_d" >> .file_d
  echo "new file test_e" >> .config/test2/file_e

  # add new file
  run kawazu add  .file_d .config/test2/file_e
  assert_success

  assert_equal "$(readlink .file_d)" "./.kawazu/dotfiles/.file_d"
  assert_equal "$(readlink .config/test2/file_e)" "../../.kawazu/dotfiles/.config/test2/file_e"

  kawazu cd
  git add .file_b
  git commit -m "test commit from machine b"
  git push origin master

  # save machine state
  cd $HOME
  tar -czf "$ARC_MACHINE_B" .
}

@test "scenario 3 : (machine a) pull from remote repos -> link -> edit exist file -> commit -> push" {
  tar -xf "$ARC_MACHINE_A"
  kawazu cd
  git branch --set-upstream-to=origin/master master
  git pull
  cd $HOME
  run kawazu link ".kawazu/dotfiles/.file_d"
  assert_success
  assert_equal "$(readlink .file_d)" "./.kawazu/dotfiles/.file_d"

  run kawazu link ".kawazu/dotfiles/.config/test2/file_e"
  assert_success
  assert_equal "$(readlink .config/test2/file_e)" "../../.kawazu/dotfiles/.config/test2/file_e"

  echo "fix on machine a" >> .file_a
  kawazu cd
  git add .file_a
  git commit -m "fix on machine a .file_a"
  git push

  # save machine state
  cd $HOME
  tar -czf "$ARC_MACHINE_A" .
}

@test "scenario 4 : (machine b) edit exist file (edit on machine a) -> commit -> pull -> fix conflict -> commit -> push" {
  tar -xf "$ARC_MACHINE_B"
  echo "fix on machine b" >> .file_a
  kawazu cd
  git add .file_a
  git commit -m "fix on machine b .file_a"

  #conflict
  git pull && fail
  echo "fix conflict" > .file_a
  git add .file_a
  git commit -m "fix conflict"
  git push

  # save machine state
  cd $HOME
  tar -czf "$ARC_MACHINE_B" .
}

@test "scenario 5 : (machine c) clone from remote repos (branch c) -> link -> add new files -> commit -> push" {
  run kawazu clone "$GIT_LOCAL_BARE_REPOSITORY" "c"
  run kawazu link
  echo "fix on machine c" >> .file_a
  echo "new file file_f" >> .file_f
  run kawazu add .file_f
  kawazu cd
  git add .file_a
  git commit -m "fix on machine c"
  git push origin c

  # save machine state
  cd $HOME
  tar -czf "$ARC_MACHINE_C" .
}

@test "scenario 6 : (machine a) pull -> edit exist file -> add new files -> commit -> push to remote repos" {
  tar -xf "$ARC_MACHINE_A"
  kawazu cd
  git pull
  cd $HOME
  echo "fix on machine a" >> .file_a
  echo "new file" >> .file_g
  echo "new file" >> .file_h
  run kawazu add .file_g .file_h
  kawazu cd
  git commit -m "add files on machine a"
  git add .file_a
  git commit -m "fix .file_a on machine a"
  git push

  # save machine state
  cd $home
  tar -czf "$ARC_MACHINE_A" .
}

@test "scenario 7 : (machine c) edit exist file -> add -> fetch -> merge from master" {
  tar -xf "$ARC_MACHINE_C"
  echo "fix on machine c" >> .file_a
  kawazu cd
  git add .file_a
  git commit -m "fix .file_a on machine c"
  git checkout master
  git pull origin master
  git checkout c
  git pull origin c
  git merge master && fail
  git checkout .file_a --theirs
  git add .file_a
  git commit -m "fix merge"
  git status
  git log --oneline
  git push origin c

  # save machine state
  cd $HOME
  tar -czf "$ARC_MACHINE_C" .
}

@test "scenario 8 : (machine a) unlink dotfiles" {
  tar -xf "$ARC_MACHINE_A"
  kawazu unlink
  assert_success
  assert [ -f .file_a ]
  assert [ -f .file_b ]
  assert [ -f .file_d ]
  assert [ ! -e .file_f ]
  assert [ -f .file_g ]
  assert [ -f .file_h ]
  assert [ -f .config/test/file_c ]
  assert [ -f .config/test2/file_e ]
}


@test "scenario 8 : (machine b) unlink dotfiles" {
  tar -xf "$ARC_MACHINE_B"
  kawazu unlink
  assert_success
  assert [ -f .file_a ]
  assert [ -f .file_b ]
  assert [ -f .file_d ]
  assert [ ! -e .file_f ]
  assert [ ! -e .file_g ]
  assert [ ! -e .file_h ]
  assert [ -f .config/test/file_c ]
  assert [ -f .config/test2/file_e ]
}


@test "scenario 8 : (machine c) unlink dotfiles" {
  tar -xf "$ARC_MACHINE_C"
  kawazu unlink
  assert_success
  assert [ -f .file_a ]
  assert [ -f .file_b ]
  assert [ -f .file_d ]
  assert [ -f .file_f ]
  assert [ ! -e .file_g ]
  assert [ ! -e .file_h ]
  assert [ -f .config/test/file_c ]
  assert [ -f .config/test2/file_e ]
}


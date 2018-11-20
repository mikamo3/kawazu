#!/usr/bin/env bash
declare -a bash_vars=(3.2 4.0 4.1 4.2 4.3 4.4)
declare -a commands=()
declare -a children_pids=()
declare exit_code=0

wait_and_get_exit_codes() {
  children=("$@")
  for job in "${children[@]}"; do
    local code=0
    wait "$job" || code=$?
    if [[ "$code" != 0 ]]; then
      exit_code=1
    fi
  done
}

for var in "${bash_vars[@]}"; do
  commands+=("{ docker build --build-arg bash_var=$var ./ -t kawazu_bash_$var ; }")
done
for command in "${commands[@]}"; do
  (
    echo "$command" | bash
  ) &
  children_pids+=($!)
done
wait_and_get_exit_codes "${children_pids[@]}"
exit $exit_code

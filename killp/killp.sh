#!/usr/bin/env bash
#
# Copyright (C) 2018 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.

if [ ! $# -eq 1 ]; then
  echo "Usage: $0 <pattern>"
  exit 1
fi

confirm () {
  while true; do
    read -p "$1 " yn
    case $yn in
      [yY]* ) return 0;;
      [nN]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}


pattern=$1

OIFS="$IFS"
IFS=$'\n'
processes=($(ps aux | grep "$pattern" | grep -v 'grep' | grep -v $0))
process_ids=()
IFS="$OIFS"

if [ "${#processes[@]}" -eq 0 ]; then
  echo "No matching processes found. Exiting ..."
  exit 1
fi

echo -e "The matched processes are:\n---"

for process in "${processes[@]}"; do
  echo "$process"
  process_id=$(echo "$process" | sed -r 's/^\w+\s+([0-9]+).*$/\1/g')
  process_ids+=( "$process_id" )
done

echo "---"

if confirm "Are you sure you want to kill all of these processes?"; then
  for process_id in "${process_ids[@]}"; do
    kill "$process_id"
  done
  exit 0
else
  echo "Exiting without killing any processes ..."
  exit 1
fi

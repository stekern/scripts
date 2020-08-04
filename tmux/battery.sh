#!/usr/bin/env bash
#
# Copyright (C) 2020 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.

set -euo pipefail
IFS=$'\n\t'

pmset -g batt | sed -n 's/^.*[[:space:]]\([[:digit:]]\{1,\}\)%.*$/\1/p'

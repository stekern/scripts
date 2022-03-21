#!/usr/bin/env bash
#
# Copyright (C) 2020 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#
# Copies the layout of the current tmux window to a new tmux window

set -euo pipefail
IFS=$'\n\t'

verify_active_tmux_session() {
	if ! [ -n "${TMUX-}" ]; then
		printf "[x] The script must be run inside a tmux session!\n"
		exit 1
	fi
}

# Creates a new tmux window with the layout of the current window
simple() {
	local layout
	local num_panes
	local target
	local first_pane

  layout="$(tmux display-message -p '#{window_layout}')"
  num_panes="$(tmux display-message -p '#{window_panes}')"
  tmux new-window

	target="$(tmux list-windows | tail -1 | sed 's/^\([[:digit:]]\{1,\}\):.*$/\1/')"
	first_pane="$(tmux list-panes | head -1 | sed 's/^\([[:digit:]]\{1,\}\):.*$/\1/')"
	for _ in $(seq $((num_panes - 1))); do
		tmux split-window -t "$target.$first_pane"
	done
	tmux select-layout -t "$target" "$layout"
	tmux select-pane -t "$target.$first_pane"
}

main() {
	verify_active_tmux_session
  simple
}

main "$@"

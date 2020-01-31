#!/usr/bin/env bash
#
# Copyright (C) 2020 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.

# Copies the layout of the current tmux window to a new tmux window

set -euo pipefail
IFS=$'\n\t'

verify_active_tmux_session() {
	if ! [ -n "${TMUX-}" ]; then
		printf "[x] The script must be run inside a tmux session!\n"
		exit 1
	fi
}

main() {
	verify_active_tmux_session

	local first_pane
	local layout
	local num_panes
	local to
	layout="$(tmux display-message -p '#{window_layout}')"
	num_panes="$(tmux display-message -p '#{window_panes}')"
	tmux new-window
	to="$(tmux list-windows | tail -1 | sed -r 's/^([0-9]+):.*$/\1/')"
	for _ in $(seq $((num_panes - 1))); do
		tmux split-window -t "$to"
	done
	first_pane="$(tmux list-panes | head -1 | sed -r 's/^([0-9]+):.*$/\1/')"
	tmux select-layout -t "$to" "$layout"
	tmux select-pane -t "$to.$first_pane"
}

main "$@"

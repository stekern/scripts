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
	local TMP_FILE="/tmp/tmux_copy_window_$(date +'%s')"
	local MAXIMUM_WAIT_IN_SECONDS="5"

	tmux command-prompt -p "Copy layout from window: ","Copy layout to window: " "run -b 'echo %1 %2 > $TMP_FILE'"
	local num_seconds="0"
	while [ ! -e "$TMP_FILE" ]; do
		if [ "$num_seconds" -gt "$MAXIMUM_WAIT_IN_SECONDS" ]; then
			printf "[x] Waited too long for response. Exiting ...\n"
			exit 1
		fi
		sleep 1
		num_seconds=$((num_seconds + 1))
	done

	local first_pane
	local layout
	local num_panes
	local target_panes
	local from
	local to

	IFS=$' ' read -r from to <<<"$(cat "$TMP_FILE")"
	# If from window is set
	if [ -n "$from" ]; then
		layout="$(tmux display-message -p -t "$from.0" '#{window_layout}')"
		num_panes="$(tmux display-message -p -t "$from.0" '#{window_panes}')"
	else
		# Use layout of current window
		layout="$(tmux display-message -p '#{window_layout}')"
		num_panes="$(tmux display-message -p '#{window_panes}')"
	fi
	# If to window is not set, create a new window
	if [ ! -n "$to" ]; then
		target_panes=1
		tmux new-window
	else
		tmux select-window -t "$to"
		target_panes="$(tmux display-message -p -t "$to.0" '#{window_panes}')"
	fi

	if [ "$target_panes" -gt "$num_panes" ]; then
		printf "[x] Target window has more panes than in the given layout\n"
		exit 1
	fi

	#to="$(tmux list-windows | tail -1 | sed -r 's/^([0-9]+):.*$/\1/')"
	for _ in $(seq $((num_panes - target_panes))); do
		tmux split-window -t "$to"
	done
	first_pane="$(tmux list-panes | head -1 | sed -r 's/^([0-9]+):.*$/\1/')"
	tmux select-layout -t "$to" "$layout"
	tmux select-pane -t "$to.$first_pane"
}

main "$@"

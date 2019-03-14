#!/usr/bin/env bash

SCRIPT_DIR=`dirname "$0"`
ENV_FILE="$SCRIPT_DIR/.env"
IP_FILE="$SCRIPT_DIR/current_ip"
MUTT_CONFIG="$SCRIPT_DIR/.muttrc"

# Load environment variables
export `cat "$ENV_FILE" | xargs -0`

if [ ! -f "$IP_FILE" ]; then
  touch "$IP_FILE"
fi

current_ip=`cat "$IP_FILE"`
new_ip=`hostname -I | sed -r "s/^(([0-9]+\.?)+) ?.*$/\1/g"`

if [[ "$new_ip" =~ ^([0-9]{,3}\.){3}[0-9]{,3}$ ]] && [ ! "$current_ip" = "$new_ip" ]; then
   echo -e "Old: $current_ip | New: $new_ip\n\nKind regards,\nMr. Mutt" | mutt -F "$MUTT_CONFIG" -d 1 -s "New IP for $DEVICE_NAME!" "$RECIPIENT" && echo "$new_ip" > "$IP_FILE"
fi

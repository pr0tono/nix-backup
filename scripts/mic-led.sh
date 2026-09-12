#!/bin/sh
set -e
LedName="platform::micmute"
MicSource="alsa_input.pci-0000_03_00.6.analog-stereo"

while true; do
	if pactl get-source-mute "$MicSource" | grep -q "no" ; then
		brightnessctl -d "$LedName" set 1 2>/dev/null || true
	else
		brightnessctl -d "$LedName" set 0 2>/dev/null || true
	fi
	sleep 1
done


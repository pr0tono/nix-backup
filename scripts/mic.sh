#!/usr/bin/env bash
# a meh mic led switcher script thingy

led="platform::micmute"
source="alsa_input.pci-0000_03_00.6.analog-stereo"

update_led() {
    if pactl get-source-mute "$source" | grep -q "Mute: no"; then
        brightnessctl -d "$led" set 1 >/dev/null
    else
        brightnessctl -d "$led" set 0 >/dev/null
    fi
}

while true; do
    update_led

    pactl subscribe |
        while read -r _; do
            update_led
        done

    sleep 1
done

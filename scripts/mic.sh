#!/usr/bin/env bash
# a meh mic led switcher script thingy

led="platform::micmute"
source="alsa_input.pci-0000_03_00.6.analog-stereo"

last_state=""

update_led() {
    local state

    if pactl get-source-mute "$source" 2>/dev/null | grep -q 'Mute: no'; then
        state=1
    else
        state=0
    fi

    if [[ "$state" != "$last_state" ]]; then
        brightnessctl -d "$led" set "$state" >/dev/null 2>&1
        last_state="$state"
    fi
}

update_led

while true; do
    if pactl subscribe 2>/dev/null |
        while IFS= read -r event; do
            case "$event" in
                *"on source #"*)
                    update_led
                    ;;
            esac
        done
    then
        :
    fi

    sleep 1
done


#!/usr/bin/env bash
# a yet another simple power profile switch script

while sleep 30; do
    battery=$(cat /sys/class/power_supply/BAT*/capacity)
    charging=$(cat /sys/class/power_supply/AC*/online)

    if [ "$charging" = "1" ] && [ "$battery" -gt 80 ]; then
        profile="performance"
    elif [ "$charging" = "0" ] && [ "$battery" -lt 40 ]; then
        profile="power-saver"
    else
        profile="balanced"
    fi

    powerprofilesctl set "$profile"
done


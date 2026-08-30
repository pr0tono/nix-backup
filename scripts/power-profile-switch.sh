#!/usr/bin/env bash

STATE_FILE="/run/power-profile-switch.last"
DEBOUNCE_SECONDS=10

now=$(date +%s)

if [ -f "$STATE_FILE" ]; then
  last=$(cat "$STATE_FILE")
  if [ $((now - last)) -lt $DEBOUNCE_SECONDS ]; then
    exit 0
  fi
fi

echo "$now" > "$STATE_FILE"

# ignore during suspend/resume storms
if [ -f /var/run/systemd/sleep/sleeping ]; then
  exit 0
fi

BAT_PATH=$(ls /sys/class/power_supply | grep BAT | head -n1)

BAT=$(cat /sys/class/power_supply/$BAT_PATH/capacity)
STATUS=$(cat /sys/class/power_supply/$BAT_PATH/status)

AC_ONLINE=0
for ps in /sys/class/power_supply/*; do
  if [ -f "$ps/online" ]; then
    AC_ONLINE=$(cat "$ps/online")
  fi
done

if [ "$STATUS" = "Charging" ] || [ "$AC_ONLINE" = "1" ]; then
  if [ "$BAT" -ge 70 ]; then
    powerprofilesctl set performance
  else
    powerprofilesctl set balanced
  fi
else
  if [ "$BAT" -le 40 ]; then
    powerprofilesctl set power-saver
  else
    powerprofilesctl set balanced
  fi
fi

{ config, pkgs, ... }:

let
  powerProfileScript = pkgs.writeShellScript "power-profile-switch" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

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

    if [ -f /var/run/systemd/sleep/sleeping ]; then
      exit 0
    fi

    BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
    if [ -z "$BAT_PATH" ]; then
      exit 0
    fi
    
    BAT_NAME=$(basename "$BAT_PATH")

    if [ -f "$BAT_PATH/capacity" ] && [ -f "$BAT_PATH/status" ]; then
      BAT=$(cat "$BAT_PATH/capacity")
      STATUS=$(cat "$BAT_PATH/status")
    else
      exit 0
    fi

    AC_ONLINE=0
    for ps in /sys/class/power_supply/*; do
      if [ -f "$ps/online" ]; then
        val=$(cat "$ps/online" 2>/dev/null || echo "0")
        if [ "$val" = "1" ]; then
          AC_ONLINE=1
          break
        fi
      fi
    done

    if [ "$STATUS" = "Charging" ] || [ "$AC_ONLINE" = "1" ]; then
      if [ "$BAT" -ge 70 ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      fi
    else
      if [ "$BAT" -le 40 ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      fi
    fi
  '';
in {
  systemd.services.power-profile-switch = {
    description = "Automatic power profile switching based on battery/AC";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = powerProfileScript;
    };
    after = [ "multi-user.target" ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-switch.service"
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-switch.service"
    SUBSYSTEM=="power_supply", KERNEL=="BAT*", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-switch.service"
  '';
}   

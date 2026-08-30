{ pkgs, ...}: {
  home.file.".config/mic-led.sh" = {
    executable = true;
    text = ''
      #!/run/current-system/sw/bin/bash
      set -e
      
      LED_NAME="platform::micmute"
      MIC_SOURCE="alsa_input.pci-0000_03_00.6.analog-stereo"

      while true; do
        if pactl get-source-mute "$MIC_SOURCE" | grep -q "no"; then
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$LED_NAME" set 1 2>/dev/null || true
        else
          ${pkgs.brightnessctl}/bin/brightnessctl -d "$LED_NAME" set 0 2>/dev/null || true
        fi
        sleep 1
      done
    '';
  };

  systemd.user.services.mic-led = {
    Unit = {
      Description = "Microphone LED Status Indicator";
      After = [ "pipewire.service" "wireplumber.service" "pipewire-pulse.service" ];
      Wants = [ "pipewire.service" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "/home/protono/.config/mic-led.sh";
      Path = [ "${pkgs.brightnessctl}/bin" "${pkgs.pulseaudio}/bin" "${pkgs.bash}/bin" ];
      Restart = "always";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

}

{ config, pkgs, ... }: {
  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      colors = true;
      interval = 1;
      output_format = "i3bar";
    };

    modules = {
      "wireless wlp1s0" = {
      enable = true;
      position = 1;
      settings = {
        format_up = "󰖩";
        format_down = "󰖪";
        };
      };
      "ethernet eth0" = {
        enable = true;
        position = 2;
        settings = {
          format_up = "";
          format_down = "";
        };
      };
      "ethernet enp4s0f4u1" = {
        enable = true;
        position = 2;
        settings = {
          format_up = "";
          format_down = "";
        };
       };
      "battery 0" = {
        position = 3;
        settings = {
          format = "%percentage %remaining";
        };
      };
      "volume master" = {
        position = 4;
        settings = {
          format = "Vol %volume";
          format_muted = "Vol muted (%volume)";
          device = "default";
          mixer = "Master";
        };
      };
      "tztime local" = {
        position = 5;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}

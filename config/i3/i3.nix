{ config, pkgs, ... }: {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    config = {
      modifier = "Mod1";
      fonts = {
        names = [ "Maple Mono NF CN" ];
        size = 8.0;
      };
      keybindings = {
        "Mod1+Return" = "exec kitty";
        "Mod1+Shift+0" = "exec /etc/nixos/scripts/chooser.sh";
        "Mod1+w" = "exec librewolf";
        "Mod1+e" = "exec --no-startup-id kitty -e yazi";
        "Mod1+v" = "exec codium";
        "Mod1+t" = "exec tor-browser";
        "Mod1+Shift+q" = "kill";
        "Print" = "exec --no-startup-id scrot -s -e 'xclip -selection clipboard -t image/png -i $f && mkdir -p ~/Pictures/Screenshots && mv $f ~/Pictures/Screenshots/ && notify-send Screenshot'";
        "Shift+Print" = "exec --no-startup-id scrot -e 'xclip clipboard -t image/png -i $f && mkdir -p ~/Pictures/Screenshots && mv $f ~/Pictures/Screenshots/ && notify-send Screenshot'";
        "Mod1+space" = "exec i3-dmenu-desktop --dmenu=\"dmenu -i -b -fn 'Poppins:size=9' -nb '#1e1e2e' -nf '#cdd6f4' -sb '#f5e0dc' -sf '#1e1e2e'\"";

        "Mod1+h" = "focus left";
        "Mod1+j" = "focus down";
        "Mod1+k" = "focus up";
        "Mod1+l" = "focus right";
        "Mod1+Left" = "focus left";
        "Mod1+Down" = "focus down";
        "Mod1+Up" = "focus up";
        "Mod1+Right" = "focus right";

        "Mod1+Shift+h" = "move left";
        "Mod1+Shift+j" = "move down";
        "Mod1+Shift+k" = "move up";
        "Mod1+Shift+l" = "move right";

        "Mod1+Shift+f" = "fullscreen toggle";
        "Mod1+Shift+s" = "layout stacking";
        "Mod1+Shift+e" = "layout toggle split";
        "Mod1+Shift+v" = "floating toggle";

        "Mod1+1" = "workspace number 1";
        "Mod1+2" = "workspace number 2";
        "Mod1+3" = "workspace number 3";
        "Mod1+4" = "workspace number 4";
        "Mod1+5" = "workspace number 5";
        "Mod1+6" = "workspace number 6";
        "Mod1+7" = "workspace number 7";
        "Mod1+Control+Right" = "workspace next";
        "Mod1+Control+Left" = "workspace prev";

        "Mod1+Shift+1" = "move container to workspace number 1";
        "Mod1+Shift+2" = "move container to workspace number 2";
        "Mod1+Shift+3" = "move container to workspace number 3";
        "Mod1+Shift+4" = "move container to workspace number 4";
        "Mod1+Shift+5" = "move container to workspace number 5";
        "Mod1+Shift+6" = "move container to workspace number 6";
        "Mod1+Shift+7" = "move container to workspace number 7";

        "Mod1+Shift+r" = "reload";

        "Mod1+Shift+m" =
          "exec \"i3-nagbar -t warning -m 'Do you really want to exit the grind?' -B 'Yes, exit ts' 'i3-msg exit'\"";

        "Mod1+r" = "mode resize";

        "XF86AudioRaiseVolume" =
          "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && killall -SIGUSR1 i3status";

        "XF86AudioLowerVolume" =
          "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && killall -SIGUSR1 i3status";

        "XF86AudioMute" =
          "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && killall -SIGUSR1 i3status";

        "XF86AudioMicMute" =
          "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && killall -SIGUSR1 i3status";

        "XF86MonBrightnessUp" =
          "exec brightnessctl set +5%";

        "XF86MonBrightnessDown" =
          "exec brightnessctl set 5%-";
      };

      gaps = {
        inner = 2;
        outer = 1;
        smartGaps = true;
      };
      colors = {
        focused = {
          border = "#f5e0dc";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5e0dc";
          childBorder = "#f5e0dc";
        };
        focusedInactive = {
          border = "#6c7086";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5e0dc";
          childBorder = "#6c7086";
        };
        unfocused = {
          border = "#6c7086";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5e0dc";
          childBorder = "#6c7086";
        };
        urgent = {
          border = "#f9e2af";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#6c7086";
          childBorder = "#f9e2af";
        };
        placeholder = {
          border = "#6c7086";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#6c7086";
          childBorder = "#6c7086";
        };
        background = "#1e1e2e";
      };
      bars = [
        {
          statusCommand = "${pkgs.i3status}/bin/i3status";

          fonts = {
            names = [ "Maple Mono NF CN" ];
            size = 8.0;
          };

          colors = {
            background = "#1e1e2e";
            statusline = "#cdd6f4";
            focusedStatusline = "#cdd6f4";
            focusedSeparator = "#1e1e2e";

            focusedWorkspace = {
              border = "#1e1e2e";
              background = "#f5e0dc";
              text = "#11111b";
            };

            activeWorkspace = {
              border = "#1e1e2e";
              background = "#585b70";
              text = "#cdd6f4";
            };

            inactiveWorkspace = {
              border = "#1e1e2e";
              background = "#1e1e2e";
              text = "#cdd6f4";
            };

            urgentWorkspace = {
              border = "#1e1e2e";
              background = "#f9e2af";
              text = "#11111b";
            };
          };
        }
      ];
      modes = {
        resize = {
          h = "resize shrink width 10 px or 10 ppt";
          j = "resize grow height 10 px or 10 ppt";
          k = "resize shrink height 10 px or 10 ppt";
          l = "resize grow width 10 px or 10 ppt";

          Left = "resize shrink width 10 px or 10 ppt";
          Down = "resize grow height 10 px or 10 ppt";
          Up = "resize shrink height 10 px or 10 ppt";
          Right = "resize grow width 10 px or 10 ppt";

          Return = "mode default";
          Escape = "mode default";
          "Mod1+r" = "mode default";
        };
      };

      startup = [
        {
          command = "dex --autostart --environment i3";
          notification = false;
        }
        {
          command = 
          "feh --bg-scale /etc/nixos/config/i3/pine.jpg";
          notification = false;
        }
        {
          command =
            "udiskie --notify --automount";
          notification = false;
        }
      ];
    };
  };
    home.packages = with pkgs; [
    xss-lock
    udiskie
    scrot
    xclip
    brightnessctl
  ];
}


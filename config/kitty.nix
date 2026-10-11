{ pkgs, ... }: {
  catppuccin.kitty.enable = true;
  programs.kitty = {
    enable = true;
    font = { name = "Maple Mono NF CN"; size = 11; };
    shellIntegration.mode = "enabled";
    settings = {
      enabled_layouts = "splits";
      background_opacity = "0.85";
      cursor_shape = "block";
      enable_audio_bell = false;
      window_padding_width = 10;
      confirm_os_window_close = 0;
    };
    keybindings = {
      "f4" = "launch --location=split";

      "shift+up" = "move_window up";
      "shift+left" = "move_window left";
      "shift+right" = "move_window right";
      "shift+down" = "move_window down";

      "ctrl+left" = "neighboring_window left";
      "ctrl+right" = "neighboring_window right";
      "ctrl+up" = "neighboring_window up";
      "ctrl+down" = "neighboring_window down";
    };
  };
}   

{ pkgs, ... }: {
  catppuccin.kitty.enable = true;
  programs.kitty = {
    enable = true;
    font = { name = "Maple Mono NF CN"; size = 11; };
    settings = {
      cursor_shape = "block";
      enable_audio_bell = false;
      window_padding_width = 10;
      confirm_os_window_close = 0;
    };
  };
}   

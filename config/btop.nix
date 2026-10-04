{ pkgs, ...}: {
  catppuccin.btop.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      update_ms = 100;
      check_temp = true;
      shown_boxes = "cpu mem net proc";
    };
  };
}

{ pkgs , ... }: {
  catppuccin.rofi.enable = true;
  programs.rofi = {
    enable = true;
    font = "Maple Mono NF CN";
    package = pkgs.rofi;
    modes = [
      "drun"
      "run"
      "ssh"
      "keys"
    ];
  };
}

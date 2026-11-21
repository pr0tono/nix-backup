{ pkgs, nixcord, inputs, ... }: {
  imports = [
    inputs.catppuccin-nix.homeModules.catppuccin
    nixcord.homeModules.nixcord
    "${inputs.self}/common.nix"
    "${inputs.self}/modules/lang.nix"
    "${inputs.self}/modules/opsec-shit.nix"
    "${inputs.self}/modules/apps.nix"
    "${inputs.self}/config/main.nix"
  ];
    
  catppuccin = {
    flavor = "mocha";
    accent = "rosewater";
    autoEnable = false;
    enable = true;
  };
  home.sessionVariables.EDITOR = "vim";
  home.packages = with pkgs; [
    alsa-lib
    cbonsai
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    pipes
    qemu
    spotdl
    streamlink
    virt-viewer
  ];

  home.stateVersion = "26.05";
}

{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = ""; 
      plugins = [
        "git"
        "z"
        "extract"
      ];
    };
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    shellAliases = {
      clear = "clear; fastfetch";
      rebuild = "doas nixos-rebuild switch --flake /etc/nixos#vivobook-16";
      upd = "doas nix flake update --flake /etc/nixos/ ; doas nixos-rebuild switch --flake /etc/nixos#vivobook-16";
      ll = "ls -l";
      la = "ls -a";
      bad_apple = "mpv --vo=caca /home/protono/old_shit/bad_apple.webm --volume=80";
      doom = "doomretro /etc/nixos/config/doom1.wad";
      weather = "curl wttr.in";
      backup = "sh /etc/nixos/scripts/nixos-backup.sh";
    };
    initContent = ''
      fastfetch 
    '';

    sessionVariables = {
      PATH = "$HOME/.local/bin:$PATH";
    };
  };
}   

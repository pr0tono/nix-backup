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
      weather = "curl wttr.in";
      backup = "sh /etc/nixos/scripts/nixos-backup.sh";
      nsearch = "nh search";
    };
    initContent = ''
      fastfetch 
    '';

    sessionVariables = {
      PATH = "$HOME/.local/bin:$PATH";
    };
  };
}   

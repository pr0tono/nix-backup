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
      mc = "cd mc; java -Xms4G -Xmx8G -jar paper.jar";
      rebuild = "doas nixos-rebuild switch --flake /etc/nixos#vivobook-16";
      upd = "doas nix flake update --flake /etc/nixos/ ; doas nixos-rebuild switch --flake /etc/nixos#vivobook-16";
      ll = "ls -l";
      la = "ls -la";
      camview = "bash /bin/camview.sh";
      bad_apple = "mpv --vo=caca /home/protono/old_shit/bad_apple.webm --volume=80";
      doom = "doomretro ~/.config/doom1.wad";
      tv = "bash /bin/iptv.sh";
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

  home.packages = with pkgs; [
    starship
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}   

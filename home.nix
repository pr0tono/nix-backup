{ pkgs, nixcord, inputs, ... }: {
  imports = [
    inputs.catppuccin-nix.homeModules.catppuccin
    nixcord.homeModules.nixcord
    ./modules/lang.nix
    ./modules/opsec-shit.nix   
    ./modules/apps.nix
    ./config/main.nix
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
    android-tools
    blender
    calc
    cbonsai
    chroma
    cliphist
    ddnet
    deluge
    dunst
    elinks
    feh
    ffmpeg
    fzf
    gh
    gimp
    git
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    irssi
    jq
    krita
    libnotify
    libreoffice
    localsend
    meow
    mpv
    ncdu
    nh
    ollama
    p7zip 
    pamixer
    pavucontrol
    picom
    pipes
    pulseaudio
    qemu
    spotdl
    streamlink
    system-config-printer
    tor-browser
    unrar
    unzip
    virt-viewer
    winetricks
    wineWow64Packages.stable
    yt-dlp
    zip
  ];

  home.stateVersion = "26.05";
}

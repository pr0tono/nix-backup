{ pkgs, nixcord, inputs, ... }: {
  imports = [
    inputs.catppuccin-nix.homeModules.catppuccin
    nixcord.homeModules.nixcord
    ./modules/mic-led.nix
    ./modules/lang.nix
    ./modules/opsec-shit.nix   
    ./modules/python.nix
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
    calc
    cbonsai
    chroma
    cliphist
    ddnet
    deluge
    doomretro
    dunst
    feh
    ffmpeg
    fluffychat
    fzf
    gh
    gimp
    git
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    irssi
    itch
    jq
    kdePackages.kdenlive
    krita
    libnotify
    libreoffice
    localsend
    meow
    mpv
    ncdu
    obs-studio
    obsidian
    ollama
    onionshare
    openspades
    p7zip 
    pamixer
    pavucontrol
    picom
    pipes
    prismlauncher
    protonup-qt
    pulseaudio
    pysolfc
    qemu
    spotdl
    streamlink
    system-config-printer
    tor-browser
    unrar
    unzip
    virt-viewer
    waydroid
    waydroid-helper
    whatsie
    winetricks
    wineWow64Packages.stable
    yt-dlp
    zip
  ];

  home.stateVersion = "26.05";
}

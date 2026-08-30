{ pkgs, helium-nix, nixcord, inputs, ... }:

{
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
    asusctl
    calc
    cava
    cbonsai
    chroma
    cliphist
    doomretro
    dunst
    feh
    ffmpeg
    fluffychat
    fzf
    gh
    gimp
    git
    helium-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    impala
    irssi
    itch
    jq
    kdePackages.kdenlive
    krita
    libnotify
    localsend
    lrcsnc
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
    prismlauncher
    proton-vpn-cli
    protonup-qt
    pulseaudio
    pysolfc
    qbittorrent
    qemu
    spotdl
    system-config-printer
    tor-browser
    unrar
    unzip
    virt-manager
    virt-viewer
    whatsie
    winetricks
    wineWow64Packages.stable
    yt-dlp
    zip
  ];

  home.stateVersion = "26.05";
}

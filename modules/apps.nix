{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    blender
    doomretro
    android-tools
    system-config-printer
    krita
    libreoffice
    localsend
    gimp
    dosbox
    ddnet
    tor-browser
    fluffychat
    itch
    obs-studio
    obsidian
    onionshare
    openspades
    prismlauncher
    pysolfc
    renpy
    thunderbird
    waydroid
    whatsie
  ];
}

{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    android-tools
    blender
    ddnet
    doomretro
    dosbox
    fluffychat
    gimp
    itch
    krita
    libreoffice
    localsend
    obs-studio
    obsidian
    onionshare
    openspades
    prismlauncher
    pysolfc
    renpy
    system-config-printer
    thunderbird
    tor-browser
    waydroid
    whatsie
  ];
}

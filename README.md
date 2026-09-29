<h2 align="center"> Protono's Nixos Config</h2>
<p align="center">
<img src="./config/example/NixConfig.png"></p>

**Components**

| | Program |
| ------ | ---------------------------------------- |
| Terminal Emulator | [Kitty](https://github.com/kovidgoyal/kitty)|
| Shell | [Zsh](https://www.zsh.org) + [Starship](https://github.com/starship/starship) |
| File Manager  | [Yazi](https://github.com/sxyazi/yazi) |
| Browser | [Librewolf](https://librewolf.net/) |
| Windows Manager | [Sway](https://swaywm.org/) |
| Application Launcher | [Rofi](https://github.com/davatorium/rofi) |
| Text Editor | [Vscodium](https://github.com/VSCodium/vscodium) + [Vim](https://www.vim.org/) |
| Color Scheme | [Catppuccin Mocha Rosewater](https://catppuccin.com/) |
| System Resource Monitor | [Btop](https://github.com/aristocratos/btop) |
| Fonts | [Maple Mono NF CN](https://github.com/subframe7536/Maple-font) |

**Shell Aliases**

| Alias | Command |
| ----- | ------- |
| **nsearch** | nh search |
| **rebuild** | doas nixos-rebuild switch --flake /etc/nixos#vivobook-16 |
| **clear** | clear; fastfetch |
| **upd** | doas nix flake update --flake /etc/nixos/ ; doas nixos-rebuild switch --flake /etc/nixos#vivobook-16 |
| **weather** | curl wttr.in |
| **backup** | sh /etc/nixos/scripts/nixos-backup.sh 

**TODO:**
- [  ] finish the readme
- [  ] add theme swapping in real time to the config
- [  ] try to take care of this lil repo thingy

**Sources:** \
Wallpaper: https://github.com/orangci/walls-catppuccin-mocha/blob/master/pine.jpg

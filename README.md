<h2 align="center"> Protono's Nix Config</h2>
Recommended hardware:
About 6gb of ram (for the installation the os uses about a gb in standby)\
50gb of usable space\
an okay cpu\

Os uses about 1 gb of ram in standby

**TODO:**
- [  ] finish the readme
- [  ] add theme swapping in real time to the config
- [  ] try to take care of this lil repo thingy

##Components

|        |   |
| ------ | ---------------------------------------- |
| Terminal Emulator | [Kitty](https://github.com/kovidgoyal/kitty)|
| Shell | [Zsh](https://www.zsh.org) |
| File Manager  | [Yazi](https://github.com/sxyazi/yazi) |
| Browser: | [Librewolf](https://librewolf.net/) |
| Windows Manager | [Sway](https://swaywm.org/) |
| Application Launcher | [Rofi](https://github.com/davatorium/rofi) |
| Text Editor | [Vscodium](https://github.com/VSCodium/vscodium) + [Vim](https://www.vim.org/) |
| Color Scheme | [Catppuccin Mocha Rosewater](https://catppuccin.com/) |
| System Resource Monitor | [Btop](https://github.com/aristocratos/btop) |
| Fonts | [Maple Mono NF CN](https://github.com/subframe7536/Maple-font) |

**Shell Aliases:**
| Alias | Command |
| ------ | -------------------------------------------------------------- |
| *nsearch* | nh search |
| *rebuild* | doas nixos-rebuild switch --flake /etc/nixos#vivobook-16 |
| *clear* | clear; fastfetch |

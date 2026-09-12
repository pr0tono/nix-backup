#!/bin/sh
grep "^bindsym" ~/.config/i3/config \
    | sed 's/bindsym //;s/^\s\+//' \
    | fzf --prompt="i3 keybinds: " --border --height 60%

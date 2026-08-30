#!/bin/sh
mkdir -p ~/nix-backup
cp -r /etc/nixos/* ~/nix-backup/
printf "What do you want to name the commit? "
read com
cd ~/nix-backup
git add .
git commit -m "$com"   
cd ~/nix-backup || return
git push origin master

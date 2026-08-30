#!/bin/sh
# a simple script that (I hope) automates commiting changes of my nixos config onto the github repository to forgive my clumsiness :3
mkdir -p ~/nix-backup
cp -r /etc/nixos/* ~/nix-backup/
printf "What do you want to name the commit? "
read com
cd ~/nix-backup
git init
git add .
git commit -m "$com"
cd ~/nix-backup || return
git push origin master

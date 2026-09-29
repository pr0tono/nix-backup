#!/usr/bin/env bash
set -euo pipefail
echo "WARNING THIS SCRIPT WILL DELETE YOUR EXISTING NIXOS CONFIG!"
read -rp "continue? (y/N) " init
if [ "$init" = y ]
 then :
	sudo rm -rf /etc/nixos/
	sudo mkdir -p /etc/nixos/
	sudo nixos-generate-config
	sudo rm /etc/nixos/configuration.nix
	nix-shell -p git --run 'sudo git clone https://github.com/pr0tono/nix-backup.git /etc/nixos/ -f'
	sudo nixos-rebuild switch --flake /etc/nixos/#vivobook-16
	read -rp "reboot? (y/N) " opt
	 if [ "$opt" = y ] 
	 then : systemctl reboot
	 else : exit
	 fi
else : exit
fi



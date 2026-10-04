#!/urs/bin/env bash
# a simple script that (I hope) automates commiting changes of my nixos config onto the github repository
set -Eeuo pipefail
url="git@github.com:pr0tono/nix-backup.git"
mkdir -p ~/nix-backup
cd ~/nix-backup
git init
if git remote get-url origin >/dev/null 2>&1; then
	git remote set-url origin "$url"
else
	git remote add origin "$url"
fi
find ~/nix-backup -mindepth 1 -maxdepth 1 ! -name '.git' ! -name '.gitignore' -exec rm -rf {} +
cp -r /etc/nixos/* ~/nix-backup/
git add .
if [ "$#" -gt 0 ]; then
	com="$*"
else
	printf "What do you want to name the commit? "
	read com
fi

if [ -z "$com" ]; then
	printf 'Commit != empty. \n'
	exit 1
fi
git add -A
git commit -m "$com"
git push -u origin master

#!/bin/bash
#
# Author: Luca Cotti <lucacotti@outlook.com>

REPO='https://github.com/LucaCtt/dotfiles'
USERNAME='Luca Cotti'
EMAIL='lucacotti@outlook.com'
PKG_LIST="$HOME/pkglist.txt"

trap INT
cd $HOME

# basic stuff
sudo pacman -Syu git gvim code kitty

# git
git config --global user.name $USERNAME
git config --global user.email $EMAIL

# yay 
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -r yay

# dotfiles
git init --bare ~/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config status.showUntrackedFiles no
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME remote add origin $REPO
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME update-index --assume-unchange README.md
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME update-index --assume-unchange LICENSE
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull origin master

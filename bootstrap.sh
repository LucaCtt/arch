#!/bin/bash
#
# USAGE
#   ./bootstrap.sh <installation-type>
#
# DESCRIPTION
#   This script handles the installation of userspace packages
#   and configuration on Arch Linux, according to the selected
#   installation type.
#   At the moment it does not install/config anything
#   system related, such as drivers, partitions, users, groups, and so on.
#
#   To run, this script requires an Internet connection and sudo
#   to be installed. Also, the current user must NOT be root.
#   If the user is root (in particular, if the EUID is 0), the script
#   will exit with a non-zero code.
#
# INSTALLATION TYPES
#   - basic: just a few basic tools. No DE/WM.
#
# AUTHOR
#   Luca Cotti <lucacotti@outlook.com>
#
# LICENSE
#   MIT license.

username="Luca Cotti"
email="lucacotti@outlook.com"
dotfiles_repo="https://github.com/LucaCtt/dotfiles"
dotfiles_dir="$HOME/.dotfiles/"
pkgs_basic="git vim zsh"
tmp="/tmp/bootstrap.$RANDOM.$RANDOM.$RANDOM.$$"
installation_type="$1"

cleanup() {
    if [ -d $tmp ]  
    then
        rm -r "$tmp"
    fi
}

err() {
    echo "$1"
    exit 1
}

dot() {
    git --git-dir="$dotfiles_dir" --work-tree="$HOME" "$@" > /dev/null
}

basic() {
    echo "Installing basic packages..."
    sudo pacman -Syuq --needed $pkgs_basic

    echo "Configuring git..."
    git config --global user.name "$username"
    git config --global user.email "$email"

    echo "Installing yay..."
    cd "$tmp"
    git clone -q https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd .. && rm -r yay
    cd "$HOME"

    echo "Installing dotfiles from $dotfiles_repo..."
    git init -q --bare $dotfiles_dir
    dot config status.showUntrackedFiles no
    dot remote add origin $dotfiles_repo
    dot update-index --assume-unchanged README.md LICENSE
    dot pull origin master
}

set -o errexit -o nounset -o noclobber -o pipefail
shopt -s nullglob
trap "cleanup; exit" EXIT INT TERM

if [ "$EUID" -eq 0 ]
then
    err "Please do not run this script as root."
fi

if [ ! -x "$(command -v sudo)" ]
then
    err "Please install sudo before running this script. Do NOT run the script itself as root/sudo."
fi

(umask 077 && mkdir "$tmp") || {
  err "Could not create temporary directory."
}

case "$installation_type" in
"basic")
    basic
;;
"")
    err "Please specify the installation type."
;;
*)
    err "Unrecognized installation type."
;;
esac

cleanup
echo "Done."
exit 0


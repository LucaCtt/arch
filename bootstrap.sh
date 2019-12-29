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

USERNAME='Luca Cotti'
EMAIL='lucacotti@outlook.com'
DOTFILES_REPO='https://github.com/LucaCtt/dotfiles'
DOTFILES_DIR="$HOME/.dotfiles/"
PKGS_BASIC='git gvim code kitty'
TMP="/tmp/bootstrap.$RANDOM.$RANDOM.$RANDOM.$$"

cleanup() {
    echo "Cleaning up..."
    if [ -d $TMP ]  
    then
        rm -r "$TMP"
    fi
}

err() {
    echo "$1"
    exit 1
}

dot() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@" > /dev/null
}

basic() {
    echo 'Installing basic packages...'
    sudo pacman -Syuq --needed "$PKGS_BASIC"

    echo 'Configuring git...'
    git config --global user.name "$USERNAME"
    git config --global user.email "$EMAIL"

    echo 'Installing yay...'
    cd "$TMP"
    git clone -q https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd .. && rm -r yay
    cd "$HOME"

    echo "Installing dotfiles from $DOTFILES_REPO..."
    git init -q --bare $DOTFILES_DIR
    dot config status.showUntrackedFiles no
    dot remote add origin $DOTFILES_REPO
    dot update-index --assume-unchanged README.md LICENSE
    dot pull origin master
}

trap "cleanup; exit" EXIT INT TERM
set -o errexit -o nounset -o noclobber -o pipefail
shopt -s nullglob

if [ "$EUID" -eq 0 ]
then
    err "Please do not run this script as root."
fi

if [ ! -x "$(command -v sudo)" ]
then
    err 'Please install sudo before running this script. Do NOT run the script itself as root/sudo.'
fi

(umask 077 && mkdir "$TMP") || {
  err "Could not create temporary directory."
}

cd "$HOME"

case "$1" in
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


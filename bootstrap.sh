#!/bin/bash
#
# USAGE
#   ./bootstrap.sh <installation-type>
#
# DESCRIPTION
#   This script handles the installation of userspace packages
#   and configuration on Arch Linux, according to the selected
#   installation type.
#   It does not setup anything system related,
#   such as drivers, partitions, users, groups, and so on.
#
#   To run, this script requires an Internet connection and sudo
#   to be installed. Also, the current user must NOT be root.
#   If the user is root (in particular, if the EUID is 0), the script
#   will exit with a non-zero code.
#
# INSTALLATION TYPES
#   - basic: just a few basic tools. No DE/WM.
#   - gnome: basic + gnome + gnome applications
#
# AUTHOR
#   Luca Cotti <lucacotti@outlook.com>
#
# LICENSE
#   MIT license.

readonly dotfiles_repo="https://github.com/LucaCtt/dotfiles"
readonly dotfiles_dir="${HOME}/.dotfiles/"
readonly dotfiles_ignore=("${HOME}/README.md" "${HOME}/LICENSE")
readonly pkgs_basic=(git vim zsh)
readonly pkgs_gnome=(gnome gnome-extra code gvim)
readonly tmp=$(mktemp -d -t -q "bootstrap.XXXXXXXXXX")
readonly installation_type="$1"

readonly color_light_blue='\033[1;34m'
readonly color_red='\033[0;31m'
readonly color_nc='\033[0m' 

# Logs the arguments to stdout, using some formatting.
# ARGS:
#   $*: The values to log.
log() {
    echo -e "${color_light_blue}> ${*}${color_nc}"
}

# Logs the arguments to stderr with some formatting, then exits with a non-zero code.
# ARGS:
#   $*: The values to log.
err() {
    echo -e "${color_red}${*}${color_nc}" >&2
    exit 1
}

# Alias for git, to use for dotfiles.
dot() {
    git --git-dir="$dotfiles_dir" --work-tree="$HOME" "$@"
}

# Removes temp directory.
cleanup() {
    if [ -d "$tmp" ]  
    then
        /bin/rm -rf "$tmp"
    fi
}

# Executes basic installation.
basic() {
    local yay_dir="${tmp}/yay"

    log "Installing basic packages..."
    sudo pacman -Syuq --noconfirm --needed "${pkgs_basic[@]}"

    if [ ! -x "$(command -v yay)" ]
    then
        log "Installing yay..."
        git clone --quiet https://aur.archlinux.org/yay.git "$yay_dir"
        (
            cd "$yay_dir"
            makepkg -si --needed --clean --noconfirm 
        )
    fi

    log "Installing dotfiles from $dotfiles_repo..."
    git init --quiet --bare "$dotfiles_dir"
    dot config status.showUntrackedFiles no
    dot remote add origin "$dotfiles_repo"
    dot pull origin master
    dot update-index --assume-unchanged "${dotfiles_ignore[@]}"
}

# Executes gnome installation
gnome() {
    log "Installing gnome..."
    sudo pacman -Syuq --noconfirm --needed "${pkgs_gnome[@]}"
    sudo systemctl enable gdm
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

if [ ! -d "$tmp" ]
then
    err "Could not create temporary directory."
fi

case "$installation_type" in
"basic")
    basic
;;
"gnome")
    basic
    gnome
;;
"")
    err "Please specify the installation type."
;;
*)
    err "Unrecognized installation type."
;;
esac

log "Done."
exit 0


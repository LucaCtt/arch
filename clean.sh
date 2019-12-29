#!/bin/bash
#
# This script cleans various temp dirs and caches.

del() {
    /bin/rm -rf "$@"
}

trap 'exit 0' INT
set -o errexit -o nounset -o noclobber -o pipefail
shopt -s nullglob

del ~/Downloads/*
del ~/.local/share/Trash/files
del ~/.local/share/Trash/info
del ~/.zsh_history
del ~/.bash_history

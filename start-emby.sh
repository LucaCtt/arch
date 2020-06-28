#!/bin/bash
#
# USAGE
#   ./start-emby.sh [--ui]
#
# DESCRIPTION
#   This is a wrapper around the "start-emby.ts" Deno script.
#   Please refer to it for documentation.
#
# AUTHOR
#   Luca Cotti <lucacotti@outlook.com>
#
# LICENSE
#   MIT License

readonly color_red='\033[0;31m'
readonly color_nc='\033[0m' 

if [ ! -x "$(command -v deno)" ]
then
    echo -e "${color_red}ERROR: Deno is not installed.${color_nc}" >&2
    exit 1
fi

deno run --allow-run start-emby.ts $*

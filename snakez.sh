#!/bin/sh
echo -ne '\033c\033]0;snakez\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/snakez.x86_64" "$@"

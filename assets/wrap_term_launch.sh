#!/usr/bin/env sh

cat ~/.local/state/caelestia/sequences.txt 2>/dev/null

export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

exec "$@"

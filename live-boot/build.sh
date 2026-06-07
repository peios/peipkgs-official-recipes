#!/bin/sh
set -eu

cd "$SOURCE_DIR"
mkdir -p "$DESTDIR/system/boot/prelude/hooks"
cp live-boot/mount-root.sh "$DESTDIR/system/boot/prelude/hooks/mount-root.sh"

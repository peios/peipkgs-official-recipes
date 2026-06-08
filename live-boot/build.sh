#!/bin/sh
set -eu

cd "$SOURCE_DIR"
mkdir -p "$DESTDIR/boot/initramfs/hooks"
cp live-boot/mount-root.sh "$DESTDIR/boot/initramfs/hooks/mount-root.sh"
install -D -m 0644 live-boot/cmdline "$DESTDIR/boot/cmdline"

#!/bin/sh
# Peios kernel build recipe.
#
# pkm's kernel Makefile runs the build inside Docker:
#   1. docker build         -> builds an image with clang + ccache + Linux source
#                              + the PKM subtree integrated.
#   2. docker run           -> compiles the kernel inside the image, writes
#                              bzImage to $SOURCE_DIR/kernel/out/.
#
# We invoke that Makefile from $SOURCE_DIR/kernel and copy the resulting
# bzImage into $DESTDIR/boot/vmlinuz.
#
# The peipkg-build sandbox has no HOME. Docker writes per-user config to
# ~/.docker/config.json; without HOME it tries '/'. We point HOME at a
# workdir-local directory so docker has somewhere to scribble.
set -eu

cd "$SOURCE_DIR/kernel"

export HOME="$PWD/.peipkg-docker-home"
mkdir -p "$HOME"

# Build. pkm's `make kernel` chains verify-scaffold -> docker build -> docker run.
# This is the slow step: 10-30 minutes cold, faster with ccache + layer cache.
make kernel

# PSD-009 §3.4.1: real kernel image lives under /usr/lib/<triplet>/ (arch-
# specific data); /boot/ holds a symlink so legacy bootloaders that probe
# /boot/ still find it. Symlink target is relative so it survives DESTDIR
# rebasing.
install -D -m 0644 out/bzImage "$DESTDIR/usr/lib/x86_64-linux-peios/kernel/vmlinuz"
mkdir -p "$DESTDIR/boot"
ln -sf ../usr/lib/x86_64-linux-peios/kernel/vmlinuz "$DESTDIR/boot/vmlinuz"

# regman documentation for the kernel's own registry knobs. The kernel
# owns these keys (KMES under Machine\System\KMES, LCS under
# Machine\System\Registry), so it ships their manuals; regman reads the
# drop-in directory /usr/share/regman/, one provider per file (stem =
# provider). Ship every fragment under the source tree's regman/ dir, so
# new knob docs are picked up without touching this recipe.
for frag in "$SOURCE_DIR"/regman/*.regman; do
	# Skip the literal pattern if regman/ is absent or empty (e.g. a tag
	# from before these docs existed); set -e would otherwise fail here.
	[ -e "$frag" ] || continue
	install -D -m 0644 "$frag" "$DESTDIR/usr/share/regman/$(basename "$frag")"
done

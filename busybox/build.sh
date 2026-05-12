#!/bin/sh
# busybox: single static binary providing dozens of POSIX utilities.
#
# Build is static-musl: musl-gcc as CC, CONFIG_STATIC=y in .config. The
# farm has musl-tools installed (Debian package; provides /usr/bin/musl-gcc).
#
# Install layout follows PSD-009 §3.4.1 — everything under /usr/bin/:
#   usr/bin/busybox      -- the binary itself
#   usr/bin/<applet>     -- symlink to busybox for each applet
#
# The conventional /bin and /sbin trees that `make install` would create
# are NOT used; busybox's own --list emits the applets and we lay them all
# at /usr/bin/. Peios is usrmerged so /bin/sh resolves via a system-level
# /bin -> /usr/bin symlink at runtime (created by peios-image's initramfs
# bundler or, eventually, a real installer).
set -eu

cd "$SOURCE_DIR"

# Start from busybox's defconfig, then enable static linking.
make defconfig
# CONFIG_STATIC is "# CONFIG_STATIC is not set" in defconfig; flip it on.
sed -i 's|^# CONFIG_STATIC is not set|CONFIG_STATIC=y|' .config
# Resolve any new prompts non-interactively. `yes ""` answers default for
# everything (which is "n" / "leave unchanged" for new symbols).
yes "" | make oldconfig >/dev/null

# Build with musl-gcc. HOSTCC stays as the system gcc because some build-
# time helpers (e.g. mkdep) are run on the build host.
#
# Linux UAPI headers live in two Debian-multiarch trees:
#   /usr/include/linux/                  -- arch-independent (linux/kd.h, ...)
#   /usr/include/x86_64-linux-gnu/asm/   -- arch-specific (asm/types.h, ...)
# musl-gcc's default search path covers neither. `-idirafter` adds them
# AFTER musl's own libc headers in the search order, so musl's <stdio.h>
# etc. still win but kernel UAPI is findable.
make HOSTCC=gcc CC=musl-gcc \
    EXTRA_CFLAGS="-idirafter /usr/include -idirafter /usr/include/x86_64-linux-gnu" \
    -j"$(nproc)"

# Stage. busybox is the actual binary; the rest are symlinks.
install -D -m 0755 busybox "$DESTDIR/usr/bin/busybox"
for applet in $(./busybox --list); do
    # Skip the "busybox" applet itself — we just installed it as a real file.
    if [ "$applet" = "busybox" ]; then
        continue
    fi
    ln -sf busybox "$DESTDIR/usr/bin/$applet"
done

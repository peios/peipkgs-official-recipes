#!/bin/sh
# prelude: Peios initramfs tooling.
#
# Builds three static-musl binaries from the prelude workspace:
#   prelude -- initramfs PID 1
#   mkirf   -- deterministic initramfs cpio.gz builder
#   seed-sd -- early-boot/install helper for seeding KACS SDs
#
# The package farm sandbox has no HOME and is strict-confined: only the
# manager work dir is writable. Point Cargo's home and target dir at
# workdir-local paths so it does not write to '/' or a read-only system path.
set -eu

cd "$SOURCE_DIR"

export CARGO_HOME="$PWD/.peipkg-cargo-home"
export CARGO_TARGET_DIR="$PWD/.peipkg-target"
mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"

# On NixOS, the default cargo/rustc may be shimmed in a way that cannot find
# the rustup-installed musl stdlib. Prefer the rustup stable toolchain when it
# is present; package-farm hosts without rustup fall back to plain cargo.
if command -v rustup >/dev/null 2>&1 && CARGO="$(rustup which cargo --toolchain stable 2>/dev/null)"; then
    RUSTUP_TC="$(dirname "$CARGO")"
    export PATH="$RUSTUP_TC:$PATH"
elif [ -n "${HOME:-}" ] && [ -x "$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo" ]; then
    RUSTUP_TC="$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin"
    export PATH="$RUSTUP_TC:$PATH"
    CARGO="$RUSTUP_TC/cargo"
else
    CARGO="cargo"
fi

# The repo's .cargo/config.toml selects x86_64-unknown-linux-musl and rust-lld.
# Pass the target explicitly so the build farm log makes the package ABI plain.
"$CARGO" build --release --target x86_64-unknown-linux-musl

REL="$CARGO_TARGET_DIR/x86_64-unknown-linux-musl/release"

# prelude is not a normal command; image builders copy it into initramfs as PID 1.
install -D -m 0755 "$REL/prelude" \
    "$DESTDIR/usr/lib/x86_64-linux-peios/prelude/prelude"

# mkirf and seed-sd are command-line tools.
install -D -m 0755 "$REL/mkirf" "$DESTDIR/usr/bin/mkirf"
install -D -m 0755 "$REL/seed-sd" "$DESTDIR/usr/bin/seed-sd"

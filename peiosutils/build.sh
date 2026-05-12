#!/bin/sh
# peiosutils: cargo workspace producing four static-musl-PIE bin tools.
#
# The workspace's .cargo/config.toml defaults the build target to
# x86_64-unknown-linux-musl with rust-lld + crt-static, so a plain
# `cargo build --release --workspace` from the workspace root produces
# the right artifacts.
#
# The peipkg-build sandbox has no HOME. Cargo writes its state to
# $HOME/.cargo by default; we point CARGO_HOME and CARGO_TARGET_DIR at
# workdir-local paths so cargo doesn't try '/'.
set -eu

cd "$SOURCE_DIR"

export CARGO_HOME="$PWD/.peipkg-cargo-home"
export CARGO_TARGET_DIR="$PWD/.peipkg-target"
mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"

cargo build --release --workspace

REL="$CARGO_TARGET_DIR/x86_64-unknown-linux-musl/release"

install -D -m 0755 "$REL/protoinit"     "$DESTDIR/usr/bin/protoinit"
install -D -m 0755 "$REL/whoami-token"  "$DESTDIR/usr/bin/whoami-token"
install -D -m 0755 "$REL/show-sd"       "$DESTDIR/usr/bin/show-sd"
install -D -m 0755 "$REL/revstrm"       "$DESTDIR/usr/bin/revstrm"

#!/bin/sh
# peiosutils: the peiosified subset of the uutils coreutils port plus
# Peios-native utility tools — 17 static-musl binaries, one per command.
# The rest of the workspace is
# unported uutils and is NOT built (the stdbuf helper, in particular,
# needs a cdylib that the static-musl target can't produce).
#
# The pu_* crates depend on the published Rust libp stack:
#   github.com/peios/libp-rs  (tag v0.1.0)  -> the kernel-interface lib
#   github.com/peios/pkm      (tag uapi/rust/v0.1.0) -> peios-uapi binding
# (pinned in the crates' Cargo.toml as git deps; cargo fetches them).
#
# The peipkg-build sandbox has no HOME and is strict-confined: only the
# work dir (where $SOURCE_DIR lives) is writable. Point cargo's home and
# target dir at workdir-local paths so it never writes to '/' or a
# read-only system path.
set -eu

cd "$SOURCE_DIR"

export CARGO_HOME="$PWD/.peipkg-cargo-home"
export CARGO_TARGET_DIR="$PWD/.peipkg-target"
mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"

# Build only the curated peiosified set, static-musl. The target is passed
# explicitly (the workspace .cargo/config sets no default build target).
cargo build --release --target x86_64-unknown-linux-musl \
    -p pu_cp      --bin cp      \
    -p pu_logonse --bin logonse \
    -p pu_ls      --bin ls      \
    -p pu_mkdir   --bin mkdir   \
    -p pu_mkirf   --bin mkirf   \
    -p pu_mkfifo  --bin mkfifo  \
    -p pu_mknod   --bin mknod   \
    -p pu_mv      --bin mv      \
    -p pu_nohup   --bin nohup   \
    -p pu_regman  --bin regman  \
    -p pu_revstrm --bin revstrm \
    -p pu_rm      --bin rm      \
    -p pu_sd      --bin sd      \
    -p pu_shred   --bin shred   \
    -p pu_test    --bin test    \
    -p pu_token   --bin token   \
    -p pu_touch   --bin touch

REL="$CARGO_TARGET_DIR/x86_64-unknown-linux-musl/release"

# PSD-009 §3.4.1: usrmerged, utilities live at /usr/bin/<name>.
for bin in cp logonse ls mkdir mkirf mkfifo mknod mv nohup regman revstrm rm sd shred test token touch; do
    install -D -m 0755 "$REL/$bin" "$DESTDIR/usr/bin/$bin"
done

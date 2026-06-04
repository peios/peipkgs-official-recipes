#!/bin/sh
# loregd: the Local Registry Daemon — a single static, CGO-free Go binary.
#
# loregd backs the LCS registry hives over /dev/pkm_registry (PSD-006). It
# uses modernc.org/sqlite (pure-Go SQLite), so CGO_ENABLED=0 produces a
# fully static binary with no libc dependency.
#
# The peipkg-build sandbox has no HOME and runs under a strict-confined
# systemd unit (ProtectSystem=strict): the only writable tree is the
# manager's work dir, which is where $SOURCE_DIR lives. Go would otherwise
# default its module cache, build cache, GOPATH and per-user env file under
# $HOME (-> '/'), which fails. Point them all at workdir-local paths under
# $SOURCE_DIR, disable the env file, and pin the installed toolchain so a
# `go` directive bump can never silently trigger a network toolchain fetch.
set -eu

cd "$SOURCE_DIR"

export GOCACHE="$PWD/.peipkg-go-cache"
export GOMODCACHE="$PWD/.peipkg-go-modcache"
export GOPATH="$PWD/.peipkg-gopath"
export GOENV=off
export GOTOOLCHAIN=local
mkdir -p "$GOCACHE" "$GOMODCACHE" "$GOPATH"

# Static + CGO-free + reproducible. -buildvcs=false: the sandbox clone may
# not present git metadata `go` trusts (and stamping is undesirable here).
# Debug info is intentionally NOT stripped — a TCB daemon's symbols are
# worth keeping for crash analysis, and the [[sign]] step runs after this,
# so whatever bytes land here are what the TCB signature commits to.
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -buildvcs=false -trimpath -o loregd .

# PSD-009 §3.4.1: usrmerged, the daemon lives at /usr/bin/. protoinit
# launches it from there at boot.
install -D -m 0755 loregd "$DESTDIR/usr/bin/loregd"

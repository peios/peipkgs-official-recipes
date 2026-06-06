#!/bin/sh
# peipkg: the Peios client package manager — a single static, CGO-free Go
# binary built from cmd/peipkg. (The repo also holds cmd/peipkg-compose, a
# producer-side image tool that does not belong on a running Peios system,
# so it is deliberately not built or packaged here.)
#
# peipkg depends on the published github.com/peios/libp-go and
# github.com/peios/pkm/uapi/go modules (pinned in go.mod, no replace
# directives) — the sandbox fetches them via GOPROXY like any other dep.
# It uses modernc.org/sqlite (pure-Go), so CGO_ENABLED=0 yields a fully
# static binary.
#
# The peipkg-build sandbox has no HOME and runs under a strict-confined
# systemd unit (ProtectSystem=strict): only the manager's work dir (where
# $SOURCE_DIR lives) is writable. Point Go's caches, GOPATH and env file at
# workdir-local paths, disable the env file, and pin the installed toolchain.
set -eu

cd "$SOURCE_DIR"

export GOCACHE="$PWD/.peipkg-go-cache"
export GOMODCACHE="$PWD/.peipkg-go-modcache"
export GOPATH="$PWD/.peipkg-gopath"
export GOENV=off
export GOTOOLCHAIN=local
mkdir -p "$GOCACHE" "$GOMODCACHE" "$GOPATH"

# Static + CGO-free + reproducible. -buildvcs=false because the sandbox
# clone may not present git metadata `go` trusts.
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -buildvcs=false -trimpath -o peipkg ./cmd/peipkg

# PSD-009 §3.4.1: usrmerged, the package manager CLI lives at /usr/bin/.
install -D -m 0755 peipkg "$DESTDIR/usr/bin/peipkg"

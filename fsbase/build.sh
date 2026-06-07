#!/bin/sh
set -eu

# Shape only. Peios policy is carried by SD/KACS/LCS, not Unix modes.
mkdir -p \
    "$DESTDIR/dev" \
    "$DESTDIR/proc" \
    "$DESTDIR/run" \
    "$DESTDIR/sys" \
    "$DESTDIR/tmp" \
    "$DESTDIR/var"

#!/bin/sh
set -eu
cd "$SOURCE_DIR"
# figlet's Makefile defaults MANDIR=/usr/man (pre-FHS); override to the
# modern /usr/share/man so recipe globs match.
make prefix=/usr DESTDIR="$DESTDIR" MANDIR=/usr/share/man install

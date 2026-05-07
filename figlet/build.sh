#!/bin/sh
set -eu
cd "$SOURCE_DIR"
# Pin every install path explicitly. figlet's Makefile generation has
# drifted across versions: 2.2.4+ honor `prefix=`, but 2.2.3's
# FONTDIR/BINDIR are set to literal defaults unrelated to prefix.
# Setting them all keeps the recipe stable across the whole tag range.
make \
  DESTDIR="$DESTDIR" \
  BINDIR=/usr/bin \
  MANDIR=/usr/share/man \
  FONTDIR=/usr/share/figlet \
  prefix=/usr \
  install

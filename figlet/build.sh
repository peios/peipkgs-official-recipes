#!/bin/sh
set -eu
cd "$SOURCE_DIR"
make prefix=/usr DESTDIR="$DESTDIR" install

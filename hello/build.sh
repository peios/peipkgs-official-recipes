#!/bin/sh
set -eu
cd "$SOURCE_DIR"

# Tell bootstrap to use the vendored gnulib that peipkg-manager
# fetched via submodules, rather than git-cloning gnulib at build
# time (which would also need network and credentials).
export GNULIB_SRCDIR="$SOURCE_DIR/gnulib"

# Bootstrap regenerates configure / Makefile.in from configure.ac /
# Makefile.am, importing gnulib modules from GNULIB_SRCDIR.
# --skip-po skips po/ regeneration we don't need; --no-git stops it
# trying to commit anything.
./bootstrap --skip-po --no-git

./configure --prefix=/usr
make

make install DESTDIR="$DESTDIR"

# usr/share/info/dir is a per-system info index, not package content;
# every install would race against every other package's info/dir.
# Distros universally exclude it from their package payloads.
rm -f "$DESTDIR/usr/share/info/dir"

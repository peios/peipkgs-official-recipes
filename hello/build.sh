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

# GNU hello's man page (hello.1) is generated at 'make dist' time and
# shipped in the release tarball. The git tree does not include it,
# and the Makefile rule that would generate it via help2man is
# commented out (upstream pattern: build from tarball). Without
# hello.1 on disk, `make all` fails because man_MANS lists it.
# Touch a placeholder so `make` finishes, then regenerate with the
# real content from the live binary's --help, then install.
touch hello.1
make
help2man --include=man/hello.x ./hello --output=hello.1

make install DESTDIR="$DESTDIR"

# usr/share/info/dir is a per-system info index, not package content;
# every install would race against every other package's info/dir.
# Distros universally exclude it from their package payloads.
rm -f "$DESTDIR/usr/share/info/dir"

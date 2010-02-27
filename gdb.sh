#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -f $gdb.tar.bz2 ]] \
        || fetch $url_gnu/gdb/$gdb.tar.bz2 \
        || die "can not down load $gdb.tar.bz2 from $url_gnu"
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $gdb
    tar xjf $gdb.tar.bz2
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$gdb/configure --target=$target --prefix=$prefix \
        --disable-nls \
        || die "configure failed"
    make -j$(num_cpus) \
        || die "make failed"
}

function install() {
    cd $builddir
    sudo make install
}

function cleanup() {
    cd $buildtop
    rm -rf $builddir $gdb
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:

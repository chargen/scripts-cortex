#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -f $newlib.tar.gz ]] \
        || fetch $url_newlib/$newlib.tar.gz \
        || die "can not download $newlib.tar.gz from $url_newlib"
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $newlib
    tar xjf $newlib.tar.gz
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$newlib/configure --target=$target --prefix=$prefix \
        --enable-interwork --enable-multilib \
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
    rm -rf $builddir $newlib
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:

#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -f $binutils.tar.bz2 ]] \
        || fetch $url_gnu/binutils/$binutils.tar.bz2
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $binutils
    tar xjf $binutils.tar.bz2
    if [[ -f "$scriptdir/$binutils-*.patch" ]]; then
        for p in $scriptdir/$binutils-*.patch; do
            patch -p1 -d $binutils < $p \
                || die "patch $p failed"
        done
    fi
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    is_osx && disable_werror=--disable-werror || disable_werror=""
    ../$binutils/configure -target=$target --prefix=$prefix \
        --enable-interwork --enable-multilib \
        --disable-nls $disable_werror \
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
    rm -rf $builddir $binutils
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:

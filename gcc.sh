#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-

. $(dirname $0)/main.subr

gcccore=$(echo $gcc | sed 's/gcc-/gcc-core-/')

function download() {
    cd $buildtop
    [[ -f $gcccore.tar.bz2 ]] \
        || fetch $url_gnu/gcc/$gcc/$gcccore.tar.bz2 \
        || die "can not download $gcccore.tar.bz2 from $url_gnu"
    [[ -f $gmp.tar.bz2 ]] \
        || fetch $url_gnu/gmp/$gmp.tar.bz2 \
        || die "can not download $gmp.tar.bz2 from $url_gnu"
    [[ -f $mpfr.tar.bz2 ]] \
        || fetch $url_mpfr/$mpfr/$mpfr.tar.bz2 \
        || die "can not download $mpfr.tar.bz2 from $url_mpfr"
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $gcc
    tar xjf $gcccore.tar.bz2
    rm -rf $gcc/gmp
    tar xjf $gmp.tar.bz2 -C $gcc
    mv $gcc/$gmp $gcc/gmp
    rm -rf $gcc/mpfr
    tar xjf $mpfr.tar.bz2 -C $gcc
    mv $gcc/$mpfr $gcc/mpfr
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$gcc/configure --target=$target --prefix=$prefix \
        --enable-languages="c" --enable-interwork --enable-multilib \
        --with-newlib --with-gnu-as --with-gnu-ld \
        --without-headers \
        --disable-libspp --disable-shared --disable-nls \
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
    rm -rf $builddir $gcc
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:

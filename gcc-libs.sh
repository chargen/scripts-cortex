#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
#
#  Copyright (C) 2010 Tadashi G. Takaoka
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

. $(dirname $0)/main.subr

gcccore=$(echo $gcc | sed 's/gcc-/gcc-core-/')
builddir=$buildtop/build-$target-gcc

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
    if [[ ! -d $gcc ]]; then
        tar xjf $gcccore.tar.bz2
    fi
    if [[ ! -d $gcc/gmp ]]; then
        tar xjf $gmp.tar.bz2 -C $gcc
        mv $gcc/$gmp $gcc/gmp
    fi
    if [[ ! -d $gcc/mpfr ]]; then
        tar xjf $mpfr.tar.bz2 -C $gcc
        mv $gcc/$mpfr $gcc/mpfr
    fi
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$gcc/configure --target=$target --prefix=$prefix \
        --mandir=$prefix/share/man --infodir=$prefix/share/info \
        --enable-languages="c" --enable-interwork --enable-multilib \
        --with-newlib \
        --with-gnu-as --with-gnu-ld \
        --disable-libmudflap --disable-libgomp --disable-libssp \
        --disable-shared --disable-nls \
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

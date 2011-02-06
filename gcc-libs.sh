#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
#
# Copyright (c) 2010, Tadashi G Takaoka
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# - Neither the name of Tadashi G. Takaoka nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
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
        || fetch $url_gnu/mpfr/$mpfr.tar.bz2 \
        || die "can not download $mpfr.tar.bz2 from $url_gnu"
    [[ -f $mpc.tar.gz ]] \
        || fetch $url_mpc/$mpc.tar.gz \
        || die "can not download $mpc.tar.gz from $url_mpc"
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
    if [[ ! -d $gcc/mpc ]]; then
        tar xzf $mpc.tar.gz -C $gcc
        mv $gcc/$mpc $gcc/mpc
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

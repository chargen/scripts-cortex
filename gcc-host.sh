#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
#
# Copyright (c) 2014, Tadashi G Takaoka
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

source $(dirname $0)/main.subr

function download() {
    do_cd $buildtop
    if [[ $gcc = current ]]; then
        clone git $gcc_repo gcc-$gcc
        do_cd gcc-$gcc
        git checkout trunk
        do_cd $buildtop
    else
        fetch $gnu_url/gcc/gcc-$gcc/gcc-$gcc.tar.bz2
    fi
    [[ $gmp == host ]] || fetch $gnu_url/gmp/gmp-$gmp.tar.xz
    [[ $isl == host ]] || fetch $isl_url/isl-$isl.tar.bz2
    [[ $mpc == host ]] || fetch $gnu_url/mpc/mpc-$mpc.tar.gz
    [[ $mpfr == host ]] || fetch $gnu_url/mpfr/mpfr-$mpfr.tar.xz
    return 0
}

function prepare() {
    do_cd $buildtop
    [[ $gcc == current || -d gcc-$gcc ]] \
        || copy gcc-$gcc.tar.bz2 $buildtop/gcc-$gcc

    [[ $gmp == host || -d gmp-$gmp ]] \
        || copy gmp-$gmp.tar.xz $buildtop/gmp-$gmp
    [[ $gmp == host ]] || symlink $buildtop/gmp-$gmp gcc-$gcc/gmp

    [[ $isl == host || -d isl-$isl ]] \
        || copy isl-$isl.tar.bz2 $buildtop/isl-$isl
    [[ $isl == host ]] || symlink $buildtop/isl-$isl gcc-$gcc/isl

    [[ $mpc == host || -d mpc-$mpc ]] \
        || copy mpc-$mpc.tar.gz $buildtop/mpc-$mpc
    [[ $mpc == host ]] || symlink $buildtop/mpc-$mpc gcc-$gcc/mpc

    [[ $mpfr == host || -d mpfr-$mpfr ]] \
        || copy mpfr-$mpfr.tar.xz $buildtop/mpfr-$mpfr
    [[ $mpfr == host ]] || symlink $buildtop/mpfr-$mpfr gcc-$gcc/mpfr

    return 0
}

function build() {
    builddir=${builddir%-host}
    [[ -d $builddir ]] && do_cmd rm -rf $builddir
    do_cmd mkdir -p $builddir
    do_cd $builddir
    local lib_flags=()
    local brew_bin=$(which brew)
    if [[ $brew_bin =~ brew ]]; then
        local brew_prefix=${brew_bin%/bin/brew}
        [[ $gmp == host ]] && lib_flags+=(--with-gmp=$brew_prefix)
        [[ $isl == host ]] && lib_flags+=(--with-isl=$brew_prefix)
        [[ $mpc == host ]] && lib_flags+=(--with-mpc=$brew_prefix)
        [[ $mpfr == host ]] && lib_flags+=(--with-mpfr=$brew_prefix)
    else
        [[ $gmp == host ]] && lib_flags+=(--with-gmp)
        [[ $isl == host ]] && lib_flags+=(--with-isl)
        [[ $mpc == host ]] && lib_flags+=(--with-mpc)
        [[ $mpfr == host ]] && lib_flags+=(--with-mpfr)
    fi
    do_cmd ../gcc-$gcc/configure \
        --target=$buildtarget \
        --prefix=$prefix \
        --enable-languages="c,c++" \
        --enable-interwork \
        --enable-multilib \
        --with-newlib \
        --with-gnu-as \
        --with-gnu-ld \
        "${lib_flags[@]:-}" \
        --with-system-zlib \
        --disable-libmudflap \
        --disable-libgomp \
        --disable-libssp \
        --disable-shared \
        --disable-nls \
        || die "configure failed"
    do_cmd make -j$(num_cpus) all-host \
        || die "make failed"
}

function install() {
    builddir=${builddir%-host}
    do_cd $builddir
    do_cmd sudo make install-host
}

function cleanup() {
    do_cd $buildtop
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:

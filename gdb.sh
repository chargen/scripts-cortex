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

source $(dirname $0)/main.subr

function download() {
    do_cd $buildtop
    if [[ $gdb == current ]]; then
        clone git $binutils_gdb_repo binutils-gdb-$gdb
        do_cd binutils-gdb-$gdb
        git checkout master
        do_cd $buildtop
    else
        fetch $gnu_url/gdb/gdb-$gdb.tar.xz
    fi
    return 0
}

function prepare() {
    do_cd $buildtop
    [[ $gdb == current || -d gdb-$gdb ]] \
        || copy gdb-$gdb.tar.xz $buildtop/gdb-$gdb
    return 0
}

function build() {
    [[ -d $builddir ]] && do_cmd rm -rf $builddir
    do_cmd mkdir -p $builddir
    do_cd $builddir
    local src_dir=gdb make_target=(all)
    if [[ $gdb == current ]]; then
        src_dir=binutils-gdb
        make_target=(configure-gdb all-gdb)
    fi
    do_cmd ../$src_dir-$gdb/configure \
        --target=$buildtarget \
        --prefix=$prefix \
        --enable-interwork \
        --enable-multilib \
        --disable-nls \
        || die "configure failed"
    do_cmd make -j$(num_cpus) "${make_target[@]}" \
        || die "make failed"
}

function install() {
    do_cd $builddir
    local install_target=(install)
    [[ $gdb == current ]] && install_target=(install-gdb)
    do_cmd sudo make "${install_target[@]}"
}

function cleanup() {
    do_cd $buildtop
    do_cmd rm -rf $builddir
    [[ $gdb == current ]] || do_cmd rm -rf gdb-$gdb
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:

#!/bin/sh
#-
# Copyright (c) 2019 HardenedBSD
# Author: Shawn Webb <shawn.webb@hardenedbsd.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

build_hardenedbsd() {
	(
		set -ex

		cd ${HBSD_SRC}
		make \
		    -n ${NJOBS} \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    buildworld
		make \
		    -n ${NJOBS} \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    KERNCONF=${HBSD_KERNEL} \
		    buildkernel
	)
	return ${?}
}

build_release() {
	(
		set -ex

		cd ${HBSD_SRC}/release
		make \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    clean
		make \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    obj
		make \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    KERNCONF=${HBSD_KERNEL} \
		    NOPORTS=1 \
		    real-release
	)
	return ${?}
}

stage_release() {
	local f
	local file

	for file in $(find ${HBSD_OBJRELDIR} -maxdepth 1 -name '*.iso' - -name '*.img'); do
		f=${file##*/}
		mv ${file} ${HBSD_STAGEDIR}/${f}
		xz -c9 ${HBSD_STAGEDIR}/${f} > ${HBSD_STAGEDIR}/${f}.xz
	done
}

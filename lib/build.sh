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

_skip_build=0

skip_build() {
	_skip_build=1
}

clean_build() {
	[ ${_skip_build} -gt 0 ] && return 0

	(
		set -ex

		cd ${HBSD_SRC}/release
		make \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    clean
	)

	return 0
}

build_hardenedbsd() {
	[ ${_skip_build} -gt 0 ] && return 0

	(
		set -ex

		cd ${HBSD_SRC}
		make \
		    -j ${HBSD_NJOBS} \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    ${HBSD_NOCLEAN} \
		    buildworld
		make \
		    -j ${HBSD_NJOBS} \
		    TARGET=${HBSD_TARGET} \
		    TARGET_ARCH=${HBSD_TARGET_ARCH} \
		    KERNCONF=${HBSD_KERNEL} \
		    ${HBSD_NOCLEAN} \
		    buildkernel
	)
	return ${?}
}

build_release() {
	[ ${_skip_build} -gt 0 ] && return 0

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
	local res

	mkdir -p \
	    ${HBSD_STAGEDIR} \
	    ${HBSD_PUBDIR}

	for file in $(find ${HBSD_OBJRELDIR} -maxdepth 1 \
	    -name '*.iso' \
	    -o -name '*.img' \
	    -o -name 'MANIFEST'); do
		f=${file##*/}
		mv ${file} ${HBSD_STAGEDIR}/${f}
		res=${?}
		if [ ${res} -gt 0 ]; then
			return ${res}
		fi
		xz -kc9 ${HBSD_STAGEDIR}/${f} > ${HBSD_STAGEDIR}/${f}.xz
		res=${?}
		if [ ${res} -gt 0 ]; then
			return ${res}
		fi
	done

	# No need to compress the .txz files
	for file in $(find ${HBSD_OBJRELDIR} -maxdepth 1 \
	    -name '*.txz'); do
		f=${file##*/}
		mv ${file} ${HBSD_STAGEDIR}/${f}
		res=${?}
		if [ ${res} -gt 0 ]; then
			return ${res}
		fi
	done

	codebase_hashish > ${HBSD_STAGEDIR}/revision.txt

	return 0
}

sign_release() {
	(
		set -ex

		cd ${HBSD_STAGEDIR}
		for file in $(find . \
		    -name '*.txz' \
		    -o -name '*.img' \
		    -o -name '*.iso' \
		    -o -name '*xz' \
		    -o -name 'MANIFEST' \
		    -o -name 'revision.txt'); do
			f=${file##*/}
			sha256 ${f} >> CHECKSUMS.SHA256
			sha512 ${f} >> CHECKSUMS.SHA512
			if [ ! -z "${HBSD_GPG_KEY}" ]; then
				gpg --sign -a --detach \
				    -u ${HBSD_GPG_KEY} \
				    -o ${f}.asc \
				    ${f}
			fi
		done
	)
	return ${?}
}

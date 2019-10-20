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

is_locked() {
	if [ -e ${HBSD_LOCKFILE} ]; then
		return 0
	fi

	return 1
}

lock_build() {
	touch ${HBSD_LOCKFILE}
	return ${?}
}

unlock_build() {
	rm -f ${HBSD_LOCKFILE}
	return ${?}
}

assert_unlocked() {
	if is_locked; then
		echo "Build locked. Remove ${HBSD_LOCKFILE}"
		exit 1
	fi

	return 0
}

# The build_number function must be called EXACTLY ONCE.
build_number() {
	local n

	if [ -e ${HBSD_INDEX_FILE} ]; then
		n=$(cat ${HBSD_INDEX_FILE})
		n=$((${n} + 1))
	else
		n=1
	fi

	echo ${n} | tee ${HBSD_INDEX_FILE}
	return 0
}

update_codebase() {
	(
		set -ex

		cd ${HBSD_SRC}
		git pull
	)
	return ${?}
}

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

publish_release() {
	mv ${HBSD_STAGEDIR} ${HBSD_PUBDIR}/${HBSD_BUILDNUMBER}
	ln -sf ${HBSD_BUILDNUMBER} ${HBSD_PUBDIR}/BUILD-LATEST
	return ${?}
}

kick_publisher_tires() {
	local res

	[ -z "${HBSD_MIRROR_MASTER}" ] && return 0

	rsync -a ${HBSD_PUBDIR}/${HBSD_BUILDNUMBER}/ \
	    ${HBSD_MIRROR_MASTER}:${HBSD_MIRROR_PUBDIR}/build-${HBSD_BUILDNUMBER}
	res=${?}
	if [ ${res} -gt 0 ]; then
		return ${res}
	fi

	return ${?}
}

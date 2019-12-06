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

get_topdir() {
	local self

	self=${1}

	echo $(realpath $(dirname ${self}))
	return ${?}
}

TOPDIR=$(get_topdir ${0})

. ${TOPDIR}/../lib/build.sh
. ${TOPDIR}/../lib/config.sh
. ${TOPDIR}/../lib/log.sh
. ${TOPDIR}/../lib/publish.sh
. ${TOPDIR}/../lib/util.sh

perform_build() {
	local forcebuild
	forcebuild=${1}

	assert_unlocked && lock_build

	update_codebase || return ${?}

	if ! should_build ${forcebuild}; then
		unlock_build
		return 0
	fi

	clean_build && \
	    build_hardenedbsd && \
	    build_release && \
	    stage_release && \
	    sign_release && \
	    publish_release && \
	    kick_publisher_tires && \
	    cache_codebase_hashish && \
	    unlock_build
	return ${?}
}

main() {
	local self
	local forcebuild

	self=${0}
	shift

	forcebuild=0

	config_set_defaults

	while getopts 'c:f' o; do
		case "${o}" in
			c)
				. ${OPTARG}
				;;
			f)
				forcebuild=1
				;;
		esac
	done

	config_set_dynamic

	perform_build ${forcebuild} | build_log 2>&1

	publish_log

	return ${?}
}

main ${0} $*
exit ${?}

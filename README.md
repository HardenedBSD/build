# HardenedBSD Build Scripts

This documentation is very much a work-in-progress.

## Dependencies

* git-lite
* rsync

## Execution

bin/ci.sh -c /path/to/config/file

## Configuration

```
HBSD_GPG_KEY="BB53388D3BD9892815CB9E30819B11A26FFD188D"
HBSD_INDEX_FILE="/build/tmp/current/index"
HBSD_LOCKFILE="/build/tmp/current/lock.file"
HBSD_NJOBS=8
HBSD_SRC="/src/current"
HBSD_STAGEDIR="/build/stage/current"
HBSD_PUBDIR="/build/pub/current"
HBSD_LOGDIR="/build/log/current"

HBSD_MIRROR_MASTER="user@host
HBSD_MIRROR_PUBDIR="/pub/hardenedbsd/current/amd64/amd64"
```

#!/bin/bash
set -e -x -u

# The s5 filesystem on these floppies is located one cylinder into the disk
# (what it gets by using e.g. /dev/dsk/f0 as opposed to /dev/dsk/f0t),
# to make room for the usual PC sector 0 and any other unmentionables
# 1 cyl = 2 heads x 18 sectors/track = 36 sectors
dd if="$1" bs=512 skip=36 > system_fs
ls -l system_fs

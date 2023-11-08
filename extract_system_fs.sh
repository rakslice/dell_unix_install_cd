#!/bin/bash
set -e -x -u

dd if="$1" bs=512 skip=36 > system_fs
ls -l system_fs

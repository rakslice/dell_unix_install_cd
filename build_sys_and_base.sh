#!/bin/bash
set -e -x

dd if=system_cd.cdramd_128.img bs=512 skip=36 > system_fs
ls -l system_fs
cat system_fs base.pad.iso > sys_and_base

#!/bin/bash
set -e -x

sudo mount -t sysv -o loop,offset=18432,ro ../original_images/system.img orig/
sudo mount -t sysv -o loop,offset=18432 ../system_cd.cdramd_128.img modified/

sudo diff -ur orig modified| grep -v 'is a block special file' | grep -v '^Only in ' | tee ../system.patch




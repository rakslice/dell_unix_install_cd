#!/bin/bash
set -e -x

sudo mount -t sysv -o loop,offset=18432 ../boot.cdramd_128.img.orig orig/
sudo mount -t sysv -o loop,offset=18432 ../boot.cdramd_128.img modified/
diff -ur orig modified | less




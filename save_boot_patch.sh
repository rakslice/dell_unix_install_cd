#!/bin/bash
set -e -x -u

# a helper script to save out the checksum-specific patch
# after you've manually edited unix.cdramd_128.hex for
# a previously unknown ver

modified_ver=unix.cdramd_128.hex

[ -f unix ]
[ -f $modified_ver ]

unix_hash=$(sha256sum unix | cut -d' ' -f1)

if [ ! -d unix.hex ]; then
	xxd unix > unix.hex
fi

patch_filename=boot_unix.$unix_hash.patch
diff unix.hex $modified_ver > $patch_filename

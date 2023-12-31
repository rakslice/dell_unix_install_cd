#!/bin/bash
set -e -x -u -o pipefail

# create a modified BOOT disk image

output_filename=boot.cdramd_128.img
input_filename=original_images/boot.img

[ -f $input_filename ]

if [ -f $output_filename ]; then
	rm $output_filename
fi
cp $input_filename $output_filename
chmod +w $output_filename

mkdir -p mounts/orig
mkdir -p mounts/modified

mount | fgrep -v 'on $(pwd)/mounts/orig type' > /dev/null
sudo mount -t sysv -o ro,loop,offset=18432 $input_filename mounts/orig

cp mounts/orig/unix .

sudo umount mounts/orig

unix_hash=$(sha256sum unix | cut -d' ' -f1)

unix_patch=boot_unix.$unix_hash.patch

[ -f $unix_patch ]

# the sed munges 8-digit address output of certain xxd's that
# don't even match their manpages
xxd unix | sed 's/0\([0-9a-f]\{7\}\):/\1:/' > unix.hex

cp unix.hex unix.cdramd_128.hex

patch unix.cdramd_128.hex $unix_patch

xxd -r unix.cdramd_128.hex > unix.cdramd_128

mount | fgrep -v 'on $(pwd)/mounts/modified type' > /dev/null
sudo mount -t sysv -o loop,offset=18432 $output_filename mounts/modified
#ls -lR mounts/modified
sudo cp unix.cdramd_128 mounts/modified/unix
#ls -lR mounts/modified
sudo umount mounts/modified

xxd $output_filename | sed 's/0\([0-9a-f]\{7\}\):/\1:/' > $output_filename.hex
# for now the other boot file patch is just changing a message,
# ignore it if it doesn't apply
patch $output_filename.hex boot_loader.patch || true
xxd -r $output_filename.hex > $output_filename


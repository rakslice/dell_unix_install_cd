#!/bin/bash
set -e -x -u -o pipefail

# create a modified BOOT disk image

output_filename=boot.cdramd_128.img
input_filename=original_images/boot.img

[ -f $input_filename ]

if [ -f $output_filename]; then
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

diff - <(sha256sum unix) <<< "cfbf3f09c2bfe49eb3ad9aac74a69ec2f78a07d4b59ac99ee0ee01f525b9dbdf  unix" 

xxd unix > unix.hex

cp unix.hex unix.cdramd_128.hex

patch unix.cdramd_128.hex boot_unix.patch

xxd -r unix.cdramd_128.hex > unix.cdramd_128

mount | fgrep -v 'on $(pwd)/mounts/modified type' > /dev/null
sudo mount -t sysv -o loop,offset=18432 $output_filename mounts/modified
#ls -lR mounts/modified
sudo cp unix.cdramd_128 mounts/modified/unix
#ls -lR mounts/modified
sudo umount mounts/modified

xxd $output_filename > $output_filename.hex
patch $output_filename.hex boot_loader.patch
xxd -r $output_filename.hex > $output_filename


#!/bin/bash
set -e -x -u -o pipefail

# create a modified SYSTEM disk image

output_filename=system_cd.cdramd_128.img
input_filename=original_images/system.img

[ -f $input_filename ]

cp $input_filename $output_filename
chmod +w $output_filename

mkdir -p mounts/orig
mkdir -p mounts/modified

mount | fgrep -v 'on $(pwd)/mounts/modified type' > /dev/null
sudo mount -t sysv -o loop,offset=18432 $output_filename mounts/modified

# we need to do the patching in a temp dir because of filename len issues
if [ -d system_temp ] ; then
	rm -rf system_temp
fi
mkdir system_temp

grep '^diff ' system.patch | while read line; do
	filename=$(echo "$line" | cut -d' ' -f3 | cut -d'/' -f2-)
	cp mounts/modified/$filename system_temp/$filename
done

patch -p1 -d system_temp < system.patch

grep '^diff ' system.patch | while read line; do
	filename=$(echo "$line" | cut -d' ' -f3 | cut -d'/' -f2-)
	sudo cp system_temp/$filename mounts/modified/$filename 
done

sudo mknod mounts/modified/dev/cd0 b 2 0
sudo cp cdpresent mounts/modified/usr/bin/cdpresent
sudo chmod +x mounts/modified/usr/bin/cdpresent

sudo umount mounts/modified


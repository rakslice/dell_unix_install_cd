#!/bin/bash
set -e -x -u -o pipefail

output_filename=tester.iso

# the dir where we're building the cd contents
cddir=./cd_build_dir

# clear it out every time
if [ -d "$cddir" ]; then 
	rm -rf "$cddir"
fi
mkdir "$cddir"

./make_boot.sh
./make_system.sh

base_archive=original_images/base
diff - <(sha256sum $base_archive) <<< "46539dbfbddb1cc1f4d03d82e4c390fef320935187ab266a41a7f0db1f22e154  $base_archive"

./pad2k $base_archive "$cddir/base"

boot_floppy_image=boot.cdramd_128.img
cp $boot_floppy_image "$cddir"

./extract_system_fs.sh system_cd.cdramd_128.img
cp system_fs "$cddir"

genisoimage -o $output_filename -sort sortfile -b $boot_floppy_image -lJR "$cddir"

# double-check things we want to be at specific fixed locations
# - the system ramdisk image
# - the base system cpio archive
# are at the places we expect

# system fs
#  offset=64k bytes, 32 2k blocks
system_fs_offset=32
#  length=711 2k blocks (the fs is only 593 but it is padded to 711 to fit the disk)
system_fs_blocks=711
dd if=$output_filename bs=2048 skip=$system_fs_offset count=$system_fs_blocks | diff - system_fs

# base cpio archive
#  offset=32 + 711 2k blocks
base_offset=$(($system_fs_offset + $system_fs_blocks))
base_size=$(stat -c '%s' "$cddir/base")
base_blocks=$(($base_size / 2048))
dd if=$output_filename bs=2048 skip=$base_offset count=$base_blocks | diff - "$cddir/base"

set +x
echo "CD image creation complete"
echo "Output file: $output_filename"

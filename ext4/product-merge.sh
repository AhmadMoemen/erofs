#!/bin/bash

PARTITION=product



LOCALDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
RUNDIR=$(realpath .)
MOUNTDIR="$LOCALDIR/$PARTITION"
tmpdir="$LOCALDIR/tmp"
MERGEDIR="$LOCALDIR/pmerge"
SIZECACHE="$tmpdir/size"

rm -rf ../logs/pimg-log.txt >> /dev/null
touch ../logs/pimg-log.txt

echo "[INFO] Cleaning up existing build residue"
rm -rf $MERGEDIR >/dev/null 2>&1
umount -f -l * >/dev/null 2>&1
rm -rf $PARTITION >/dev/null 2>&1
rm -rf my_*/ >/dev/null 2>&1

# Check if product partition is present
if [ ! -f product.img ]; then
echo "[ERROR] product.img is not present, aborting..." && exit
fi
if [ $(du -sm $PARTITION.img | awk '{printf $1}') -gt 20 ]; then
echo "[ERROR] product.img is too big to be merged again, aborting..." && exit
fi

usage() {
    echo "sudo ./$0"
}

PARTITIONS="my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest"

mkdir $MERGEDIR
mkdir -p $tmpdir

merge() {
	if [ -f $partition.img ]; then
        	mkdir $partition
        	mount -o ro,loop -t auto $partition.img $partition >/dev/null 2>&1
		echo "[INFO] Merging $partition into product.img"
        	cp -fpr $partition/* $MERGEDIR/ >/dev/null 2>&1
        	umount -f -l $partition >/dev/null 2>&1
        	rm -rf $partition
        else
        	echo "[WARNING] $partition.img cannot be merged to $PARTITION, Reason: $partition not present"
        fi
}

clean() {
        echo "[INFO] Cleaning product image"
        cd $MERGEDIR
        rm -rf apkcerts.txt
        rm -rf applist
        rm -rf build.prop
        rm -rf custom_info.txt
        rm -rf decouping_wallpaper
        rm -rf del*
        rm -rf etc
        rm -rf framework
        rm -rf lost+found
        rm -rf media
        rm -rf non_overlay
        rm -rf plugin
        rm -rf product_overlay
        rm -rf res
        rm -rf vendor
        cd $RUNDIR
}

prepimg() {
	e2fsck -fy $PARTITION.img
	resize2fs $PARTITION.img "$SIZE"M
	e2fsck -yE unshare_blocks $PARTITION.img
	mkdir product
	mount -o loop -t auto $PARTITION.img product
}

copy() { 
cp -fpr $MERGEDIR/* $PARTITION/ 
}

unmount() {
	umount -f -l $PARTITION
	rm -rf $PARTITION
}

getsize() {
        echo "[INFO] Setting image size"
        DIRSIZE=$(du -sm $MERGEDIR | awk '{printf $1}')
	IMGSIZE=$(du -sm $PARTITION.img | awk '{printf $1}')
	SIZE=$(($DIRSIZE + $IMGSIZE + 100))
}
for partition in $PARTITIONS; do
        merge
done
clean
getsize
echo "[INFO] Preparing the existing product.img"
prepimg >> ../logs/pimg-log.txt
copy
unmount
echo "[INFO] Done! Cleaning up"
rm -rf $MERGEDIR $tmpdir

#!/bin/bash

PARTITION=product
SIZE=$1

rm -rf log.txt >> /dev/null
touch log.txt

NEWIMAGE="$PARTITION-ext4.img"
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
RUNDIR=$(realpath .)
MOUNTDIR="$LOCALDIR/$PARTITION"
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"
fileconts="$tmpdir/plat_file_contexts"
PRODUCTDIR=$LOCALDIR/product

rm -rf $PRODUCTDIR

if [[ $1 == "" ]]; then
    SIZE=4294967296
else
    SIZE=$1
fi

usage() {
    echo "sudo ./$0 <optional: image size>"
}

PARTITIONS="my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest"

mkdir $PRODUCTDIR
mkdir -p $tmpdir
touch $fileconts

merge() {
        mkdir $partition
        mount -o loop -t erofs $partition.img $partition
        cp -fpr $partition/* $PRODUCTDIR/
        umount -f -l $partition
        rm -rf $partition
}

fconts() {
        mkdir $LOCALDIR/system
        sudo mount -o loop -t erofs $RUNDIR/system.img $LOCALDIR/system
        sudo cat $LOCALDIR/system/system/etc/selinux/plat_file_contexts >> $fileconts
        sudo umount -f -l $LOCALDIR/system
        rm -rf $LOCALDIR/system
}

for partition in $PARTITIONS; do
        echo "[INFO] Merging $partition into product.img"
        merge >> log.txt
done

fconts
echo "[INFO] Rebuilding Product image"
sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/$PARTITION" $SIZE $fileconts -j "0" -T "1230768000" -L "$PARTITION" -I "256" -M "/$PARTITION" -m "0" >> log.txt
echo "[INFO] Cleaning up"
rm -rf product

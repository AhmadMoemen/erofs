#!/usr/bin/env bash

IMAGE=$(realpath $1)
PARTITION=$2
SIZE=$3

NEWIMAGE="ext4/$PARTITION.img"
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
RUNDIR=$(dirname $1)
MOUNTDIR="$LOCALDIR/$PARTITION"
toolsdir="$LOCALDIR/tools"


usage() {
	echo "sudo ./$0 <image path> <partition name>"
}

check() {
	if [ ! -d tools ]; then
		echo "tools folder is not present, aborting..." && exit
	fi
}

testmount() {
	mkdir system
	mount -o loop -t erofs system.img system
	umount system
	rm -rf system
}

mountimg() {
	rm -rf $tmpdir $MOUNTDIR
	mkdir $MOUNTDIR
	echo "[INFO] Mounting $PARTITION..."
	mount -t auto -o ro,loop $IMAGE $MOUNTDIR
}

rebuild() {
	mkdir "ext4/"$PARTITION""
	echo "[INFO] Rebuilding $PARTITION as ext4 image..."
	# Create a blank ext4 image
	dd if=/dev/zero of=ext4/$PARTITION.img bs=4k count=4096
	mkfs.ext4 -F ext4/$PARTITION.img
	tune2fs -c0 -i0 ext4/$PARTITION.img
	IMGSIZE=$(du -sb $IMAGE | awk '{printf("%.f", $1)}')
	SIZE=$(du -sb $MOUNTDIR | awk '{printf("%.f", $1)}')
	if (( $SIZE < 1474560 )); then
		SIZE=20
	else 
		SIZE=$(du -sb $MOUNTDIR | awk '{$1=int($1*4);printf("%.f", $1)}')
		getsize
	fi
	echo "[INFO] Setting $PARTITION image size..."
	if [[ ! -z $SIZE ]]; then
		resizeimg
	fi
	mount -t auto -o loop ext4/$PARTITION.img ext4/$PARTITION
	cp -fa $MOUNTDIR/* ext4/$PARTITION
	echo "[INFO] Unmounting images..."
	unmountimg
	echo "[INFO] Done"
}

getsize() {
        DIRSIZE=$(du -sb $MOUNTDIR | awk '{$1/=1024000;printf("%.f",$1)}')
	IMGSIZE=$(du -sb $IMAGE | awk '{$1/=1024000;printf("%.f",$1)}')
	if (( $DIRSIZE > 100 )); then
		SIZE=$(($DIRSIZE + 150))
	else SIZE=$DIRSIZE
	fi
}

resizeimg() {
	e2fsck -fy ext4/$PARTITION.img
	resize2fs -f ext4/$PARTITION.img "$SIZE"M
}

unmountimg() {
	umount -f -l * >/dev/null 2>&1
	umount -f -l ext4/* >/dev/null 2>&1
	rm -rf $MOUNTDIR >/dev/null 2>&1
	rm -rf ext4/$PARTITION >/dev/null 2>&1
}

if [[ $2 == "" ]]; then 
	usage
fi
check
unmountimg
#testmount
mountimg
rebuild

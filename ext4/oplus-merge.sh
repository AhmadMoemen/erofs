#!/usr/bin/env bash

# oplus merger
RUNDIR=$(realpath .)
MODE=$1
prep() {
        echo "[INFO] Setting up"
        cd $RUNDIR
	umount -f -l * >/dev/null 2>&1
	echo "[INFO] Cleaning up existing build residue"
	clean
	if [ ! -f system.img ]; then
	echo "[ERROR] system.img is not present, aborting..." && exit
	fi
	cp system.img system-org.img
        mkdir system
	e2fsck -fy system.img
	resize2fs -f system.img 7000M
	mount -o loop -t auto system.img system
	
}
PARTITIONS="my_bigball my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock my_version"
if [[ $MODE == "--gsi" ]]; then
PARTITIONS+=" system_ext product"
fi
merge() {
        cd $RUNDIR
        if [ -f ../$partition.img ]; then
        echo "[INFO] Merging $partition into system"
        mkdir ../$partition
        mount -o ro,loop -t auto ../$partition.img ../$partition  >/dev/null 2>&1
        cd system
        cp -fa ../../$partition/* ./$partition >/dev/null 2>&1
	cd $RUNDIR >/dev/null 2>&1
	umount -f -l ../$partition >/dev/null 2>&1
        rm -rf ../$partition/ >/dev/null 2>&1
        fi
}

odmmerge() {
        cd $RUNDIR
        echo "[INFO] Merging odm into system"
        mkdir ../odm >/dev/null 2>&1
        mount -o loop -t auto ../odm.img ../odm >/dev/null 2>&1
        cd system >/dev/null 2>&1
        rm -rf odm/*
	cp -fa ../odm/build.prop ./odm/ >/dev/null 2>&1
        cp -fa ../odm/etc/ ./odm/ >/dev/null 2>&1
        rm -rf ./odm/etc/*
	OPID=$(ls -d ../odm/etc/[0-9]* | tail -c 6)
	cp -fa ../odm/etc/$OPID ./odm/etc >/dev/null 2>&1
	cp -fa ../odm/etc/normalize ./odm/etc >/dev/null 2>&1
	cp -fa ../odm/etc/*.prop ./odm/etc >/dev/null 2>&1
	cp -fa ../odm/overlay ./odm >/dev/null 2>&1
	cp -fa ../odm/etc/media_profiles_V1_0.xml ./odm/etc >/dev/null 2>&1
	[ -f ./odm/build.prop ] && sed -i 's|${ro.boot.prjname}|'$OPID'|g' ./odm/build.prop && sed -i 's|/mnt/vendor||g' ./odm/build.prop
	sed -i 's|${ro.boot.prjname}|'$OPID'|g' ./odm/etc/build.prop
	sed -i 's|/mnt/vendor||g' ./odm/etc/build.prop
        cd ..
        umount -f -l odm  >/dev/null 2>&1
	umount -f -l system  >/dev/null 2>&1
        rm -rf odm >/dev/null 2>&1
}

prepimg() {
	cd $RUNDIR
	umount -f -l system >/dev/null 2>&1
	e2fsck -fy system.img
	resize2fs -f system.img "$SIZE"M
}

setsize() {
	cd $RUNDIR
	mount -o loop -t auto system.img system
	IMGSIZE=`du -sm system | awk '{printf $1}'`
	SIZE=$(($IMGSIZE + 150))
}

clean() {
        cd $RUNDIR
	rm -rf smerge/
        umount -f -l system/ >/dev/null 2>&1
        rm -rf system/
}

prep
for partition in $PARTITIONS; do
    merge
done
#odmmerge
echo "[INFO] Setting image size..."
setsize
echo "[INFO] Preparing system image..."
prepimg
echo "[INFO] Cleaning up..."
clean
echo "[INFO] Done!"

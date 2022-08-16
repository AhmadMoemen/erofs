#!/bin/bash

# oplus merger
RUNDIR=$(realpath .)
prep() {
	rm -rf ../logs/smerge-log.txt >> /dev/null
	touch ../logs/smerge-log.txt
	rm -rf ../logs/simg-log.txt >> /dev/null
	touch ../logs/simg-log.txt
        echo "[INFO] Setting up"
        cd $RUNDIR
	echo "[INFO] Cleaning up existing build residue"
	clean
	if [ ! -f system.img ]; then
	echo "[ERROR] system.img is not present, aborting..." && exit
	fi
        mkdir system
	mkdir smerge
}
PARTITIONS="my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock my_version my_bigball"
merge() {
        cd $RUNDIR
        echo "[INFO] Merging $partition into system"
        mkdir $partition >/dev/null 2>&1
	mkdir smerge/$partition >/dev/null 2>&1
        mount -o ro,loop -t auto $partition.img $partition  >/dev/null 2>&1
        cd smerge/$partition/ >/dev/null 2>&1
        cp -fpr ../../$partition/apkcerts.txt . >/dev/null 2>&1
        cp -fpr ../../$partition/applist . >/dev/null 2>&1
        cp -fpr ../../$partition/build.prop . >/dev/null 2>&1
        cp -fpr ../../$partition/custom_info.txt . >/dev/null 2>&1
        cp -fpr ../../$partition/decouping_wallpaper . >/dev/null 2>&1
        cp -fpr ../../$partition/del* . >/dev/null 2>&1
        cp -fpr ../../$partition/etc . >/dev/null 2>&1
        cp -fpr ../../$partition/framework . >/dev/null 2>&1
        cp -fpr ../../$partition/lost+found . >/dev/null 2>&1
        cp -fpr ../../$partition/media . >/dev/null 2>&1
        cp -fpr ../../$partition/non_overlay . >/dev/null 2>&1
        cp -fpr ../../$partition/plugin . >/dev/null 2>&1
        cp -fpr ../../$partition/product_overlay . >/dev/null 2>&1
        cp -fpr ../../$partition/res . >/dev/null 2>&1
        cp -fpr ../../$partition/vendor . >/dev/null 2>&1
	cd $RUNDIR >/dev/null 2>&1
	umount -f -l $partition >/dev/null 2>&1
        rm -rf $partition/ >/dev/null 2>&1
}

odmmerge() {
        cd $RUNDIR
        echo "[INFO] Merging odm into system"
        mkdir odm >/dev/null 2>&1
        mount -o loop -t auto odm.img odm >/dev/null 2>&1
	mount -o loop -t auto system.img system >/dev/null 2>&1
        cd system >/dev/null 2>&1
        rm -rf odm/*
	cp -fpr ../odm/build.prop ./odm/ >/dev/null 2>&1
        cp -fpr ../odm/etc/ ./odm/ >/dev/null 2>&1
        rm -rf ./odm/etc/*
	OPID=$(ls -d ../odm/etc/[0-9]* | tail -c 6)
	cp -fpr ../odm/etc/$OPID ./odm/etc >/dev/null 2>&1
	cp -fpr ../odm/etc/normalize ./odm/etc >/dev/null 2>&1
	cp -fpr ../odm/etc/*.prop ./odm/etc >/dev/null 2>&1
	cp -fpr ../odm/overlay ./odm >/dev/null 2>&1
	zip -d ./odm/overlay/oplus_framework_res_overlay.display.product.$OPID.apk "res/*"
	sed -i 's|${ro.boot.prjname}|'"$OPID"'|g' ./odm/build.prop
	sed -i 's|${ro.boot.prjname}|'"$OPID"'|g' ./odm/etc/build.prop
	sed -i 's|/mnt/vendor||g' ./odm/build.prop
        cd ..
        umount -f -l odm  >/dev/null 2>&1
	umount -f -l system  >/dev/null 2>&1
        rm -rf odm >/dev/null 2>&1
}

prepimg() {
	cd $RUNDIR
	echo "[INFO] Preparing system.img"
	umount -f -l system/ >/dev/null 2>&1
	e2fsck -fy system.img
	resize2fs -f system.img "$SIZE"M
	e2fsck -yE unshare_blocks system.img
	mount -o loop -t auto system.img system
	cp -fpr smerge/* system/
}

getsize() {
	cd $RUNDIR
        echo "[INFO] Setting image size"
	mount -o loop -t auto system.img system
        DIRSIZE=`du -sm smerge | awk '{printf $1}'`
	IMGSIZE=`du -sm system/system | awk '{printf $1}'`
	SIZE=$(($DIRSIZE + $IMGSIZE + 100))
}

clean() {
        cd $RUNDIR
	rm -rf smerge/
        umount -f -l system/ >/dev/null 2>&1
        rm -rf system/
}

prep
for partition in $PARTITIONS; do
    merge >> ../logs/smerge-log.txt
done
odmmerge
getsize
prepimg >> ../logs/simg-log.txt
echo "[INFO] Cleaning up"
clean
echo "[INFO] Done"

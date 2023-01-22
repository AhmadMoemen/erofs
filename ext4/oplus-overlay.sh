#!/usr/bin/env bash

# oplus overlay patcher
RUNDIR=$(realpath .)
PARTITIONS="my_product odm"
MODE=$1
mountimg() {
	mkdir $part
	sudo mount -o loop -t auto $part.img $part
}

patchoverlay() {
	for part in $PARTITIONS; do
	if [[ $MODE == "--gsi" ]]; then
		mkdir system
		sudo mount -o loop system.img system
		cd system/$part/overlay
		echo "[INFO] Patching to system"
	else
		mountimg
		cd $part/overlay
	fi
	OPRC=$(find "oplus_framework_res_overlay.display.product."*".apk")
	if [ ! $OPRC == "" ]; then
	zip -d $OPRC "res/*" >/dev/null 2>&1
	java -jar ../tools/uber.jar -a $OPRC --overwrite >/dev/null 2>&1
	chcon u:object_r:vendor_overlay_file:s0 $OPRC
	echo "[INFO] Removing overlay cutouts successful!"
	break
	else
	echo "[INFO] Cutout overlay not present, aborting..."
	fi
	done
	cd $RUNDIR
	unmountimg >/dev/null 2>&1
	
}

unmountimg() {
	for part in $PARTITIONS; do
	sudo umount -f -l $part
	rm -rf $part
	done
	if [[ $MODE == "--gsi" ]]; then
	umount -f -l system
	rm -rf system
	fi
}

patchoverlay

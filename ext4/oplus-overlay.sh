#!/bin/bash

# oplus merger
RUNDIR=$(realpath .)
PARTITIONS="system product odm"

mountimg() {
	mkdir $part
	sudo mount -o loop $part.img $part
}

patchoverlay() {
	OPRC=./odm/overlay/oplus_framework_res_overlay.display.product.$OPID.apk
	[ ! -f $OPRC ] && OPRC=./product/overlay/oplus_framework_res_overlay.display.product.$OPID.apk
	if [ -f $OPRC ]; then
	zip -d $OPRC "res/*" >/dev/null 2>&1
	java -jar ../../tools/uber.jar -a $OPRC --overwrite >/dev/null 2>&1
	fi
}

unmountimg() {
	sudo umount -f -l $part
}

for part in $PARTITIONS; do
	mountimg
done
OPID=$(ls -d ./odm/etc/[0-9]* | tail -c 6)
patchoverlay
for part in $PARTITIONS; do
	unmountimg
	rm -rf $part
done
echo "[INFO] Patch overlay apk successful."

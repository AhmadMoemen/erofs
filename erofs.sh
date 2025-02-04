#!/bin/bash

IMAGE=$(realpath $1)
PARTITION=$2
SIZE=$3

rm -rf ext4/erofs-log.txt >> /dev/null
touch logs/erofs-log.txt
rm -rf ext4/mkimg-log.txt >> /dev/null
touch logs/mkimg-log.txt

NEWIMAGE="ext4/$PARTITION.img"
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
RUNDIR=$(dirname $1)
MOUNTDIR="$LOCALDIR/$PARTITION"
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"
fileconts="$tmpdir/$2_file_contexts"


usage() {
    echo "sudo ./$0 <image path> <partition name>"
}

if [[ $2 == "" ]]; then 
    usage
fi

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
    sudo mount -t auto -o ro,loop $IMAGE $MOUNTDIR
}

contextfix() {
    echo "/opconfig(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/opcust(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/3rdmodem(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/3rdmodemnvm(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/3rdmodemnvmbkp(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/cust(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/eng(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/hw_product(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/log(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/modem_log(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/patch_hw(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/preas(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/prets(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/pretvs(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/resetFactory.cfg(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/sec_storage(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/splash2(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_bigball(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_carrier(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_custom(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_company(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_engineering(/.*)?                u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_heytap(/.*)?                     u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_manifest(/.*)?                   u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_preload(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_product(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_region(/.*)?                     u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_stock(/.*)?                      u:object_r:rootfs:s0" >> "$fileconts"
    echo "/my_version(/.*)?                    u:object_r:rootfs:s0" >> "$fileconts"
    echo "/special_preload(/.*)?               u:object_r:rootfs:s0" >> "$fileconts"
    echo "/preavs(/.*)?                        u:object_r:rootfs:s0" >> "$fileconts"
    echo "/preload(/.*)?                       u:object_r:rootfs:s0" >> "$fileconts"
    echo "/version(/.*)?                       u:object_r:rootfs:s0" >> "$fileconts"
    echo "/(oppo_custom|my_custom)/theme_bak(/.*)? u:object_r:oppo_theme_data_file:s0
    /(my_(engineering|version|product|company|preload|bigball|carrier|region|stock|heytap|manifest|custom)|special_preload)(/.*)?           u:object_r:system_file:s0
    /(my_(engineering|version|product|company|preload|bigball|carrier|region|stock|heytap|custom)|special_preload)/overlay(/.*)?   u:object_r:vendor_overlay_file:s0
    /(my_(engineering|version|product|company|preload|bigball|carrier|region|stock|heytap|custom)|special_preload)/non_overlay/overlay(/.*)?   u:object_r:vendor_overlay_file:s0
    /(my_(engineering|version|product|company|preload|bigball|carrier|region|stock|heytap|custom)|special_preload)/vendor_overlay/[0-9]+/.*   u:object_r:vendor_file:s0
    /(my_(engineering|version|product|company|preload|bigball|carrier|region|stock|heytap|custom)|special_preload)/vendor/etc(/.*)?    u:object_r:vendor_configs_file:s0
    /(my_version|odm)/build.prop                                             u:object_r:vendor_file:s0
    /(my_version|odm)/vendor_overlay/[0-9]+/lib(64)?(/.*)?    u:object_r:same_process_hal_file:s0
    /(my_version|odm)/vendor_overlay/[0-9]+/etc/camera(/.*)?  u:object_r:same_process_hal_file:s0
    /(my_version|odm)/vendor_overlay/[0-9]+/camera(/.*)?      u:object_r:vendor_file:s0
    /(my_version|odm)/lib64/camera(/.*)?                      u:object_r:vendor_file:s0
    /(my_version|odm)/vendor_overlay/lib?(/.*)?         u:object_r:same_process_hal_file:s0
    /(my_version|odm)/vendor_overlay/lib(64)?(/.*)?     u:object_r:same_process_hal_file:s0
    /my_manifest/build.prop u:object_r:vendor_file:s0
    /my_company/theme_bak(/.*)? u:object_r:oem_theme_data_file:s0
    /my_product/etc/project_info.txt                                   u:object_r:vendor_file:s0
    /my_product/product_overlay/framework(/.*)?          u:object_r:system_file:s0
    /my_product/product_overlay/etc/permissions(/.*)?    u:object_r:system_file:s0
    /(vendor|my_engineering|system/vendor)/bin/factory	u:object_r:factory_exec:s0
    /(vendor|my_engineering|system/vendor)/bin/pcba_diag	u:object_r:pcba_diag_exec:s0
    /my_product/lib(64)?/libcolorx-loader\.so                                                   u:object_r:same_process_hal_file:s0
    /my_product/vendor/firmware(/.*)      u:object_r:vendor_file:s0
    /my_version/vendor/firmware(/.*)?      u:object_r:vendor_file:s0" >> "$fileconts"
    if [[ $PARTITION != "system" ]]; then
        mkdir $LOCALDIR/system
        sudo mount -t auto $RUNDIR/system.img $LOCALDIR/system
        sudo cat $LOCALDIR/system/system/etc/selinux/plat_file_contexts >> $fileconts
        sudo umount -f -l $LOCALDIR/system
        rm -rf $LOCALDIR/system
    fi
}

rebuild() {
    mkdir $tmpdir
    echo "[INFO] Rebuilding $PARTITION as ext4 image..."
    # selibux
    cp -fpr $(sudo find $MOUNTDIR | grep file_contexts) $tmpdir/ >/dev/null 2>&1
    if [[ $PARTITION == "system" ]]; then
    fileconts="$tmpdir/plat_file_contexts"
    contextfix
    fi
    [[ $PARTITION == "vendor" ]] && echo "/(vendor|system/vendor)(/.*)?                  u:object_r:vendor_file:s0" >> "$fileconts"
    [[ $PARTITION == "odm" ]] && echo "/(odm|vendor/odm)(/.*)?                       u:object_r:vendor_file:s0" >> "$fileconts"
    [[ $PARTITION == "system_ext" ]] && echo "/(system_ext|system/system_ext)(/.*)?               u:object_r:system_file:s0" >> "$fileconts"
    # end selinux
    IMGSIZE=$(du -sb $IMAGE | awk '{printf("%.f", $1)}')
    SIZE=$(du -sb $MOUNTDIR | awk '{printf("%.f", $1)}')
    if (( $SIZE < 1474560 )); then
        SIZE=$(( $IMGSIZE * 3 ))
    else SIZE=$(du -sb $MOUNTDIR | awk '{$1=int($1*4);printf("%.f", $1)}')
    fi
    if [[ $PARTITION == "system" ]]; then
        sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/" $SIZE $fileconts -j "0" -T "1230768000" -L "/" -I "256" -M "/" -m "0" >> logs/mkimg-log.txt
    else
        sudo $toolsdir/mkuserimg_mke2fs.py "$MOUNTDIR/" "$NEWIMAGE" ext4 "/$PARTITION" $SIZE $fileconts -j "0" -T "1230768000" -L "$PARTITION" -I "256" -M "/$PARTITION" -m "0" >> logs/mkimg-log.txt
    fi
    echo "[INFO] Setting $PARTITION image size"
    getsize
    if [[ ! -z $NEWSIZE ]]; then
    resizeimg >> logs/erofs-log.txt
    fi
    sudo umount -f -l $MOUNTDIR
    rm -rf $MOUNTDIR 
    sudo rm -rf $tmpdir
    echo "[INFO] Done"
}

getsize() {
        DIRSIZE=$(du -sm $MOUNTDIR |  awk '{printf("%.f", $1)}')
	IMGSIZE=$(du -sm ./ext4/$PARTITION.img |  awk '{printf("%.f", $1)}')
	if (( $DIRSIZE > 100 )); then
	NEWSIZE=$(($IMGSIZE + 100))
	else NEWSIZE=""
	fi
}

resizeimg() {
	e2fsck -fy ext4/$PARTITION.img
	resize2fs -f ext4/$PARTITION.img "$NEWSIZE"M
}

check
testmount
mountimg
rebuild

#!/bin/bash
RUNDIR=$(realpath .)
cd $RUNDIR

echo "[INFO] Cleaning up existing build residue"
rm -rf ext4/*.img
PARTITIONS="my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest system vendor system_ext"
echo "Batch converting erofs images..."
echo
for part in $PARTITIONS
do
	if [ -f "$part.img" ]; then
	echo "[INFO] Converting $part.img to erofs"
	./erofs.sh $part.img $part
	mv *-ext4.img ext4/
	fi
done
[ $(du -sm $MERGEDIR | awk '{printf $1}') -gt 20 ] && cp product.img ext4/
cd ext4
for part in $PARTITIONS
do
	mv $part-ext4.img $part.img
done
echo "[INFO] Merging partitions into product.img"
./product-merge.sh

echo "[INFO] Merging partitions into system.img"
./oplus-merge.sh

echo "[INFO] Rebuild oplus images & merge done."

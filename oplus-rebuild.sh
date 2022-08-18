#!/bin/bash
RUNDIR=$(realpath .)
cd $RUNDIR

echo "[INFO] Cleaning up existing build residue"
rm -rf ext4/*.img
PARTITIONS="my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest system vendor system_ext odm"
echo "Batch converting erofs images..."
echo
for part in $PARTITIONS
do
	if [ -f "$part.img" ]; then
	echo "[INFO] Converting $part.img to erofs"
	./erofs.sh $part.img $part
	fi
done
if [ -f product.img ]; then
	cp product.img ext4/
	cd ext4
	echo "[INFO] Merging partitions into product.img"
	./product-merge.sh
else
	echo "[WARNING] Product image is not present, skipping..."
	cd ext4
fi
if [ -f system.img ]; then
echo "[INFO] Merging partitions into system.img"
./oplus-merge.sh
else
echo "[WARNING] System image is missing, skipping..."
fi
OUT="system vendor system_ext odm product"
for out in $OUT
do
	if [ -f $out.img ]; then
	cp -fpr $out.img ../out
	fi
done
[ -f system-org.img ] && mv system-org.img system.img
cp ../product.img .
echo "[INFO] Rebuild oplus images & merge done."

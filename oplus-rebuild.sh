#!/usr/bin/env bash
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
RUNDIR=$(realpath .)
HOST="$(uname)"
toolsdir="$LOCALDIR/tools"
if [[ "$(uname)" == *CYGWIN* ]]; then
    HOST=Windows
fi
romzip="$(realpath $1)"
MODE=$2

# METHODS start
usage() {
	echo "sudo $0 <firmware zip> <arguments>"
}
erofs() {
echo "Batch converting erofs images..."
echo
for part in $PARTITIONS
do
	if [[ -f "$part.img" ]]; then
	echo "[INFO] Converting $part.img to ext4"
	./erofs.sh $part.img $part
	fi
done
}
main() {
cd ext4
if [ -f system.img ]; then
echo "[INFO] Merging partitions into system.img"
./oplus-merge.sh
else
echo "[WARNING] System image is missing, skipping..."
fi
./oplus-overlay.sh --gsi
}

gsi() {
cd ext4
if [ -f system.img ]; then
echo "[INFO] Merging partitions into system.img"
./oplus-merge.sh --gsi
else
echo "[WARNING] System image is missing, skipping..."
fi
./oplus-overlay.sh --gsi
}

oplus() {
./oplus-overlay.sh
}

# METHODS end

# main script

if [ "$romzip" == "" ]; then
    usage
    exit
fi
cd $RUNDIR
echo "[INFO] Cleaning up existing build residue"
rm -rf ext4/*.img
# Extract payload (Firmware-extractor)
payload_go="$toolsdir/$HOST/bin/payload-dumper-go"
if [[ $(7z l -ba "$romzip" | grep payload.bin) ]]; then
    $payload_go -o $RUNDIR $romzip
fi
if [[ $MODE == "--oplus" ]]; then
	PARTITIONS="my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest system vendor system_ext odm"
	erofs
	oplus
elif [[ $MODE == "--gsi" ]]; then
	PARTITIONS="system"
	erofs
	gsi
else
	PARTITIONS="system vendor system_ext odm"
	erofs
	main
fi
OUT=$PARTITIONS
cp -fa ../product.img ../out
for out in $OUT
do
	if [ -f $out.img ]; then
	cp -fa $out.img ../out
	fi
done
echo "[INFO] Rebuild oplus images & merge done."

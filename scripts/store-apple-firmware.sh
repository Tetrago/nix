#!/bin/sh

echo "NOTICE: It may be necessary to boot into MacOS and run $(curl https://alx.sh | sh) to update the necessary files"

set -eu

outdir="/tmp/${0##*/}-$$/firmware.cpio"
[ -d "$outdir" ] && exit 1

mkdir -p "$outdir"
trap "rm -r $outdir" EXIT

cp /boot/vendorfw/firmware.cpio "$outdir/"
echo "Copied: firmware.cpio"

hash=$(nix --experimental-features 'nix-command' hash path "$outdir")
echo "Identified hash: $hash"

path="$(nix-store --add-fixed --recursive sha256 "$outdir")"
echo "Added store entry: $path"

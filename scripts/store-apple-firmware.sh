#!/usr/bin/env sh

outdir="/tmp/${0##*/}-$$"

abort() {
	rm -r "$outdir"
	exit 1
}

[ -d "$outdir" ] && exit 1
mkdir "$outdir"

cp /boot/asahi/all_firmware.tar.gz "$outdir/"
[ $? -ne 0 ] && abort || echo "Copied firmware."

cp /boot/asahi/kernelcache.release.* "$outdir/"
echo "Copied kernelcache."

kernelcache="$(ls -1 "$outdir" | grep kernelcache)"
name="${kernelcache#$outdir/kernelcache.release.}"
[ -z "$name" ] && abort || echo "Identified \"$name\" kernelcache."

out="$outdir/$name-firmware.tar.gz"

tar -czf "$out" -C "$outdir" "all_firmware.tar.gz" "$kernelcache"
[ $? -ne 0 ] && abort || echo "Archived firmware to \"$out\"."

hash=$(nix --experimental-features 'nix-command' hash "$out")
echo "Identified hash: $hash"

path="$(nix-store --add-fixed sha256 "$out")"
[ $? -ne 0 ] && abort || echo "Added store entry \"$path\"."

rm -r "$outdir"

{ pkgs }:

let
  lsiommu = pkgs.writeShellScriptBin "lsiommu" ''
    #!/usr/bin/env bash
    shopt -s nullglob
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ''${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ''${d##*/})"
        done;
    done;
  '';
in
pkgs.mkShell {
  name = "dev";

  packages = with pkgs; [
    pciutils
    usbutils
    hwloc
    amdgpu_top
    intel-gpu-tools
    cpu-x
    lsiommu
  ];
}

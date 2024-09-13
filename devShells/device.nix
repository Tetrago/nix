{
  fd,
  writeShellScriptBin,
  mkShell,
  pciutils,
  usbutils,
  util-linux,
  hwloc,
  amdgpu_top,
  intel-gpu-tools,
  cpu-x,
  nerdfetch,
  cpufetch,
}:

let
  lsiommu = writeShellScriptBin "lsiommu" ''
    #!/usr/bin/env bash
    shopt -s nullglob
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ''${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ''${d##*/})"
        done;
    done;
  '';

  lsnvme = writeShellScriptBin "lsnvme" ''
    #!/usr/bin/env bash
    ${fd}/bin/fd "^nvme" /sys/block/ | xargs -I{} sh -c "echo -n '{}  '; cat {}/device/address"
  '';
in
mkShell {
  name = "device";

  packages = [
    pciutils
    usbutils
    util-linux
    hwloc
    amdgpu_top
    intel-gpu-tools
    cpu-x
    lsiommu
    lsnvme
    nerdfetch
    cpufetch
  ];
}

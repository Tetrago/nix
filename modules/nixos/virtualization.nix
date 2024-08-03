{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (lib.lists) allUnique optional optionals;
  inherit (lib.strings) concatStringsSep;
in {
  options.tetrago.virtualization = {
    enable = mkEnableOption "enable libvirt";

    cpu = mkOption {
      type = with types; nullOr (enum [ "amd" "intel" ]);
      default = null;
    };

    passthrough = mkOption {
      type = with types; nullOr (listOf string);
      default = null;
      example = [ "10de:1e87" ];
    };

    kvmfr = {
      enable = mkEnableOption "enable kvmfr";

      sizes = mkOption {
        type = with types; listOf ints.positive;
        default = [ ];
        example = [ 32 ];
        description =
          "next power of 2 from (width * height * depth * 2 / 1024 / 1024 + 10) where depth is 4 for sdr and 8 for hdr";
      };
    };

    devices = {
      enable = mkEnableOption "enable cgroup exceptions";

      kvmfr = mkOption {
        type = types.bool;
        default = true;
        description = "passthrough kvmfr devices when available";
      };
    };
  };

  config = with config.tetrago.virtualization;
    mkIf enable {
      assertions = mkIf (passthrough != null) [
        {
          assertion = allUnique passthrough;
          message = "passthroughs should be unique";
        }
        {
          assertion = cpu != null;
          message = "virtualization cpu not selected";
        }
      ];

      boot = mkIf (passthrough != null) {
        extraModulePackages =
          mkIf kvmfr.enable (with config.boot.kernelPackages; [ kvmfr ]);

        kernelModules = mkIf kvmfr.enable [ "kvmfr" ];

        initrd.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" ];

        kernelParams = [
          "${toString cpu}_iommu=on"
          "iommu=pt"
          "vfio-pci.ids=${concatStringsSep "," passthrough}"
        ] ++ optional kvmfr.enable "kvmfr.static_size_mb=${
            concatStringsSep "," (map toString kvmfr.sizes)
          }";
      };

      services.udev.extraRules =
        mkIf kvmfr.enable ''SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660"'';

      virtualisation.libvirtd = {
        enable = true;

        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;

          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              }).fd
            ];
          };
        };

        qemuVerbatimConfig = mkIf devices.enable (let
          inherit (lib.lists) imap0;

          deviceList = [
            "null"
            "full"
            "zero"
            "random"
            "urandom"
            "ptmx"
            "kvm"
            "kqemu"
            "rtc"
            "hpet"
            "vfio"
          ] ++ optionals (kvmfr.enable && devices.kvmfr)
            (imap0 (i: _: "kvmfr${toString i}") kvmfr.sizes);
        in ''
          cgroup_device_acl = [${
            concatStringsSep "," (map (v: ''"/dev/${v}"'') deviceList)
          }]
        '');
      };
    };
}

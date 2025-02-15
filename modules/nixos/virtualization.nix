{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.lists) allUnique optional optionals;
  inherit (lib.strings) concatStringsSep;
in
{
  options.tetrago.virtualization = {
    enable = mkEnableOption "libvirt and virt-manager";

    cpu = mkOption {
      type =
        with types;
        nullOr (enum [
          "amd"
          "intel"
        ]);
      default = null;
    };

    passthrough = mkOption {
      type = with types; nullOr (listOf str);
      default = null;
      example = [ "10de:1e87" ];
    };

    kvmfr = {
      enable = mkEnableOption "kvmfr";

      sizes = mkOption {
        type = with types; listOf ints.positive;
        default = [ ];
        example = [ 32 ];
        description = "Next power of 2 from (width * height * depth * 2 / 1024 / 1024 + 10) where depth is 4 for sdr and 8 for hdr";
      };
    };

    devices = {
      enable = mkEnableOption "cgroup exceptions";

      kvmfr = mkOption {
        type = types.bool;
        default = true;
        description = "Passthrough kvmfr devices when available";
      };
    };
  };

  config =
    let
      cfg = config.tetrago.virtualization;
    in
    mkIf cfg.enable {
      assertions = mkIf (cfg.passthrough != null) [
        {
          assertion = allUnique cfg.passthrough;
          message = "Passthroughs should be unique";
        }
        {
          assertion = cfg.cpu != null;
          message = "Virtualization cpu not selected";
        }
      ];

      boot = mkIf (cfg.passthrough != null) {
        extraModulePackages = mkIf cfg.kvmfr.enable (with config.boot.kernelPackages; [ kvmfr ]);

        kernelModules = mkIf cfg.kvmfr.enable [ "kvmfr" ];

        initrd.kernelModules = [
          "vfio"
          "vfio_pci"
          "vfio_iommu_type1"
        ];

        kernelParams =
          [
            "${toString cfg.cpu}_iommu=on"
            "iommu=pt"
            "vfio-pci.ids=${concatStringsSep "," cfg.passthrough}"
          ]
          ++ optional cfg.kvmfr.enable "kvmfr.static_size_mb=${concatStringsSep "," (map toString cfg.kvmfr.sizes)}";
      };

      services.udev.extraRules = mkIf cfg.kvmfr.enable ''SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660"'';

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

          verbatimConfig = mkIf cfg.devices.enable (
            let
              inherit (lib.lists) imap0;

              deviceList =
                [
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
                ]
                ++ optionals (cfg.kvmfr.enable && cfg.devices.kvmfr) (
                  imap0 (i: _: "kvmfr${toString i}") cfg.kvmfr.sizes
                );
            in
            ''
              cgroup_device_acl = [${concatStringsSep "," (map (v: ''"/dev/${v}"'') deviceList)}]
            ''
          );
        };
      };
    };
}

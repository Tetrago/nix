{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isInt;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.lists) allUnique optional optionals;
  inherit (lib.strings) concatStringsSep;

  framebufferType =
    with types;
    submodule {
      options = {
        width = mkOption { type = ints.positive; };
        height = mkOption { type = ints.positive; };

        depth = mkOption {
          type = coercedTo (enum [
            "sdr"
            "hdr"
          ]) (x: if x == "sdr" then 4 else 8) ints.positive;
          default = "sdr";
        };
      };
    };

  findFramebufferSizeMb =
    let
      nextPow2 = acc: x: if acc >= x then acc else nextPow2 (acc * 2) x;
    in
    fb: nextPow2 1 (fb.width * fb.height * fb.depth * 2 / 1024 / 1024 + 10);
in
{
  options.tetrago.virtualization = {
    enable = mkEnableOption "libvirt and virt-manager.";

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
      enable = mkEnableOption "kvmfr.";

      sizes = mkOption {
        type = with types; listOf (either framebufferType ints.positive);
        apply = map (x: if isInt x then x else findFramebufferSizeMb x);
        default = [ ];
      };
    };

    devices = {
      enable = mkEnableOption "cgroup exceptions.";

      kvmfr = mkOption {
        type = types.bool;
        default = true;
        description = "Passthrough kvmfr devices when available.";
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

        extraModprobeConfig = ''
          softdep xhci_pci pre: vfio-pci
          softdep nvme pre: vfio-pci

          options vfio-pci ids=${concatStringsSep "," cfg.passthrough}
        '';

        initrd.kernelModules = [
          "vfio"
          "vfio_pci"
          "vfio_iommu_type1"
        ];

        kernelParams = [
          "${toString cfg.cpu}_iommu=on"
          "iommu=pt"
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

          verbatimConfig = mkIf cfg.devices.enable (
            let
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

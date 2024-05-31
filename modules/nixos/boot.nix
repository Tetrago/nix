{ config, inputs, lib, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkForce mkIf;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.grub2-themes.nixosModules.default
  ];

  options.tetrago.boot = {
    enable = mkEnableOption "enable boot configuration";

    loader = mkOption {
      type = types.enum [ "systemd" "grub" ];
      default = "systemd";
    };

    skipBootMenu = mkOption {
      type = types.bool;
      default = true;
    };

    secureboot = {
      enable = mkEnableOption "enable secureboot";
      enableTpm2 = mkEnableOption "enable tpm2 support";
    };
  };

  config = with config.tetrago.boot; mkIf enable {
    assertions = [
      {
        assertion = !(loader == "grub" && secureboot.enable);
        message = "secureboot requires systemd-boot";
      }
    ];

    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };

        systemd-boot = {
          enable = mkForce (if loader == "systemd" then !secureboot.enable else false);
          configurationLimit = 15;
        };

        grub = {
          enable = mkForce (loader == "grub");
          configurationLimit = 15;
          efiSupport = true;
          device = "nodev";
        };

        grub2-theme = mkIf (loader == "grub") {
          enable = true;
          screen = "2k";
        };

        timeout = mkIf skipBootMenu 0;
      };

      lanzaboote = mkIf secureboot.enable {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      initrd.systemd = {
        enable = true;
        enableTpm2 = secureboot.enable && secureboot.enableTpm2;
      };
    };
  };
}

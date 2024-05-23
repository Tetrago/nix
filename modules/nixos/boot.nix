{ config, inputs, lib, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkForce mkIf;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.tetrago.boot = {
    enable = mkEnableOption "enable boot configuration";

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
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };

        systemd-boot = {
          enable = mkForce (!secureboot.enable);
          configurationLimit = 15;
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

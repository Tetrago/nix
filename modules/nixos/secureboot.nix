{ config, inputs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.secureboot = {
    enable = mkEnableOption "enable secureboot";
    enableTpm2 = mkEnableOption "enable tpm2 support";
  };

  config = mkIf config.secureboot.enable {
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };
        systemd-boot = {
          enable = lib.mkForce false;
          configurationLimit = 15;
        };
      };

      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      initrd.systemd = mkIf config.secureboot.enableTpm2 {
        enable = true;
        enableTpm2 = true;
      };
    };
  };
}

{ config, inputs, lib, ... }:

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options = {
    secureboot.enable = lib.mkEnableOption "enable secureboot";
    secureboot.enableTpm2 = lib.mkEnableOption "enable tpm2 support";
  };

  config = lib.mkIf config.secureboot.enable (lib.mkMerge [
    ({
      boot = {
        loader = {
          systemd-boot.enable = lib.mkForce false;
          efi.canTouchEfiVariables = true;
          efi.efiSysMountPoint = "/boot/efi";
        };
        lanzaboote = {
          enable = true;
	  pkiBundle = "/etc/secureboot";
        };
      };
    })
    (lib.mkIf config.secureboot.enableTpm2 {
      boot.initrd.systemd = {
        enable = true;
	enableTpm2 = true;
      };
    })
  ]);
}

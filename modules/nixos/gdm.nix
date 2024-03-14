{ config, lib, pkgs, ... }:

{
  options = {
    gdm.enable = lib.mkEnableOption "enable gdm";
    gdm.enablePlymouth = lib.mkEnableOption "enable plymouth smooth transition support";
  };

  config = lib.mkIf config.gdm.enable (lib.mkMerge [
    ({
      services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        excludePackages = [ pkgs.xterm ];
      };
    })
    (lib.mkIf config.gdm.enablePlymouth {
      systemd.services.display-manager = let plymouth = "${pkgs.plymouth}/bin/plymouth"; in {
	onFailure = [ "plymouth-quit.service" ];
	conflicts = [ "plymouth-quit.service" ];
	after = [
	  "plymouth-quit.service"
	  "rc-local.service"
	  "plymouth-start.service"
	  "systemd-user-sessions.service"
	];
	preStart = "-${plymouth} deactivate";
	postStart = "-/usr/bin/env sleep 30\n-${plymouth} quit --retain-splash";
      };
    })
  ]);
}

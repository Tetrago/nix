{ config, lib, pkgs, ... }:

{
  options.gdm = {
    enable = lib.mkEnableOption "enable gdm";
    enablePolkit = lib.mkEnableOption "enable gnome polkit";
  };

  config = lib.mkIf config.gdm.enable (lib.mkMerge [
    ({
      services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        excludePackages = [ pkgs.xterm ];
      };
    })
    (lib.mkIf config.gdm.enablePolkit {
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
	wantedBy = [ "graphical-session.target" ];
	wants = [ "graphical-session.target" ];
	after = [ "graphical-session.target" ];
	serviceConfig = {
	  Type = "simple";
	  ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
	  Restart = "on-failure";
	  ResdtartSec = 1;
	  TimeoutStopSec = 10;
	};
      };
    })
  ]);
}

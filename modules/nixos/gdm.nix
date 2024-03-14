{ config, lib, pkgs, ... }:

{
  options = {
    gdm.enable = lib.mkEnableOption "enable gdm";
  };

  config = lib.mkIf config.gdm.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      excludePackages = [ pkgs.xterm ];
    };
  };
}

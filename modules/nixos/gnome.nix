{ config, lib, pkgs, ... }:

{
  options = {
    gnome.enable = lib.mkEnableOption "enable gnome";
  };

  config = lib.mkIf config.gnome.enable {
    services = {
      xserver.desktopManager.gnome.enable = true;
      gnome.core-utilities.enable = false;
    };

    environment = {
      gnome.excludePackages = [ pkgs.gnome-tour ];
      systemPackages = [ pkgs.gnomeExtensions.no-overview ];
    };

    programs.dconf.profiles.user.databases = [{
      settings = with lib.gvariant; {
         "org/gnome/online-accounts".whitelisted-providers = mkEmptyArray type.string;
        "org/gnome/shell".enabled-extensions = [ "no-overview@fthx" ];
      };
    }];
  };
}

{
  config,
  lib,
  ...
}:

let
  inherit (builtins) any;
  inherit (lib) mkDefault mkIf;
  inherit (lib.attrsets) mapAttrsToList;
in
{
  config =
    mkIf
      (any (x: x.enable) (
        mapAttrsToList (_: x: x.flume or { enable = false; }) config.home-manager.users
      ))
      {
        programs = {
          dconf.enable = true;
        };

        services = {
          gnome.gnome-keyring.enable = true;
          gvfs.enable = true;
          logind.extraConfig = "UserTasksMax=1";
          udisks2.enable = true;
        };

        security.pam.services.hyprlock.enableGnomeKeyring = true;

        xdg.portal = {
          enable = true;
          # Used to suppress the warning. Portal config is managed in the home manager config.
          config.common.default = mkDefault "*";
        };
      };
}

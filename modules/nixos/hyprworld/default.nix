{
  config,
  lib,
  ...
}:

let
  inherit (builtins) any;
  inherit (lib) mkIf;
  inherit (lib.attrsets) mapAttrsToList;
in
{
  config =
    mkIf
      (any (x: x.enable) (
        mapAttrsToList (_: x: x.hyprworld or { enable = false; }) config.home-manager.users
      ))
      {
        programs = {
          dconf.enable = true;
        };

        services = {
          gnome.gnome-keyring.enable = true;
          gvfs.enable = true;
          logind.settings.Login.UserTasksMax = 1;
          udisks2.enable = true;
        };

        security.pam.services.hyprlock.enableGnomeKeyring = true;
      };
}

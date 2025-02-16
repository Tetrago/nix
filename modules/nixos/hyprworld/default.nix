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
          gvfs.enable = true;
          udisks2.enable = true;
          logind.extraConfig = "UserTasksMax=1";
        };
      };
}

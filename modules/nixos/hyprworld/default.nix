{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (builtins) any;
  inherit (lib) mkIf;
  inherit (lib.attrsets) mapAttrsToList;
in
{
  imports = [ inputs.home-manager.nixosModules.default ];

  config =
    mkIf
      (any (x: x.enable) (
        mapAttrsToList (_: x: x.hyprworld or { enable = false; }) config.home-manager.users
      ))
      {
        programs = {
          dconf.enable = true;
          xfconf.enable = true;
        };

        services = {
          tumbler.enable = true;
          gvfs.enable = true;
          udisks2.enable = true;
        };
      };
}

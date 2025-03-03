{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      nixland.portal = {
        enable = true;
        sources = [ inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system} ];

        portals = {
          Settings = {
            name = "darkman";
            inherit (config.services.darkman) package;
          };

          Secret = {
            name = "gnome-keyring";
            package = pkgs.gnome-keyring;
          };
        };
      };
    };
}

{
  config,
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

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
      xdg.configFile."xdg-desktop-portal-shana/config.toml".text = ''
        open_file = "Gnome"
        save_file = "Gnome"
      '';

      xdg.portal = {
        enable = true;

        config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];

            "org.freedesktop.impl.portal.Settings" = [
              "darkman"
              "gtk"
            ];

            "org.freedesktop.impl.portal.Secret" = [
              "gnome-keyring"
            ];
          };
        };

        extraPortals = [
          config.services.darkman.package
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
          pkgs.gnome-keyring
        ];
      };
    };
}

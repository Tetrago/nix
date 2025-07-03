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
      cfg = config.flume;
    in
    mkIf cfg.enable {
      xdg.portal = {
        enable = true;

        config.niri = {
          default = [
            "gnome"
            "gtk"
          ];

          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };

        extraPortals = with pkgs; [
          darkman
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
          gnome-keyring
        ];
      };
    };
}

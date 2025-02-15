{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
in
{
  options.hyprworld = {
    scripts = {
      dark = mkOption {
        type = with types; attrsOf path;
        default = [ ];
      };

      light = mkOption {
        type = with types; attrsOf path;
        default = [ ];
      };
    };
  };

  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      services.darkman = {
        enable = true;
        darkModeScripts = cfg.scripts.dark;
        lightModeScripts = cfg.scripts.light;
      };

      xdg.portal = {
        config.hyprland."org.freedesktop.impl.portal.Settings" = [
          "darkman"
          "gtk"
        ];

        extraPortals = [
          config.services.darkman.package
        ];
      };

      systemd.user.services.darkman = {
        Service = {
          Environment = [
            "XDG_RUNTIME_DIR=/run/user/%U"
          ];
        };
      };
    };
}

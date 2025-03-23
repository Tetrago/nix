{ config, lib, ... }:

let
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      services.darkman.enable = true;

      xdg = {
        configFile."darkman/config.yaml".text = "usegeoclue: true";

        desktopEntries.darkman = {
          name = "Toggle darkman";
          noDisplay = true;
        };
      };

      systemd.user.services.darkman = {
        # If these changes are not made, darkman firing updateWallpaper on startup
        # will cause the swww daemon to hijack the current wayland display and
        # brick the session
        Unit = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
          After = [ config.wayland.systemd.target ];
        };

        Service = {
          Environment = [
            "XDG_RUNTIME_DIR=/run/user/%U"
          ];
        };
      };
    };
}

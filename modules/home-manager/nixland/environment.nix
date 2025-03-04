{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) mapAttrsToList;
in
{
  options.nixland = {
    environment = mkOption {
      type = with types; attrsOf (coercedTo anything toString str);
      default = { };
    };
  };

  config =
    let
      cfg = config.nixland;
    in
    mkIf cfg.enable {
      nixland.environment = {
        XDG_SESSION_DESKTOP = "Hyprland";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        _JAVA_AWT_WM_NONREPARENTING = 1;
        GTK_BACKEND = "wayland";
        GTK_USE_PORTAL = 1;
        NIXOS_OZONE_WL = 1;
      };

      wayland.windowManager.hyprland.settings.env = mapAttrsToList (n: v: "${n},${v}") cfg.environment;
    };
}

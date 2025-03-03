{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = [
    ./binds.nix
    ./monitor.nix
    ./portal.nix
    ./windowRules.nix
    ./workspaceRules.nix
  ];

  options.nixland = {
    enable = mkEnableOption "nixland";
  };

  config =
    let
      cfg = config.nixland;
    in
    mkIf cfg.enable {
      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;

        settings.env = [
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "GTK_BACKEND,wayland"
          "GTK_USE_PORTAL,1"
          "NIXOS_OZONE_WL,1"
        ];

        systemd = {
          enable = true;
          variables = [ "--all" ];
        };
      };
    };
}

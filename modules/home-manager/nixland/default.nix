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
    ./environment.nix
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
        portalPackage = null; # We're managing this manually
        xwayland.enable = true;

        systemd = {
          enable = true;
          variables = [ "--all" ];
        };
      };
    };
}

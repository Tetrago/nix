{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = [
    ./binds.nix
    ./windowrules.nix
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
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        xwayland.enable = true;
      };
    };
}

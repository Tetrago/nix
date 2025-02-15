{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;
  inherit (lib.lists) optional;
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

  options.tetrago.hyprland = {
    enable = mkEnableOption "enable Hyprland";

    addSession = mkOption {
      type = types.bool;
      default = true;
      description = "add hyprland session file";
    };
  };

  config =
    with config.tetrago.hyprland;
    mkIf enable {
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };

      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      services.xserver.displayManager.session = optional addSession {
        manage = "desktop";
        name = "Hyprland";
        start = "exec Hyprland 1>/dev/null 2>/dev/null";
      };
    };
}

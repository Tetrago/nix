{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib.lists) optional;
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

  options.tetrago.hyprland = {
    enable = mkEnableOption "Hyprland.";

    homeManagerModule = mkOption {
      type = types.bool;
      default = true;
      description = "Adds the home manager module and sets the appropriate package";
    };

    session = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to add a Hyprland session file.";
    };
  };

  config =
    let
      cfg = config.tetrago.hyprland;
    in
    mkIf cfg.enable (mkMerge [
      {
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

        services.xserver.displayManager.session = optional cfg.session {
          manage = "desktop";
          name = "Hyprland";
          start = "exec Hyprland 1>/dev/null 2>/dev/null";
        };
      }
      (mkIf cfg.homeManagerModule {
        home-manager.sharedModules = [
          (
            { inputs, pkgs, ... }:
            {
              wayland.windowManager.hyprland.package =
                inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            }
          )
        ];
      })
    ]);
}

{ config, inputs, lib, pkgs, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkIf;
  inherit (lib.lists) optional;
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

  options.hyprland = {
    enable = mkEnableOption "enable Hyprland";
    session = mkOption {
      type = types.bool;
      default = true;
      description = "add hyprland session file";
    };
  };

  config = mkIf config.hyprland.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland.enable = true;

    services.xserver.displayManager.session = optional config.hyprland.session {
      manage = "desktop";
      name = "Hyprland";
      start = ''
      ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland &> /dev/null &
      waitPID=$!
      '';
    };
  };
}

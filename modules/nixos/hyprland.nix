{ config, inputs, lib, pkgs, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkIf;
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

  config = with config.tetrago.hyprland; mkIf enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland.enable = true;

    services.xserver.displayManager.session = optional addSession {
      manage = "desktop";
      name = "Hyprland";
      start = let path = "$HOME/.local/share/hypr"; in ''
        mkdir -p ${path}
        number=`ls -1 ${path} | wc -l`
        format=`seq -f "%05g" $number $number`

        ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland &> ${path}/''${format}.txt &
        waitPID=$!
      '';
    };
  };
}

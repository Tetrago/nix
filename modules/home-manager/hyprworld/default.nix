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
    ./ags.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./monitors.nix
    ./rofi.nix
    ./swww.nix
    ./theme.nix
    ./kanshi.nix
  ];

  options.hyprworld = {
    enable = mkEnableOption "enable hyprworld desktop environment";
    bluetooth.enable = mkEnableOption "enable bluetooth support";
  };

  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          networkmanagerapplet # Necessary despite services.network-manager-applet.enable being set to true
        ];
      };

      services = {
        blueman-applet.enable = mkIf cfg.bluetooth.enable true;
        mpris-proxy.enable = true;
        network-manager-applet.enable = true;

        udiskie = {
          enable = true;
          automount = true;
          notify = true;
        };
      };

      xdg.portal = {
        enable = true;

        config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];

            "org.freedesktop.impl.portal.Settings" = [
              "darkman"
              "gtk"
            ];
          };
        };

        extraPortals = [
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
          pkgs.darkman
        ];
      };
    };
}

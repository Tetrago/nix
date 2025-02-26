{
  config,
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
    ./darkman.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./monitors.nix
    ./nautilus.nix
    ./portal.nix
    ./rofi.nix
    ./swww.nix
    ./kanshi.nix
  ];

  options.hyprworld = {
    enable = mkEnableOption "enable hyprworld desktop environment.";
    bluetooth.enable = mkEnableOption "enable bluetooth support.";
  };

  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        networkmanagerapplet # Necessary despite services.network-manager-applet.enable being set to true
      ];

      services = {
        blueman-applet.enable = mkIf cfg.bluetooth.enable true;
        mpris-proxy.enable = true;
        network-manager-applet.enable = true;

        gnome-keyring = {
          enable = true;
          components = [
            "secrets"
            "ssh"
          ];
        };

        udiskie = {
          enable = true;
          automount = true;
          notify = true;
        };
      };
    };
}

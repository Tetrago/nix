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
      home = {
        packages = with pkgs; [
          networkmanagerapplet # Necessary despite services.network-manager-applet.enable being set to true
        ];

        sessionVariables = {
          SSH_AUTH_SOCK = "/run/user/$UID/keyring/ssh";
        };
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

      systemd.user = {
        services.gnome-keyring = {
          Unit = {
            PartOf = [ "graphical-session-pre.target" ];
          };

          Service = {
            ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground --components=secrets,ssh";
            Restart = "on-abort";
          };

          Install = {
            WantedBy = [ "graphical-session-pre.target" ];
          };
        };

        sessionVariables = {
          SSH_AUTH_SOCK = "/run/user/%u/keyring/ssh";
        };
      };
    };
}

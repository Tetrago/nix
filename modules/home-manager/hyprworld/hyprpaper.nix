{ config, pkgs, ... }:

{
  imports = [ ./options.nix ];

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${config.hyprworld.wallpaper}
    wallpaper = ,${config.hyprworld.wallpaper}
    ipc = off
    splash = off
  '';

  systemd.user.services.hyprpaper = import ./service.nix pkgs "${pkgs.hyprpaper}/bin/hyprpaper";
}
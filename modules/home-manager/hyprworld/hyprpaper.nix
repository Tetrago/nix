{ config, pkgs, ... }:

{
  imports = [ ./options.nix ];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${config.hyprworld.wallpaper}
    wallpaper = ,${config.hyprworld.wallpaper}
    ipc = off
    splash = off
  '';

  hyprworld.services.hyprpaper = pkgs.hyprpaper;
}

{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.hyprworld;

      images =
        if (cfg.lockscreen.background != null) then
          cfg.lockscreen.background
        else
          (
            if isString cfg.wallpaper then
              {
                dark = cfg.wallpaper;
                light = cfg.wallpaper;
              }
            else
              cfg.wallpaper
          );
    in
    mkIf cfg.enable {
      polymorph = {
        enable = true;
        default = "dark";

        morph = {
          dark.context.colors = import (
            outputs.lib.mkColors {
              inherit pkgs;
              path = images.dark;
            }
          );

          light.context.colors = import (
            outputs.lib.mkColors {
              inherit pkgs;
              path = images.light;
              style = "light";
            }
          );
        };
      };
    };
}

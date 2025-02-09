{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkForce types;
in
{
  options.colors = {
    dark = mkOption {
      type = with types; attrsOf str;
    };

    light = mkOption {
      type = with types; attrsOf str;
    };
  };

  config.colors =
    let
      nix-colors-contrib = inputs.nix-colors.lib.contrib { inherit pkgs; };
    in
    {
      dark =
        mkForce
          (nix-colors-contrib.colorSchemeFromPicture {
            path = config.hyprworld.wallpaper.dark;
            variant = "dark";
          }).palette;

      light =
        mkForce
          (nix-colors-contrib.colorSchemeFromPicture {
            path = config.hyprworld.wallpaper.dark;
            variant = "light";
          }).palette;
    };
}

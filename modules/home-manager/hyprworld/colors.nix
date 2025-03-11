{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib) mkIf;

  mkColors =
    path: style:
    pkgs.stdenvNoCC.mkDerivation {
      name = "hyprworld-colors-${path}-${style}";

      dontUnpack = true;

      nativeBuildInputs = with pkgs; [
        flavours
      ];

      buildPhase = ''
        echo "{" > ./colors.txt
        flavours generate ${style} "${path}" --stdout | tail -n +4 | sed 's/: "\?\(......\)"\?/ = "\1";/' >> ./colors.txt
        echo "}" >> ./colors.txt
      '';

      installPhase = ''
        mkdir -p $out
        cp ./colors.txt $out/default.nix
      '';
    };
in
{
  imports = [ inputs.polymorph.homeManagerModules.default ];

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
          dark.context.colors = import (mkColors images.dark "dark");
          light.context.colors = import (mkColors images.light "light");
        };
      };

      xdg.dataFile = {
        "dark-mode.d/polymorph".source = config.polymorph.activate.dark;
        "light-mode.d/polymorph".source = config.polymorph.activate.light;
      };
    };
}

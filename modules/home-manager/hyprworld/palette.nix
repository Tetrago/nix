{ config, pkgs }:

let
  inherit (builtins) isString;

  colors = import (
    pkgs.stdenvNoCC.mkDerivation {
      name = "hyprworld_stylesheet";

      dontUnpack = true;

      nativeBuildInputs = with pkgs; [ okolors ];

      buildPhase =
        let
          wallpaper =
            if (isString config.hyprworld.wallpaper) then
              config.hyprworld.wallpaper
            else
              config.hyprworld.wallpaper.dark;
        in
        ''
          (echo [; okolors ${wallpaper} -w 0 -k 1 -l 10,20,30,50,80 | tail -n +2 | sed -e 's/\(.*\)/"\1"/'; echo ]) > ./default.nix
        '';

      installPhase = ''
        mkdir -p $out
        cp ./default.nix $out/
      '';
    }
  );

  col = i: builtins.elemAt colors i;
in
{
  dark-bg = col 0;
  bg = col 1;
  light-bg = col 2;

  fg = col 4;
  alt-fg = col 3;
}

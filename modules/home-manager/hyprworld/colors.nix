{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (builtins) isString listToAttrs substring;
  inherit (lib) mkIf;
  inherit (lib.asserts) assertMsg;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) findFirstIndex flatten;
  inherit (lib.strings) stringToCharacters toUpper;
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

      mkColors =
        path: style:
        let
          colors = import (outputs.lib.mkColors { inherit pkgs path style; });
          hexToInt =
            str:
            let
              dgt =
                c:
                let
                  result = findFirstIndex (x: toUpper c == x) null (stringToCharacters "0123456789ABCDEF");
                in
                assert assertMsg (result != null) "Invalid hex character: ${c}";
                result;
            in
            builtins.foldl' (acc: x: acc * 16 + dgt x) 0 (stringToCharacters str);

          fromHex = i: value: hexToInt (substring i 2 value);
        in
        listToAttrs (
          flatten (
            mapAttrsToList (
              name: value:
              let
                r = fromHex 0 value;
                g = fromHex 2 value;
                b = fromHex 4 value;
              in
              [
                { inherit name value; }
                {
                  name = "${name}_r";
                  value = r;
                }
                {
                  name = "${name}_g";
                  value = g;
                }
                {
                  name = "${name}_b";
                  value = b;
                }
                {
                  name = "${name}_c";
                  value = "${toString r}, ${toString g}, ${toString b}";
                }
              ]
            ) colors
          )
        );
    in
    mkIf cfg.enable {
      polymorph = {
        enable = true;

        morph = {
          dark.context.colors = mkColors images.dark "dark";
          light.context.colors = mkColors images.light "light";
        };
      };
    };
}

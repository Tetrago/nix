{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  hyprworld.services.ags = lib.getExe (pkgs.callPackage ./ags { inherit (inputs) ags; });
}

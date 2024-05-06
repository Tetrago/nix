{ pkgs }:

let
  inherit (pkgs) callPackage;
in
{
  flat-remix-gtk-variant = callPackage ./flat-remix-gtk-variant.nix {};
  okolors = callPackage ./okolors.nix {};
  spotify-adblock = callPackage ./spotify-adblock.nix {};
  somo = callPackage ./somo.nix {};
  rp = callPackage ./rp.nix {};
}
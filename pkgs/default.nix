{ pkgs }:

{
  flat-remix-gtk-variant = pkgs.callPackage ./flat-remix-gtk-variant.nix {};
  spotify-adblock = pkgs.callPackage ./spotify-adblock.nix {};
  somo = pkgs.callPackage ./somo.nix {};
  rp = pkgs.callPackage ./rp.nix {};
}
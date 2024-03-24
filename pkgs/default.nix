{ pkgs }:

{
  base16-flat-gtk = pkgs.callPackage ./base16-flat-gtk.nix {};
  gef = pkgs.callPackage ./gef.nix {};
  spotify-adblock = pkgs.callPackage ./spotify-adblock.nix {};
}
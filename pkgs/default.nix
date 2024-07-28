{ pkgs }:

let
  inherit (pkgs) callPackage;
in
{
  bg-nvim = callPackage ./bg-nvim.nix {};
  flat-remix-gtk-variant = callPackage ./flat-remix-gtk-variant.nix {};
  okolors = callPackage ./okolors.nix {};
  nvim-recorder = callPackage ./nvim-recorder.nix {};
  renderdoc-x11 = callPackage ./renderdoc-x11.nix {};
  rp = callPackage ./rp.nix {};
  spotify-adblock = callPackage ./spotify-adblock.nix {};
  somo = callPackage ./somo.nix {};
}

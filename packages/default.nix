{ callPackage }:

{
  binaryninja = callPackage ./binaryninja.nix { };
  bg-nvim = callPackage ./bg-nvim.nix { };
  flat-remix-gtk-variant = callPackage ./flat-remix-gtk-variant.nix { };
  okolors = callPackage ./okolors.nix { };
  renderdoc-x11 = callPackage ./renderdoc-x11.nix { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  somo = callPackage ./somo.nix { };
  vsg = callPackage ./vsg.nix { };
}

{ callPackage }:

{
  binaryninja = callPackage ./binaryninja.nix { };
  darkman-nvim = callPackage ./darkman-nvim.nix { };
  flat-remix-gtk-variant = callPackage ./flat-remix-gtk-variant.nix { };
  renderdoc-x11 = callPackage ./renderdoc-x11.nix { };
  ropium = callPackage ./ropium.nix { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  somo = callPackage ./somo.nix { };
  vsg = callPackage ./vsg.nix { };
  whitesur-firefox-theme = callPackage ./whitesur-firefox-theme.nix { };
}

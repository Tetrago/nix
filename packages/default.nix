{ callPackage }:

{
  binaryninja = callPackage ./binaryninja.nix { };
  binaryninja-unwrapped = callPackage ./binaryninja-unwrapped.nix { };
  bg-nvim = callPackage ./bg-nvim.nix { };
  flat-remix-gtk-variant = callPackage ./flat-remix-gtk-variant.nix { };
  okolors = callPackage ./okolors.nix { };
  nvim-recorder = callPackage ./nvim-recorder.nix { };
  renderdoc-x11 = callPackage ./renderdoc-x11.nix { };
  rp = callPackage ./rp.nix { };
  somo = callPackage ./somo.nix { };
  vsg = callPackage ./vsg.nix { };
}
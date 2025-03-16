{ callPackage }:

{
  bg-nvim = callPackage ./bg-nvim.nix { };
  darkman-nvim = callPackage ./darkman-nvim.nix { };
  kasasa = callPackage ./kasasa.nix { };
  renderdoc-x11 = callPackage ./renderdoc-x11.nix { };
  ropium = callPackage ./ropium.nix { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  somo = callPackage ./somo.nix { };
  vsg = callPackage ./vsg.nix { };
}

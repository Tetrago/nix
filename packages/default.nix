{ callPackage }:

{
  adwaita-nerdfont = callPackage ./adwaita-nerdfont.nix { };
  bg-nvim = callPackage ./bg-nvim.nix { };
  darkman-nvim = callPackage ./darkman-nvim.nix { };
  kasasa = callPackage ./kasasa.nix { };
  ropium = callPackage ./ropium.nix { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  vsg = callPackage ./vsg.nix { };
}

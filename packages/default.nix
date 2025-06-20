{ callPackage }:

{
  adwaita-nerdfont = callPackage ./adwaita-nerdfont.nix { };
  bg-nvim = callPackage ./bg-nvim.nix { };
  comfy-line-numbers-nvim = callPackage ./comfy-line-numbers-nvim.nix { };
  darkman-nvim = callPackage ./darkman-nvim.nix { };
  kasasa = callPackage ./kasasa.nix { };
  mellifluous-nvim = callPackage ./mellifluous-nvim.nix { };
  ropium = callPackage ./ropium.nix { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  vsg = callPackage ./vsg.nix { };
}

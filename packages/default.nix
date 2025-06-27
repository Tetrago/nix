{ callPackage }:

{
  adwaita-nerdfont = callPackage ./adwaita-nerdfont.nix { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  vsg = callPackage ./vsg.nix { };
}

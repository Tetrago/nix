{ callPackage }:

{
  adwaita-nerdfont = callPackage ./adwaita-nerdfont.nix { };
  onshape = callPackage ./onshape { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  vsg = callPackage ./vsg.nix { };
}

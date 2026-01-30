{ callPackage }:

{
  onshape = callPackage ./onshape { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  vsg = callPackage ./vsg.nix { };
  cine = callPackage ./cine.nix { };
}

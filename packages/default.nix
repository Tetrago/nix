{ callPackage }:

{
  onshape = callPackage ./onshape { };
  jupyter-app = callPackage ./jupyter-app { };
  rp = callPackage ./rp.nix { };
  sliver = callPackage ./sliver.nix { };
  vsg = callPackage ./vsg.nix { };
  cine = callPackage ./cine.nix { };
}

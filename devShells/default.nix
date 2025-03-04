{ callPackage, inputs }:

{
  ags = callPackage ./ags.nix { inherit (inputs) ags; };
  cyber = callPackage ./cyber.nix { };
  device = callPackage ./device.nix { };
}

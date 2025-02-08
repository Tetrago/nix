{ callPackage, inputs }:

{
  ags = callPackage ./ags.nix { inherit (inputs) ags; };
  device = callPackage ./device.nix { };
  cyber = callPackage ./cyber.nix { };
}

{ callPackage }:

{
  device = callPackage ./device.nix { };
  cyber = callPackage ./cyber.nix { };
}

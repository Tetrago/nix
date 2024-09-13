{ callPackage }:

{
  cyber = callPackage ./cyber.nix { };
  device = callPackage ./device.nix { };
}

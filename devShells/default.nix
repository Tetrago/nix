{ callPackage }:

{
  cyber = callPackage ./cyber.nix { };
  dev = callPackage ./dev.nix { };
}

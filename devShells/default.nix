{
  callPackage,
  inputs,
  system,
}:

{
  cyber = callPackage ./cyber.nix { pwndbg = inputs.pwndbg.packages.${system}.default; };
  device = callPackage ./device.nix { };
  wall = callPackage ./wall.nix { };
}

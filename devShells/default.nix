{
  callPackage,
  inputs,
  system,
}:

{
  ags = callPackage ./ags.nix { inherit (inputs) ags; };
  cyber = callPackage ./cyber.nix { pwndbg = inputs.pwndbg.packages.${system}.default; };
  device = callPackage ./device.nix { };
  wall = callPackage ./wall.nix { };
}

{ callPackage }:

{
  device = callPackage ./device.nix { };
  pwn = callPackage ./pwn.nix { };
}

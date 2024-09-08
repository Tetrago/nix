{ lib, pkgs }:

{
  cyber = import ./cyber.nix {
    inherit lib;
    inherit pkgs;
  };

  dev = import ./dev.nix { inherit pkgs; };
}

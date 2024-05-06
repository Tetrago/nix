{ pkgs }:

{
  cyber = import ./cyber.nix { inherit pkgs; };
}
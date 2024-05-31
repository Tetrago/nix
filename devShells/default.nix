{ pkgs }:

{
  cyber = import ./cyber.nix { inherit pkgs; };
  dev = import ./dev.nix { inherit pkgs; };
}

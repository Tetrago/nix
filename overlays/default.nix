{
  default = final: prev: import ../packages { inherit (prev) callPackage; };
  angrop = import ./angrop.nix;
}

{ inputs, pkgs }:

inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
  inherit pkgs;

  module =
    { ... }:
    {
      imports = [ (import ../../modules/nixvim/wondervim) ];

      wondervim.enable = true;
    };
}

{
  inputs,
  outputs,
  pkgs,
}:

inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
  inherit pkgs;

  module =
    { ... }:
    {
      imports = [ outputs.nixvimModules.wondervim ];
      wondervim.enable = true;
    };
}

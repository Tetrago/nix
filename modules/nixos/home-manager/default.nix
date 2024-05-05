{ config, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    ../host.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit (config) host;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}

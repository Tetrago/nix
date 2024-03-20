{ config, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    ../nixos/host.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      host = config.host;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
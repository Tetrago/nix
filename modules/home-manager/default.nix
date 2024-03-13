{ config, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    ../nixos/system.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      system = config.system;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}

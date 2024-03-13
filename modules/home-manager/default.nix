{ config, inputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.default ];

  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
	system = config.system;
      };
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}

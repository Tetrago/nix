{ inputs, outputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.default ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}

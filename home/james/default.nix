{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.james = import ./home.nix;
}

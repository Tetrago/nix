{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    nixos-hardware.url = "nixos-hardware";

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (self) outputs;

    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.cyber = import ./devShells/cyber.nix {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.outputs.overlays.default ];
      };
    };

    nixosConfigurations = {
      lithium = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        inherit system;
        modules = [ ./hosts/lithium/configuration.nix ];
      };
    };

    overlays = import ./overlays { inherit inputs; };
    packages.${system} = import ./pkgs { inherit pkgs; };
  };
}

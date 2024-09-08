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

    flake-utils.url = "github:numtide/flake-utils";
    nix-colors.url = "github:misterio77/nix-colors";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        hydrogen = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          system = "x86_64-linux";
          modules = [ ./hosts/hydrogen/configuration.nix ];
        };

        lithium = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          system = "x86_64-linux";
          modules = [ ./hosts/lithium/configuration.nix ];
        };
      };

      overlays = import ./overlays { inherit inputs; };

      devShells."x86_64-linux" = import ./devShells {
        inherit (nixpkgs) lib;

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ outputs.overlays.default ];
          config.allowUnfree = true;
        };
      };

      packages."x86_64-linux" = import ./pkgs { pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
    };
}

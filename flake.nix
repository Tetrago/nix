{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim.url = "github:nix-community/nixvim";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord.url = "github:kaylorben/nixcord";

    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    distro-grub-themes = {
      url = "github:AdisonCavani/distro-grub-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    solaar = {
      url = "github:Svenum/Solaar-Flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sherlock = {
      url = "github:Skxxtz/sherlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      inherit (lib) nixosSystem;
      inherit (lib.attrsets) filterAttrs genAttrs;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      eachDir =
        path: fn:
        genAttrs (builtins.attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir path))) fn;
      eachSystem = fn: genAttrs systems fn;
    in
    {
      nixosConfigurations = eachDir ./hosts (
        host:
        nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          system = if host == "polonium" then "aarch64-linux" else "x86_64-linux";
          modules = [ ./hosts/${host}/configuration.nix ];
        }
      );

      homeModules = eachDir ./homes (home: import ./homes/${home}) // {
        default = import ./modules/home;
        garden = import ./modules/home/garden;
        nixvim = import ./homes/james/nixvim.nix;
      };

      nixosModules = {
        default = import ./modules/nixos;
        garden = import ./modules/nixos/garden;
        home-manager = import ./modules/nixos/home-manager;
      };

      nixvimModules.wondervim = import ./modules/nixvim/wondervim;

      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;

            overlays = with outputs.overlays; [
              default
              angrop
            ];
          };
        in
        pkgs.callPackage ./devShells {
          inherit (pkgs) callPackage;
          inherit inputs;
          inherit system;
        }
      );

      overlays = import ./overlays;
      lib = import ./lib;

      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.callPackage ./packages { inherit (pkgs) callPackage; }
        // {
          nvim = import ./packages/nvim { inherit inputs outputs pkgs; };
        }
      );
    };
}

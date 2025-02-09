{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprspace = {
      url = "github:KZDKM/Hyprspace";
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

    ghostty.url = "github:ghostty-org/ghostty";
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

      systems = [ "x86_64-linux" ];

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
          system = "x86_64-linux";
          modules = [ ./hosts/${host}/configuration.nix ];
        }
      );

      homeManagerModules = eachDir ./homes (home: import ./homes/${home});

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
        }
      );

      overlays = import ./overlays;

      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.callPackage ./packages { inherit (pkgs) callPackage; }
      );
    };
}

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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;
      inherit (lib) nixosSystem;
      inherit (lib.attrsets) filterAttrs genAttrs;

      eachSystem = fn: genAttrs [ "x86_64-linux" ] fn;
    in
    {
      nixosConfigurations =
        let
          hosts = builtins.attrNames (filterAttrs (_: v: v == "directory") (builtins.readDir ./hosts));
        in
        genAttrs hosts (
          host:
          nixosSystem {
            specialArgs = {
              inherit inputs outputs;
            };
            system = "x86_64-linux";
            modules = [ ./hosts/${host}/configuration.nix ];
          }
        );

      devShells = eachSystem (
        system:
        let
          allPkgs = import nixpkgs {
            inherit system;
            overlays = [ outputs.overlays.default ];
            config.allowUnfree = true;
          };
        in
        import ./devShells { inherit (allPkgs) callPackage; }
      );

      overlays = import ./overlays { inherit inputs; };

      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./packages { inherit (pkgs) callPackage; }
      );
    };
}

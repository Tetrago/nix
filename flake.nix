{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    polymorph.url = "github:tetrago/polymorph";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim.url = "github:nix-community/nixvim";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-darkwindow = {
      url = "github:micha4w/Hypr-DarkWindow";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    hyprmag = {
      url = "github:SIMULATAN/hyprmag";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";
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
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    commander = {
      url = "github:tetrago/commander";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
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

      homeManagerModules = eachDir ./homes (home: import ./homes/${home}) // {
        hyprworld = import ./modules/home-manager/hyprworld;
        nixland = import ./modules/home-manager/nixland;
        nixvim = import ./homes/james/nixvim.nix;
      };

      nixosModules = {
        default = import ./modules/nixos;
        hyprworld = import ./modules/nixos/hyprworld;
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
          pkgs' = import nixpkgs {
            inherit system;
            overlays = [ outputs.overlays.default ];
          };
        in
        pkgs.callPackage ./packages { inherit (pkgs) callPackage; }
        // {
          emacs = import ./packages/emacs { inherit inputs pkgs; };
          nvim = import ./packages/nvim { inherit inputs outputs pkgs; };
        }
      );
    };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      nixpkgs,
      systems,
      rust-overlay,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };

          rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
          };
        in
        {
          default = (pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }) {
            packages = with pkgs; [
              gdb
              mold-wrapped
              rustToolchain
              rustPlatform.bindgenHook
            ];

            RUSTFLAGS = "-C linker=clang -C link-arg=-fuse-ld=mold";
          };
        }
      );
    };
}

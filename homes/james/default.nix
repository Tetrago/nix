{ inputs, outputs, ... }:

{
  imports = [
    inputs.polymorph.homeManagerModules.default
    inputs.polymorph.homeManagerModules.theme
    outputs.homeManagerModules.nixland

    ./bash.nix
    ./binja
    ./directories.nix
    ./firefox.nix
    ./git.nix
    ./media.nix
    ./neovide
    ./neovim.nix
    ./podman.nix
    ./programs
    ./terminal.nix
  ];
}

{ inputs, outputs, ... }:

{
  imports = [
    ./bash.nix
    ./binja
    ./directories.nix
    ./firefox.nix
    ./git.nix
    ./music.nix
    ./neovide
    ./neovim.nix
    ./podman.nix
    ./programs
    ./terminal.nix
  ];
}

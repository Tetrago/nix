{ inputs, outputs, ... }:

{
  imports = [
    inputs.polymorph.homeManagerModules.default
    inputs.polymorph.homeManagerModules.theme
    outputs.homeManagerModules.nixland

    ./bash.nix
    ./binja
    ./directories.nix
    ./discord.nix
    ./emacs.nix
    ./firefox.nix
    ./fonts.nix
    ./git.nix
    ./media.nix
    ./neovide
    ./neovim.nix
    ./podman.nix
    ./programs
    ./speech.nix
    ./terminal.nix
    ./theme.nix
    ./vscode.nix
  ];
}

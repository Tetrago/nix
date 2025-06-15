{ inputs, outputs, ... }:

{
  imports = [
    inputs.polymorph.homeManagerModules.default
    inputs.polymorph.homeManagerModules.theme
    outputs.homeManagerModules.nixland

    ./bash.nix
    ./binja
    ./discord.nix
    ./emacs.nix
    ./firefox.nix
    ./fonts.nix
    ./git.nix
    ./media.nix
    ./neovim.nix
    ./podman.nix
    ./speech.nix
    ./terminal.nix
    ./theme.nix
    ./vscode.nix
  ];
}

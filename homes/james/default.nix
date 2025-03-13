{ inputs, outputs, ... }:

{
  imports = [
    inputs.polymorph.homeManagerModules.default
    inputs.polymorph.homeManagerModules.theme
    outputs.homeManagerModules.nixland

    ./bash.nix
    ./discord.nix
    ./emacs
    ./firefox.nix
    ./git.nix
    ./media.nix
    ./neovim.nix
    ./speech.nix
    ./terminal.nix
    ./theme.nix
  ];
}

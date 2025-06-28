{ outputs, ... }:

{
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.james
    outputs.homeManagerModules.flume
  ];

  home = {
    username = "james";

    sessionVariables = {
      TERMINAL = "ghostty";
      EDITOR = "nvim";
    };

    stateVersion = "25.11";
  };

  james = {
    bash.enable = true;
    directories.enable = true;
    fonts.enable = true;
    git.enable = true;
    neovim.enable = true;
    neovide.enable = true;
    terminal.enable = true;

    programs = {
      direnv.enable = true;
      ssh.enable = true;
    };
  };
}

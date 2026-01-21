{
  outputs,
  ...
}:

{
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.james
    outputs.homeManagerModules.garden
  ];

  polymorph.enable = true;
  tetrago.nautilus.enable = true;

  garden = {
    enable = true;
    background = {
      light = ./light.png;
      dark = ./dark.png;
    };
  };

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
    neovide.enable = true;
    terminal.enable = true;

    firefox = {
      enable = true;
      theme.enable = true;
    };

    git = {
      enable = true;
      enableLibsecretIntegration = true;
    };

    media = {
      enable = true;
    };

    neovim = {
      enable = true;
      transparent = true;
    };

    programs = {
      enable = true;
      direnv.enable = true;
      ssh.enable = true;
    };
  };
}

{
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    outputs.homeModules.default
    outputs.homeModules.james
    outputs.homeModules.garden
  ];

  garden = {
    enable = true;
    background = {
      light = ./light.png;
      dark = ./dark.png;
    };

    extraExtensions = with pkgs.gnomeExtensions; [ user-stylesheet-font ];
    extraExtensionConfig.just-perfection.clock-menu-position = 1;
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
    music.enable = true;
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

    neovim = {
      enable = true;
      enableThemeIntegration = true;
      transparent = true;
    };

    programs = {
      enable = true;
      direnv.enable = true;
      ssh.enable = true;
    };
  };

  xdg.configFile."gnome-shell/gnome-shell.css".text = "#panelBox {height: 42px !important}";
}

{
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (builtins) fromJSON readDir readFile;
  inherit (lib)
    filterAttrs
    hasSuffix
    mapAttrs'
    nameValuePair
    removeSuffix
    ;
in
{
  imports = [
    outputs.homeModules.default
    outputs.homeModules.james
    outputs.homeModules.garden
  ];

  garden = {
    enable = true;
    extraExtensions = with pkgs.gnomeExtensions; [ easyeffects-preset-selector ];
    background = {
      dark = "${./dark.png}";
      light = "${./light.png}";
    };
  };

  home = {
    username = "james";

    packages = with pkgs; [
      qemu
    ];

    sessionVariables = {
      TERMINAL = "ghostty";
      EDITOR = "nvim";
    };

    stateVersion = "23.11";
  };

  programs.obs-studio.enable = true;

  services.easyeffects = {
    enable = true;
    preset = "Default";
    extraPresets =
      let
        presetsDir = ./presets;
        jsonFiles = filterAttrs (name: ty: ty == "regular" && hasSuffix ".json" name) (readDir presetsDir);
      in
      mapAttrs' (
        name: ty: nameValuePair (removeSuffix ".json" name) (fromJSON (readFile "${presetsDir}/${name}"))
      ) jsonFiles;
  };

  xdg = {
    enable = true;
    configFile = {
      "pwn.conf".text = ''
        [update]
        interval=never

        [context]
        terminal=["ghostty", "-e", "sh", "-c"]
      '';
    };
  };

  james = {
    bash.enable = true;
    directories.enable = true;
    music.enable = true;
    terminal.enable = true;

    binja = {
      enable = true;
      themes = "${
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "binary-ninja";
          rev = "0cb1eae43c6cd615eafe74db923259e4f683ac04";
          hash = "sha256-uFw098Z0D7lZTfl+QolX/JgRGKfE0FCsm6f7vNfzJUo=";
        }
      }/themes";
    };

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
    };

    podman = {
      enable = true;
      enableGui = true;
    };

    programs = {
      enable = true;
      cli.enable = true;
      direnv.enable = true;
      development.enable = true;
      games.enable = true;
      media.enable = true;
      office.enable = true;
      renderdoc.enable = true;
      ssh.enable = true;
      system.enable = true;
      utility.enable = true;
      java.enable = true;
    };
  };
}

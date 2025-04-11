{
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatLines;

  store = pkgs.writeShellScriptBin "store" ''
    if dir=$(ls -d /nix/store/*/ | sed 's|^/nix/store/||' | ${lib.getExe pkgs.fzf} --height 40% --layout=reverse); then
      ${lib.getExe pkgs.xplr} "/nix/store/$dir"
    fi
  '';
in
{
  imports = [
    outputs.homeManagerModules.james
    outputs.homeManagerModules.hyprworld
  ];

  hyprworld = {
    enable = true;

    wallpaper = {
      dark = "${./dark.png}";
      light = "${./light.png}";
    };
  };

  nixland.windowRules =
    let
      mkFloat =
        name:
        {
          width ? 350,
          height ? 500,
        }:
        [
          {
            class = name;
            rules = [
              "float"
              "size ${toString width} ${toString height}"
            ];
          }
        ];
    in
    [
      {
        class = "ghidra-Ghidra";
        title = "Ghidra";
        rules = "size 0 0";
      }
      {
        class = "ghidra-Ghidra";
        title = "Ghidra:.*";
        rules = "tile";
      }
      {
        class = "ghidra-Ghidra";
        title = "CodeBrowser";
        rules = "tile";
      }
      {
        title = "OpenTTD.*";
        rules = "tile";
      }
      {
        class = "Aseprite";
        rules = "tile";
      }
    ]
    ++ mkFloat "io.github.fizzyizzy05.binary" { height = 350; }
    ++ mkFloat "org.gnome.gitlab.cheywood.Buffer" { width = 600; }
    ++ mkFloat "dev.geopjr.Collision" { }
    ++ mkFloat "com.github.huluti.Curtail" { }
    ++ mkFloat "io.gitlab.adhami3310.Impression" { }
    ++ mkFloat "io.github.zefr0x.hashes" { };

  dconf.settings."io/missioncenter/MissionCenter".performance-page-cpu-graph = 2;

  home = {
    username = "james";
    homeDirectory = "/home/james";

    file = {
      ".gdbinit".source = pkgs.runCommand "gdbinit" { } ''
        echo "set disassembly-flavor intel" > $out

        cat "${
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/616ed5100d3588bb70e3b86737ac0609ce0635cc/.gdbinit";
            hash = "sha256-cLpH7t/oK8iFOfDnfnWw3oLGegYnNEb5vI8M7FGI7ic=";
          }
        }" >> $out
      '';

      ".sdk/jdk-21".source = "${pkgs.jdk21_headless.home}";
      ".clang-format".source = ./clang-format;
    };

    packages =
      with pkgs;
      let
        inherit (inputs.pwndbg.packages.${stdenv.hostPlatform.system})
          pwndbg
          ;
      in
      [
        # CLI
        p7zip
        fzf
        fd
        nix-output-monitor
        ctop
        file
        jq
        store

        # Media
        aseprite
        inkscape
        blender
        gimp
        handbrake
        davinci-resolve
        gnome-sound-recorder
        mousai # Song identifier
        switcheroo # Image converter
        xournalpp # PDF editor
        pinta # Minimal image editor
        pdfarranger

        # System
        bottles
        qemu
        gnome-connections
        inspector # System info
        mission-center # Resource viewier
        snoop # File search

        # Development
        meld
        turtle
        jetbrains.idea-community
        blockbench
        zeal
        ghex
        renderdoc
        pwndbg
        wildcard # Regex helper

        # Tools
        cartero # HTTP toolkit
        drawio
        bustle # DBus log

        # Utility
        obsidian
        gnome-calendar
        gnome-clocks
        chromium
        mousam # Weather
        alpaca # Ollama chat
        gnome-graphs
        key-rack # Secrets tracker
        gnome-characters
        binary # Base converter
        buffer # Volatile scratchpad
        collision # Hash calculator
        curtail # Image compressor
        impression # Removable media writer
        gnome-frog # OCR
        warp # Easy file transfer
        gnome-firmware
        celeste # Cloud file manager

        # Games
        gnome-mines
        gnome-sudoku
        aisleriot
      ];

    sessionVariables = {
      TERMINAL = "ghostty";
    };

    stateVersion = "23.11";
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      config.global.warn_timeout = "0";
      nix-direnv.enable = true;
    };

    obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.looking-glass-obs ];
    };

    ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks."*".setEnv.TERM = "xterm-256color";
    };
  };

  services = {
    easyeffects.enable = true;
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

    userDirs = {
      enable = true;
      createDirectories = false;
      desktop = null;
      publicShare = null;
      templates = pkgs.runCommand "templates" { } ''
        mkdir -p $out
        ${concatLines (
          mapAttrsToList (n: v: ''touch "$out/New ${n} File.${v}"'') {
            Text = "txt";
            Markdown = "md";
          }
        )}
      '';
    };
  };

  james = {
    bash.enable = true;
    emacs.enable = true;
    fonts.enable = true;
    speech.enable = true;
    terminal.enable = true;
    theme.enable = true;

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

    discord = {
      enable = true;
      enableNixlandIntegration = true;
    };

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
      enableNixlandIntegration = true;
    };

    neovim = {
      enable = true;
      transparent = true;
      enableDarkmanIntegration = true;
    };
  };
}

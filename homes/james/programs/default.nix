{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  flakey = pkgs.runCommand "flakey" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin/
    cp ${./flakey.sh} $out/bin/flakey
    wrapProgram $out/bin/flakey \
      --set TEMPLATE_DIR ${./templates}
  '';

  gdbinit = pkgs.runCommand "gdbinit" { } ''
    echo "set disassembly-flavor intel" > $out

    cat "${
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/616ed5100d3588bb70e3b86737ac0609ce0635cc/.gdbinit";
        hash = "sha256-cLpH7t/oK8iFOfDnfnWw3oLGegYnNEb5vI8M7FGI7ic=";
      }
    }" >> $out
  '';

  renderdoc-cl = pkgs.writeShellScriptBin "renderdoc-cl" ''
    unset WAYLAND_DISPLAY
    nohup ${pkgs.renderdoc}/bin/qrenderdoc >/dev/null 2>&1 &
  '';

  store = pkgs.writeShellScriptBin "store" ''
    if dir=$(ls -d /nix/store/*/ | sed 's|^/nix/store/||' | ${lib.getExe pkgs.fzf} --height 40% --layout=reverse); then
      ${lib.getExe pkgs.xplr} "/nix/store/$dir"
    fi
  '';
in
{
  options.james.programs = {
    enable = mkEnableOption "programs.";
    cli.enable = mkEnableOption "command line programs.";
    development.enable = mkEnableOption "development tools.";
    direnv.enable = mkEnableOption "direnv.";
    games.enable = mkEnableOption "games.";
    media.enable = mkEnableOption "media programs.";
    office.enable = mkEnableOption "LibreOffice.";
    renderdoc.enable = mkEnableOption "RenderDoc X11 launcher.";
    ssh.enable = mkEnableOption "ssh.";
    system.enable = mkEnableOption "system programs.";
    utility.enable = mkEnableOption "utility programs.";
  };

  config =
    let
      cfg = config.james.programs;
    in
    mkIf cfg.enable {
      home = {
        file = mkIf cfg.development.enable {
          ".clang-format".source = ./clang-format;
          ".gdbinit".source = gdbinit;
          ".rustfmt".source = ./rustfmt.toml;
          ".taplo.toml".source = ./taplo.toml;
        };

        packages =
          with pkgs;
          mkMerge [
            (mkIf cfg.cli.enable [
              bandwhich
              duf
              dust
              flakey
              hyperfine # Benchmarking tool
              nix-output-monitor
              store
            ])
            (mkIf cfg.development.enable [
              cartero # HTTP toolkit
              gql # SQL for Git
              pastel # Color mixing tool
              rusty-man
              tokei # Line counter
              wildcard # Regex helper
              zeal
            ])
            (mkIf cfg.games.enable [
              aisleriot
              gnome-mines
              gnome-sudoku
            ])
            (mkIf cfg.media.enable [
              aseprite
              blender
              davinci-resolve
              drawio
              gimp
              handbrake
              inkscape
              pdfarranger
              pinta # Minimal image editor
              video-downloader
              xournalpp # PDF editor
            ])
            (mkIf cfg.office.enable [
              libreoffice-fresh
              hunspell
              hunspellDicts.en_US
            ])
            (mkIf cfg.renderdoc.enable [
              renderdoc-cl
            ])
            (mkIf cfg.system.enable [
              baobab # Disk usage
              bustle # DBus log
              gnome-firmware
              inspector # System info
              resources
            ])
            (mkIf cfg.utility.enable [
              binary # Base converter
              buffer # Volatile scratchpad
              curtail # Image compressor
              ghex
              gnome-sound-recorder
              impression # Removable media writer
              key-rack # Secrets tracker
              kooha
              meld
              mousai # Song identifier
              switcheroo # Image converter
              warp
            ])
          ];
      };

      programs = {
        direnv = mkIf cfg.direnv.enable {
          enable = true;
          enableBashIntegration = true;
          config.global.warn_timeout = "0";
          nix-direnv.enable = true;
        };

        ssh = mkIf cfg.ssh.enable {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks."*" = {
            addKeysToAgent = "yes";
            setEnv.TERM = "xterm-256color";
          };
        };
      };
    };
}

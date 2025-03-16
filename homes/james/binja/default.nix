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
    mkOption
    types
    ;
  inherit (lib.lists) length;
in
{
  options.james.binja = {
    enable = mkEnableOption "Binary Ninja environment.";

    path = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/binaryninja";
    };

    themes = mkOption {
      type = with types; coercedTo path (x: [ x ]) (listOf path);
      default = [ ];
    };
  };

  config =
    let
      cfg = config.james.binja;
    in
    mkIf cfg.enable {
      home = {
        file.".binaryninja/themes".source = mkIf (length cfg.themes != 0) (
          pkgs.symlinkJoin {
            name = "binaryninja-themes";
            paths = cfg.themes;
          }
        );

        packages =
          let
            package = pkgs.buildFHSEnv {
              name = "binaryninja";

              runScript = pkgs.writeShellScript "binaryninja.sh" ''
                set -e
                exec "${cfg.path}/binaryninja" "$@"
              '';

              targetPkgs =
                pkgs:
                let
                  kdeDeps = with pkgs.kdePackages; [
                    qtbase
                    qtdeclarative
                  ];
                  xorgDeps = with pkgs.xorg; [
                    libX11
                    libxcb
                    xcbutilimage
                    xcbutilkeysyms
                    xcbutilrenderutil
                    xcbutilwm
                  ];
                in
                with pkgs;
                [
                  dbus
                  fontconfig
                  freetype
                  libGL
                  libxkbcommon
                  libxml2
                  (python3.withPackages (p: with p; [ torch ]))
                  stdenv.cc.cc
                  wayland
                  zlib
                ]
                ++ kdeDeps
                ++ xorgDeps;

              extraInstallCommands = ''
                mkdir -p $out/share/icons
                cp ${./logo.png} $out/share/icons/binaryninja.png

                mkdir -p $out/share/applications
                cp ${./binaryninja.desktop} $out/share/applications
              '';
            };
          in
          [
            package
          ];
      };
    };
}

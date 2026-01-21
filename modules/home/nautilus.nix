{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (lib.lists) any;

  package = pkgs.nautilus.overrideAttrs (
    final: prev: {
      nativeBuildInputs = prev.nativeBuildInputs or [ ] ++ [
        pkgs.makeWrapper
      ];

      preFixup =
        prev.preFixup or ""
        + ''
          gappsWrapperArgs+=(
            --prefix XDG_DATA_DIRS : "${pkgs.ffmpegthumbnailer}/share"
          )
        '';
    }
  );
in
{
  options.tetrago.nautilus = {
    enable = mkEnableOption "Nautilus configuration.";
  };

  config =
    let
      cfg = config.tetrago.nautilus;

      hasCollision = any (x: x == pkgs.collision) config.home.packages;
      hasSnoop = any (x: x == pkgs.snoop) config.home.packages;
      hasTurtle = any (x: x == pkgs.turtle) config.home.packages;
    in
    mkIf cfg.enable {
      home = {
        sessionVariables =
          let
            extensions = pkgs.symlinkJoin {
              name = "nautilus-extensions";
              paths = with pkgs; [
                file-roller
                nautilus-python
              ];
            };
          in
          {
            NAUTILUS_4_EXTENSION_DIR = "${extensions}/lib/nautilus/extensions-4";
          };

        packages = [
          package
        ];
      };

      xdg = {
        dataFile = mkMerge [
          {
            "nautilus-python/extensions/ghostty.py".source =
              "${config.programs.ghostty.package}/share/nautilus-python/extensions/ghostty.py";
          }
          (mkIf hasCollision {
            "nautilus-python/extensions/collision-extension.py".source =
              "${pkgs.collision}/share/nautilus-python/extensions/collision-extension.py";
          })
          (mkIf hasSnoop {
            "nautilus-python/extensions/snoop.py".source =
              "${pkgs.snoop}/share/nautilus-python/extensions/snoop.py";
          })
          (mkIf hasTurtle {
            "nautilus-python/extensions/turtle_nautilus.py".source =
              "${pkgs.turtle}/share/nautilus-python/extensions/turtle_nautilus.py";

            "dbus-1/services/de.philippun1.turtle.service".text = ''
              [D-BUS Service]
              Name=de.philippun1.turtle
              Exec=${pkgs.turtle}/bin/turtle_service
            '';
          })
        ];

        mimeApps = {
          enable = true;
          defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
        };
      };
    };
}

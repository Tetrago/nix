{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge;
  inherit (lib.lists) any;

  package = pkgs.nautilus.overrideAttrs (
    final: prev: {
      buildInputs =
        prev.buildInputs
        ++ (with pkgs.gst_all_1; [
          gst-plugins-good
          gst-plugins-ugly
          gst-plugins-bad
        ]);
    }
  );
in
{
  config =
    let
      cfg = config.hyprworld;

      hasCollision = any (x: x == pkgs.collision) config.home.packages;
      hasTurtle = any (x: x == pkgs.turtle) config.home.packages;
    in
    mkIf cfg.enable {
      home = {
        sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";

        packages = [
          package
        ];
      };

      xdg = {
        desktopEntries.nautilus = {
          name = "Files";
          exec = "nautilus --new-window %U";
          terminal = false;
          noDisplay = true;
          startupNotify = true;
          mimeType = [ "inode/directory" ];
        };

        dataFile = mkMerge [
          (mkIf hasCollision {
            "nautilus-python/extensions/collision-extension.py".source =
              "${pkgs.collision}/share/nautilus-python/extensions/collision-extension.py";
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
          defaultApplications."inode/directory" = "nautilus.desktop";
        };
      };
    };
}

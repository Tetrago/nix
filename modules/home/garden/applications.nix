{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  mkDefault =
    p:
    import (
      pkgs.runCommand "${p.name}-desktop.nix" { } ''
        path="$(find "${p}/share/applications" -name '*.desktop' | sort -r | head -n 1)"
        mime="$(cat "$path" | grep -oP '(?<=^MimeType=).*' | sed 's/;$//' | tr ';' '\n')"
        values="$(echo "$mime" | sed "s/.*/\"&\" = \"$(basename "$path")\";/")"

        echo "{$values}" > $out
      ''
    );
in
{
  config =
    let
      cfg = config.garden;
    in
    mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          apostrophe
          cine
          collision
          snoop
          turtle
        ];

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
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          with pkgs;
          mkDefault file-roller
          // mkDefault decibels
          // mkDefault cine
          // mkDefault loupe
          // mkDefault gnome-font-viewer
          // mkDefault papers
          // mkDefault firefox
          // mkDefault apostrophe
          // {
            "inode/directory" = "org.gnome.Nautilus.desktop";
          };
      };

      xdg = {
        enable = true;
        dataFile = {
          "nautilus-python/extensions/collision-extension.py".source =
            "${pkgs.collision}/share/nautilus-python/extensions/collision-extension.py";
          "nautilus-python/extensions/snoop.py".source =
            "${pkgs.snoop}/share/nautilus-python/extensions/snoop.py";
          "nautilus-python/extensions/turtle_nautilus.py".source =
            "${pkgs.turtle}/share/nautilus-python/extensions/turtle_nautilus.py";
          "dbus-1/services/de.philippun1.turtle.service".text = ''
            [D-BUS Service]
            Name=de.philippun1.turtle
            Exec=${pkgs.turtle}/bin/turtle_service
          '';
        };
      };
    };
}

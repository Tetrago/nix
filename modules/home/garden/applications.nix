{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge;

  getDefaultApps =
    pkg:
    let
      inherit (lib) hasSuffix replaceStrings splitString;
      inherit (lib.filesystem) listFilesRecursive;
      inherit (builtins)
        readFile
        head
        filter
        match
        listToAttrs
        ;

      desktopFile = head (
        filter (f: hasSuffix ".desktop" f) (listFilesRecursive "${pkg}/share/applications")
      );

      mimeTypes = match ".*MimeType=([^\n]+).*" (readFile desktopFile);
      desktopName = baseNameOf desktopFile;
    in
    if mimeTypes != null then
      listToAttrs (
        map (mime: {
          name = replaceStrings [ ";" ] [ "" ] mime;
          value = desktopName;
        }) (splitString ";" (head mimeTypes))
      )
    else
      { };
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
          mkMerge (
            map getDefaultApps [
              file-roller
              decibels
              cine
              loupe
              gnome-font-viewer
              papers
              firefox
              apostrophe
            ]
            ++ [
              {
                "inode/directory" = "org.gnome.Nautilus.desktop";
              }
            ]
          );
      };

      xdg = {
        enable = true;
        dataFile = {
          "nautilus-python/extensions/collision-extension.py".source =
            "${pkgs.collision}/share/nautilus-python/extensions/collision-extension.py";
          "nautilus-python/extensions/snoop.py".source =
            "${pkgs.snoop}/share/nautilus-python/extensions/snoop.py";
          # TODO: Fix.
          # "nautilus-python/extensions/turtle_nautilus.py".source =
          #   "${pkgs.turtle}/share/nautilus-python/extensions/turtle_nautilus.py";
          # "dbus-1/services/de.philippun1.turtle.service".text = ''
          #   [D-BUS Service]
          #   Name=de.philippun1.turtle
          #   Exec=${pkgs.turtle}/bin/turtle_service
          # '';
        };
      };
    };
}

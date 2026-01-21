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
      home.packages = with pkgs; [ apostrophe ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          with pkgs;
          mkDefault file-roller
          // mkDefault decibels
          // mkDefault showtime
          // mkDefault loupe
          // mkDefault gnome-font-viewer
          // mkDefault papers
          // mkDefault firefox
          // mkDefault apostrophe;
      };
    };
}

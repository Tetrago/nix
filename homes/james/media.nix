{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) attrValues head;
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.attrsets) filterAttrs mapAttrs;
  inherit (lib.strings) hasPrefix;

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
  options.james.media = {
    enable = mkEnableOption "media applications and mime configurations.";
    enableNixlandIntegration = mkEnableOption "nixland window rules.";
  };

  config =
    let
      cfg = config.james.media;
    in
    mkIf cfg.enable {
      dconf.settings = {
        "com/github/neithern/g4music" = {
          audio-sink = "pulsesink";
          music-dir = "file://${config.xdg.userDirs.music}";
          peak-characters = "•";
        };

        "org/gnome/TextEditor" = {
          highlight-current-line = true;
          restore-session = false;
        };
      };

      home.packages = with pkgs; [
        clapper
        decibels
        exhibit
        file-roller
        g4music
        loupe
        gnome-font-viewer
        papers
        typora
        (gnome-text-editor.overrideAttrs (
          final: prev: {
            postInstall =
              prev.postInstall or ""
              + ''
                substituteInPlace $out/share/applications/org.gnome.TextEditor.desktop \
                  --replace-fail "gnome-text-editor %U" "gnome-text-editor --new-window %U"
              '';
          }
        ))
      ];

      programs = {
        beets = {
          enable = true;
          settings = {
            library = "${config.xdg.userDirs.music}/.library.db";

            paths = {
              default = "$album/$title";
              comp = "$album/$title";
              singleton = "$title/$title";
            };

            plugins = [
              "fetchart"
              "thumbnails"
            ];
          };
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          with pkgs;
          let
            audio = mkDefault decibels;
            video = mkDefault clapper;

            additional =
              let
                aud = head (attrValues audio);
              in
              mapAttrs (_: _: aud) (filterAttrs (n: _: hasPrefix "audio/" n) video);
          in
          mkDefault exhibit
          // mkDefault file-roller
          // video
          // audio
          // mkDefault loupe
          // mkDefault gnome-font-viewer
          // mkDefault papers
          // mkDefault gnome-text-editor
          // mkDefault firefox
          // mkDefault typora
          // additional;
      };

      nixland.windowRules = mkIf cfg.enableNixlandIntegration [
        {
          class = "com.github.neithern.g4music";
          rules = [
            "float"
            "size 350 500"
          ];
        }
        {
          class = "org.gnome.Decibels";
          rules = [
            "float"
            "size 600 400"
          ];
        }
      ];
    };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.james.music = {
    enable = mkEnableOption "music applications and mime configurations.";
  };

  config =
    let
      cfg = config.james.music;
    in
    mkIf cfg.enable {
      dconf.settings = {
        "com/github/neithern/g4music" = {
          audio-sink = "pulsesink";
          music-dir = "file://${config.xdg.userDirs.music}";
          peak-characters = "•";
        };
      };

      home.packages = with pkgs; [
        gapless
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
              "duplicates"
              "fetchart"
              "musicbrainz"
              "thumbnails"
            ];
          };
        };
      };
    };
}

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
              "thumbnails"
            ];
          };
        };
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

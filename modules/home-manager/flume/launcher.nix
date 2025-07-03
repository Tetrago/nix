{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
in
{
  imports = [ inputs.sherlock.homeManagerModules.default ];

  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      programs.sherlock = {
        enable = true;
        settings = {
          launchers = [
            {
              name = "Clipboard";
              type = "clipboard-execution";
              args.capabilities = [
                "url"
                "colors.hex"
                "colors.rgb"
                "colors.hsl"
              ];
              priority = 1;
              home = true;
              only_home = true;
            }
            {
              name = "Calculator";
              type = "calculation";
              args.capabilities = [
                "calc.math"
                "calc.lengths"
                "calc.weights"
                "calc.volumes"
                "calc.temperatures"
              ];
              priority = 1;
            }
            {
              name = "App Launcher";
              alias = "app";
              type = "app_launcher";
              priority = 2;
              home = true;
            }
            {
              name = "Web Search";
              display_name = "Google Search";
              tag_start = "{keyword}";
              tag_end = "{keyword}";
              alias = "g";
              type = "web_launcher";
              args = {
                search_engine = "google";
                icon = "google";
              };
              priority = 100;
            }
          ];
        };
      };
    };
}

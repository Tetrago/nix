{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      flume.spawn = [ "${pkgs.swayosd}/bin/swayosd-server" ];

      xdg.configFile."swayosd/style.css".text = ''
        window#osd {
          padding: 12px 20px;
          border-radius: 999px;
          border: none;

          #container {
            margin: 16px;
          }

          progressbar:disabled, image:disabled {
            opacity: 0.5;
          }

          progressbar {
            min-height: 6px;
            border-radius: 999px;
            background: transparent;
            border: none;
          }

          trough {
            min-height: inherit;
            border-radius: inherit;
            border: none;
          }

          progress {
            min-height: inherit;
            border-radius: inherit;
            border: none;
          }
        }
      '';
    };
}

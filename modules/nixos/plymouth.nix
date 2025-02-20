{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  options.tetrago.plymouth = {
    enable = mkEnableOption "plymouth.";

    theme = mkOption {
      type = types.str;
      default = "spinner_alt";
    };

    scale = mkOption {
      type = types.float;
      default = 1.0;
    };
  };

  config =
    let
      cfg = config.tetrago.plymouth;
    in
    mkIf cfg.enable {
      boot = {
        consoleLogLevel = 0;

        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "fbcon=nodefer"
          "vt.global_cursor_default=0"
        ];

        plymouth = {
          enable = true;
          themePackages = [
            (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ cfg.theme ]; })
          ];
          inherit (cfg) theme;
          extraConfig = "DeviceScale=${toString cfg.scale}";
        };
      };
    };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  customThemeType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      package = mkOption { type = types.package; };
    };
  };
in
{
  options.tetrago.plymouth = {
    enable = mkEnableOption "plymouth.";

    theme = mkOption {
      type = with types; either str customThemeType;
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
          #"udev.log_level=3"  TODO: remove; not something I want hard-coded
          "fbcon=nodefer"
          "vt.global_cursor_default=0"
        ];

        plymouth = {
          enable = true;
          extraConfig = "DeviceScale=${toString cfg.scale}";

          theme = if isString cfg.theme then cfg.theme else cfg.theme.name;

          themePackages =
            let
              theme =
                if isString cfg.theme then
                  pkgs.adi1090x-plymouth-themes.override { selected_themes = [ cfg.theme ]; }
                else
                  cfg.theme.package;
            in
            [
              theme
            ];
        };
      };
    };
}

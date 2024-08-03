{ config, lib, pkgs, ... }:

let inherit (lib) mkEnableOption mkOption types mkIf;
in {
  options.tetrago.plymouth = {
    enable = mkEnableOption "enable plymouth";

    theme = mkOption {
      type = types.str;
      default = "spinner_alt";
      description = "theme";
    };

    scale = mkOption {
      type = types.float;
      default = 1.0;
    };
  };

  config = with config.tetrago.plymouth;
    mkIf enable {
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
          themePackages = [ pkgs.adi1090x-plymouth-themes ];
          inherit theme;
          extraConfig = "DeviceScale=${toString scale}";
        };
      };
    };
}

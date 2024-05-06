{ config, lib, pkgs, ... }:

{
  options.plymouth = {
    enable = lib.mkEnableOption "enable plymouth";
    theme = lib.mkOption {
      default = "spinner_alt";
      description = "theme";
    };
    scale = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
    };
  };

  config = lib.mkIf config.plymouth.enable {
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
        theme = "${config.plymouth.theme}";
        extraConfig = "DeviceScale=${toString config.plymouth.scale}";
      };
    };
  };
}

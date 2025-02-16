{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.audio = {
    enable = mkEnableOption "default audio configuration.";
  };

  config =
    let
      cfg = config.tetrago.audio;
    in
    mkIf cfg.enable {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
}

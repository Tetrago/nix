{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.audio = {
    enable = mkEnableOption "enable audio configuration";
  };

  config = mkIf config.tetrago.audio.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    sound.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}

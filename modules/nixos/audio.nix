{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.audio = {
    enable = mkEnableOption "enable audio configuration";
  };

  config = mkIf config.tetrago.audio.enable {
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

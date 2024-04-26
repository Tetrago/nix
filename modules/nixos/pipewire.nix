{ config, lib, ... }:

{
  options = {
    pipewire.enable = lib.mkEnableOption "enable pipewire";
  };

  config = lib.mkIf config.pipewire.enable {
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

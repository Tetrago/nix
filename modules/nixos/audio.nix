{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.tetrago.audio = {
    enable = mkEnableOption "default audio configuration.";

    samplingRate = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
    };
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

        extraConfig.pipewire = {
          "10-sample-rate" = mkIf (cfg.samplingRate != null) {
            "context.properties"."default.clock.rate" = cfg.samplingRate;
          };
        };
      };
    };
}

{
  config,
  lib,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.flume = {
    enable = mkEnableOption "flume desktop environment.";
  };

  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
    };
}

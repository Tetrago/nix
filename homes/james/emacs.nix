{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.james.emacs = {
    enable = mkEnableOption "emacs configuration.";
  };

  config =
    let
      cfg = config.james.emacs;
    in
    mkIf cfg.enable {
      home.packages = [ outputs.packages.${pkgs.stdenv.hostPlatform.system}.emacs ];
    };
}

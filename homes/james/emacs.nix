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
      home.packages = [
        (pkgs.runCommand "emacs" { } ''
          mkdir -p $out
          cp --no-preserve=mode -rL ${outputs.packages.${pkgs.stdenv.hostPlatform.system}.emacs}/* $out/
          chmod +x $out/bin/emacs
          rm $out/share/applications/emacsclient*
        '')
      ];
    };
}
